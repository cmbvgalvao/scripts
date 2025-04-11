#!/bin/bash

for dir in /home/*/; do
    user=$(basename "$dir")
    if [ "$user" != "$USER" ]; then
        sudo cp .gitconfig "/home/$user/.gitconfig"
    fi
done

