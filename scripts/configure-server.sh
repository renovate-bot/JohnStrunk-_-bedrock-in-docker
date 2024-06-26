#! /bin/bash

# Create a list of all environment variables starting with "MC_"
# and update the server.properties file accordingly
PROP_FILE=server.properties
echo "Updating $PROP_FILE..."
for var in "${!MC_@}"; do
    # Remove the "MC_" prefix
    name=${var:3}      # Remove the "MC_" prefix
    name=${name//_/-}  # Replace all underscores with dashes
    value=${!var}
    echo "Setting '$name' to '$value'"
    # https://stackoverflow.com/a/66949954
    if ! sed --quiet -i "s/^$name.*/$name=$value/;t1;b2;:1;h;:2;p;\${g;s/..*//;tok;q1;:ok}" "$PROP_FILE"; then
        echo "$name wasn't found in the file... adding"
        echo "$name=$value" >> "$PROP_FILE"
    fi
done
