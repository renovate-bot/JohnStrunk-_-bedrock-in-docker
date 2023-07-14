#! /bin/bash

cat - <<EOM


======================================================================
From: https://minecraft.fandom.com/wiki/Commands

Player status
===================
allowlist <add | remove> <PlayerName>  # Add/remove player to allowlist
allowlist <on | off | list | reload>  # Enable/disable/view allowlist
op <PlayerName>                # Give operator status to player
deop <PlayerName>              # Remove operator status from player
permission <list | reload>     # List player operator permissions
kick <PlayerName> <Reason>     # Kick player off server
list                           # List players that are online

Game rules
===================
gamerule                       # Show all game rules and their values
gamerule keepInventory true    # Keep inventory upon death
gamerule pvp false             # No PvP damage
gamerule showCoordinates true  # Display player coordinates in HUD
gamerule doFireTick false      # Disable Fire spread
gamerule tntExplodes false     # Whether TNT can explode

Misceallaneous
===================
difficulty <peaceful | easy | normal | hard>  # Set difficulty level
stop                           # Stop the server

======================================================================
===    Connecting to server console... (Ctrl-a d to disconnect)    ===
======================================================================

EOM
read -rp "Press any key to continue ..."
screen -xr bedrock
