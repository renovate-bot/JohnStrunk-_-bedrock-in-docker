#!/bin/bash

USER_AGENT="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)"
DOWNLOADS_DIR="/downloads"
BEDROCK_DIR="/bedrock"
JSON_API_URL="https://net-secondary.web.minecraft-services.net/api/v1.0/download/links"

# check_internet: Checks if the internet connection is available by attempting to reach the JSON API
# Arguments: none
check_internet() {
  wget --quiet -U "$USER_AGENT" --timeout=30 "$JSON_API_URL" -O /dev/null
}

# download_json: Downloads the Bedrock server download JSON to a specified file
# Arguments:
#   $1 - Output file path
# Side effects: Writes to the specified output file
download_json() {
  local output_file="$1"
  wget --no-verbose -U "$USER_AGENT" --timeout=30 -O "$output_file" "$JSON_API_URL"
}

# extract_download_url: Extracts the Bedrock server Linux download URL from a given JSON file
# Arguments:
#   $1 - Path to the JSON file
# Returns: Prints the download URL to stdout
extract_download_url() {
  local json_file="$1"
  grep -o '"downloadType":"serverBedrockLinux","downloadUrl":"[^"]*"' "$json_file" | \
    sed -n 's/.*"downloadUrl":"\([^"]*\)"/\1/p'
}

# download_server: Downloads the Bedrock server zip from a URL to a specified file
# Arguments:
#   $1 - Download URL
#   $2 - Output file path
download_server() {
  local url="$1"
  local output_file="$2"
  wget --no-verbose -U "$USER_AGENT" -O "$output_file" "$url"
}

# unpack_server: Unzips the Bedrock server zip into the server directory, preserving config files if present
# Arguments:
#   $1 - Path to the zip file
# Side effects: Unzips files into $BEDROCK_DIR, sets executable permission on bedrock_server
unpack_server() {
  local zip_file="$1"
  if [ -f "$BEDROCK_DIR/server.properties" ]; then
    unzip -q -o "$zip_file" -x "*server.properties*" "*permissions.json*" "*allowlist.json*" "*whitelist.json*" -d "$BEDROCK_DIR/"
  else
    unzip -q -o "$zip_file" -d "$BEDROCK_DIR/"
  fi
  chmod a+x "$BEDROCK_DIR/bedrock_server"
}

# Test mode variables
test_mode=""

# test_print_current_version: Prints the latest Bedrock server version filename found in the JSON
# Arguments: none
# Returns: Prints the filename to stdout
test_print_current_version() {
  download_json "/tmp/version.json"
  url=$(extract_download_url "/tmp/version.json")
  # shellcheck disable=SC2001
  file=$(echo "$url" | sed "s#.*/##")
  echo "$file"
}

# test_download_and_check: Downloads the latest Bedrock server zip to /tmp and tests its integrity
# Arguments: none
# Returns: Prints result to stdout, returns 1 on failure
test_download_and_check() {
  download_json "/tmp/version.json"
  url=$(extract_download_url "/tmp/version.json")
  # shellcheck disable=SC2001
  file=$(echo "$url" | sed "s#.*/##")
  out_file="/tmp/$file"
  echo "Downloading $file to /tmp..."
  download_server "$url" "$out_file"
  echo "Testing integrity with unzip -t..."
  if unzip -t "$out_file" >/dev/null 2>&1; then
    echo "Integrity check passed."
  else
    echo "Integrity check FAILED!"
    return 1
  fi
  rm -f "$out_file"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --current-version)
      test_mode="current-version"
      shift
      ;;
    --download)
      test_mode="download"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

main() {
  if [ "$test_mode" = "current-version" ]; then
    test_print_current_version
    return
  elif [ "$test_mode" = "download" ]; then
    test_download_and_check
    return
  fi

  if ! check_internet; then
    echo "Unable to connect to update website (internet connection may be down).  Skipping update ..."
    return
  fi

  if [ "$BEDROCK_DOWNLOAD_URL" ]; then
    DownloadURL="$BEDROCK_DOWNLOAD_URL"
  else
    download_json "$DOWNLOADS_DIR/version.json"
    DownloadURL=$(extract_download_url "$DOWNLOADS_DIR/version.json")
  fi

  # shellcheck disable=SC2001
  DownloadFile=$(echo "$DownloadURL" | sed "s#.*/##")

  if [ -f "$DOWNLOADS_DIR/$DownloadFile" ]; then
    echo "Minecraft Bedrock server is up to date..."
  else
    echo "New version $DownloadFile is available.  Updating Minecraft Bedrock server ..."
    download_server "$DownloadURL" "$DOWNLOADS_DIR/$DownloadFile"
    unpack_server "$DOWNLOADS_DIR/$DownloadFile"
  fi
}

main "$@"
