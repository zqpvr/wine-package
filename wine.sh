#!/bin/bash

# Define dialog height and width
DIALOG_HEIGHT=20
DIALOG_WIDTH=80

# Define options menu
OPTIONS=(1 "Install Box64 Binary"
         2 "Install Box86 Binary"
         3 "Install Wine and dependencies"
         4 "Install Winetricks"
         5 "Install required packages"
         6 "Compile and Install Box64 from source"
         7 "Compile and Install Box86 from source"
         8 "Clean up downloaded files and uncompressed files"
         9 "Exit")

# Define function to install Box64 Binary
function install_box64() {
    dialog --infobox "Adding Box64 repository and installing packages..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
    wget -qO- https://ryanfortner.github.io/box64-debs/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg 
    sudo apt update && sudo apt install box64-tegrax1 -y
}

# Define function to install Box86 Binary
function install_box86() {
    dialog --infobox "Adding Box86 repository and installing packages..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo wget https://ryanfortner.github.io/box86-debs/box86.list -O /etc/apt/sources.list.d/box86.list
    wget -qO- https://ryanfortner.github.io/box86-debs/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg 
    sudo apt update && sudo apt install box86-tegrax1 -y
}

# Define function to install Wine and dependencies
function install_wine() {
    dialog --infobox "Installing Wine and dependencies..." $DIALOG_HEIGHT $DIALOG_WIDTH
    wget --show-progress -O wine-8.6-amd64.tar.xz https://github.com/Kron4ek/Wine-Builds/releases/download/8.6/wine-8.6-amd64.tar.xz
    tar -xf wine-8.6-amd64.tar.xz # Extract Wine
    mkdir ~/wine # Create Wine directory
    mv wine-8.6-amd64/* ~/wine/ # Move Wine files to Wine directory
    sudo ln -sf ~/wine/bin/* /usr/local/bin/ # Create symbolic links for Wine binaries
}

# Define function to install Winetricks
function install_winetricks() {
    dialog --infobox "Installing Winetricks..." $DIALOG_HEIGHT $DIALOG_WIDTH
    wget --show-progress -O winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    sudo chmod +x winetricks # Make Winetricks executable
    sudo mv winetricks /usr/local/bin/ # Move Winetricks to bin directory
}

# Define function to install required packages
function install_packages() {
    dialog --infobox "Installing required packages..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo apt update # Update package list
    sudo apt install -y cmake cabextract libc6:armhf libx11-6:armhf libgdk-pixbuf2.0-0:armhf \
    libgtk2.0-0:armhf libstdc++6:armhf libsdl2-2.0-0:armhf mesa-va-drivers:armhf libsdl-mixer1.2:armhf \
    libpng16-16:armhf libsdl2-net-2.0-0:armhf libopenal1:armhf libsdl2-image-2.0-0:armhf libjpeg62:armhf \
    libudev1:armhf libgl1-mesa-dev:armhf libx11-dev:armhf libsdl2-image-2.0-0:armhf libsdl2-mixer-2.0-0:armhf
}

# Define function to compile and install Box64 from source
function compile_install_box64() {
    dialog --infobox "Compiling Box64 from source..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo apt install zenity cmake git build-essential gcc-11 g++-11 -y || error "Could not install dependencies"
    git clone --depth=1 https://github.com/ptitSeb/box64
    cd box64
    mkdir build
    cd build
    cmake .. -DLD80BITS=1 -DNOALIGN=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_COMPILER=gcc-11
    echo "Building Box64"
}

# Define function to compile and install Box86 from source
function compile_install_box86() {
    dialog --infobox "Compiling Box86 from source..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo apt install gcc-8-arm-linux-gnueabihf -y || error "Could not install dependencies"
    git clone https://github.com/ptitSeb/box86.git 
    cd box86 
    mkdir build 
    cd build 
    cmake .. -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc-8 -DARM_DYNAREC=ON
    echo "Building Box86"
    make -j$(nproc)
    echo "Still Building Box86"
    sudo make install
    sudo systemctl restart systemd-binfmt
}

# Define function to clean up downloaded files and uncompressed files
function clean_up() {
    dialog --infobox "Cleaning up downloaded files and uncompressed files..." $DIALOG_HEIGHT $DIALOG_WIDTH
    rm wine-8.6-amd64.tar.xz
    rm -r wine-8.6-amd64
}

# Loop through options until user exits
while true; do
    CHOICE=$(dialog --clear --title "Wine Installation Script" \
                    --menu "Choose an option:" $DIALOG_HEIGHT $DIALOG_WIDTH $DIALOG_HEIGHT \
                    "${OPTIONS[@]}" \
                    2>&1 >/dev/tty)

    case $CHOICE in
        1)
            install_box64
            ;;
        2)
            install_box86
            ;;
        3)
            install_wine
            ;;
        4)
            install_winetricks
            ;;
        5)
            install_packages
            ;;
        6)  
            compile_install_box64
            ;;
        7)  
            compile_install_box86
            ;;
        8)
            clean_up
            ;;
        9)  
            exit 0
            ;;
    esac
done
