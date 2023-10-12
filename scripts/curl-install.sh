#!/bin/bash

# Checking if is running in Repo Folder
if [[ "$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')" =~ ^scripts$ ]]; then
    echo "You are running this in ArchRodey Folder."
    echo "Please use ./archrodey.sh instead"
    exit
fi

# Installing git

echo "Installing git."
pacman -Sy --noconfirm --needed git glibc

echo "Cloning the ArchRodey Project"
git clone https://github.com/rodeyseijkens/ArchRodey ArchRodey

echo "Executing ArchRodey Script"

cd $HOME/ArchRodey

exec ./archrodey.sh
