#!/bin/bash

# Declare constants and variables
readonly GAME_ID=1690800
readonly GAME_FOLDER="SatisfactoryDedicatedServer"
readonly GAME_PROCESS_NAME="FactoryGame"
readonly GAME_STARTUP_SCRIPT="FactoryServer.sh"
build_id=0
version_data=0
loop=1

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

while [[ $loop -eq 1 ]]; do
    pgrep -f $GAME_PROCESS_NAME
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Server Running${NC}"
            else
            echo "${RED}Server Offline...Starting Server...${NC}"
                steamcmd +force_install_dir ~/$GAME_FOLDER +login anonymous +app_update $GAME_ID validate +quit
                sleep 10
                $GAME_FOLDER/$GAME_STARTUP_SCRIPT &
            fi

    echo
    timestamp=$(date +'%m-%d-%Y %r')
    active_build_id=$(grep -o -P '.{0,0}buildid.{0,12}' "$GAME_FOLDER/steamapps/appmanifest_${GAME_ID}.acf" | tail -c 9)

    if [[ $active_build_id -ne 0 ]]; then
        build_id=0
        while [[ $build_id -eq 0 ]]; do
            version_data=$(curl -s "https://api.steamcmd.net/v1/info/${GAME_ID}")
#            echo -e "${BLUE}\n$version_data\n${NC}"
            build_id=$(echo "$version_data" | grep -o -P '.{0,0}public.{0,55}' | grep -o -P '.{0,0}buildid.{0,12}' | tail -c 9)
        done

        echo -e "Installed Version: ${GREEN}$active_build_id${NC}"
        echo -e "Public Release Version: ${GREEN}$build_id${NC}"

        if [[ $active_build_id -eq $build_id ]]; then
            echo -e "Timestamp: ${GREEN}$timestamp${NC}"
            echo -e "${GREEN}Server up-to-date...sleeping...${NC}"
        else
            echo -e "${RED}Server update needed, restarting server...${NC}"
            process=0
            process=$(pgrep -f $GAME_PROCESS_NAME)

            if [[ $process -ne 0 ]]; then
                kill -INT "$process"
            else
                echo -e "${RED}\nProcess not found. Check game process name.\n${NC}"
                loop=0
            fi

        fi

        sleep 900
    else
        echo -e "${RED}\nGame ID not found. Check game folder path.\n${NC}"
        loop=0
    fi
