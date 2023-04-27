#!/bin/bash

# Step 1: Add Box64 and Box86 repositories and install packages
echo "Step 1: Adding Box64 and Box86 repositories and installing packages..."
sudo wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg 
sudo apt update && sudo apt install box64-tegrax1 -y

sudo wget https://ryanfortner.github.io/box86-debs/box86.list -O /etc/apt/sources.list.d/box86.list
wget -qO- https://ryanfortner.github.io/box86-debs/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg 
sudo apt update && sudo apt install box86-tegrax1 -y

# Step 2: Download and install Wine and dependencies
echo "Step 2: Installing Wine and dependencies..."
wget --show-progress -O wine-8.6-amd64.tar.xz https://github.com/Kron4ek/Wine-Builds/releases/download/8.6/wine-8.6-amd64.tar.xz
tar -xf wine-8.6-amd64.tar.xz # Extract Wine
mkdir ~/wine # Create Wine directory
mv wine-8.6-amd64/* ~/wine/ # Move Wine files to Wine directory
sudo ln -sf ~/wine/bin/* /usr/local/bin/ # Create symbolic links for Wine binaries

# Step 3: Install Winetricks
echo "Step 3: Installing Winetricks..."
wget --show-progress -O winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
sudo chmod +x winetricks # Make Winetricks executable
sudo mv winetricks /usr/local/bin/ # Move Winetricks to bin directory

# Step 4: Install required packages
echo "Step 4: Installing required packages..."
sudo apt update # Update package list
sudo apt install -y cmake cabextract libc6:armhf libx11-6:armhf libgdk-pixbuf2.0-0:armhf \
libgtk2.0-0:armhf libstdc++6:armhf libsdl2-2.0-0:armhf mesa-va-drivers:armhf libsdl-mixer1.2:armhf \
libpng16-16:armhf libsdl2-net-2.0-0:armhf libopenal1:armhf libsdl2-image-2.0-0:armhf libjpeg62:armhf \
libudev1:armhf libgl1-mesa-dev:armhf libx11-dev:armhf libsdl2-image-2.0-0:armhf libsdl2-mixer-2.0-0:armhf

# Step 5: Clean up downloaded files and uncompressed files
echo "Step 5: Cleaning up downloaded files and uncompressed files..."
rm wine-8.6-amd64.tar.xz
rm -r wine-8.6-amd64
