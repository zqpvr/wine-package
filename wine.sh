#!/bin/bash

# Define dialog height and width
DIALOG_HEIGHT=20
DIALOG_WIDTH=80

# Define options menu
OPTIONS=(1 "Install Box64 Binary"
         2 "Install Box86 Binary"
         3 "Install Wine"
         4 "Install Winetricks"
         5 "Install required packages"
         6 "Compile and Install Box64 from source"
         7 "Compile and Install Box86 from source"
         8 "Remove Box64 Binary"
         9 "Remove Box86 Binary"
         10 "Clean up downloaded files and uncompressed files"
         11 "Exit")

# Define function to install Box64 Binary
function install_box64() {
    dialog --infobox "Adding Box64 repository and installing packages..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo wget https://ryanfortner.github.io/box64-debs/box64.list -O /etc/apt/sources.list.d/box64.list
    wget -qO- https://fortner.github.io/box64-debs/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg 
    sudo apt update 
    sudo install box64-tegrax1 -y
    if [ $? -ne 0 ]; then
        dialog --msgbox "Error installing Box64 Binary. Please try again." $DIALOG_HEIGHT $DIALOG_WIDTH
    fi
}

# Define function to install Box86 Binary
function install_box86() {
    dialog --infobox "Adding Box86 repository and installing packages..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo wget https://ryanfortner.github.io/box86-debs/box86.list -O /etc/apt/sources.list.d/box86.list
    wget -qO- https://ryanfortner.github.io/box86-debs/KEY.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg 
    sudo apt update 
    sudo apt install box86-tegrax1 -y
    if [ $? -ne 0 ]; then
        dialog --msgbox "Error installing Box86 Binary. Please try again." $DIALOG_HEIGHT $DIALOG_WIDTH
    fi
}

# Define function to install Wine
function install_wine() {
    dialog --menu "Choose Wine version:" $DIALOG_HEIGHT $DIALOG_WIDTH 2 \
        1 "wine-8.8-staging-tkg" \
        2 "wine-ge-custom" 2>temp_choice

    choice=$(cat temp_choice)

    case $choice in
        1)
            dialog --infobox "Installing wine-8.8-staging-tkg..." $DIALOG_HEIGHT $DIALOG_WIDTH
            wget --show-progress -O wine-8.8-staging-tkg-amd64.tar.xz https://github.com/Kron4ek/Wine-Builds/releases/download/8.8/wine-8.8-staging-tkg-amd64.tar.xz
            tar -xf wine-8.8-staging-tkg-amd64.tar.xz # Extract Wine
            ;;
        2)
            dialog --infobox "Installing wine-ge-custom..." $DIALOG_HEIGHT $DIALOG_WIDTH
            wget --show-progress -O wine-lutris-GE-Proton8-5-x86_64.tar.xz https://github.com/GloriousEggroll/wine-ge-custom/releases/download/GE-Proton8-5/wine-lutris-GE-Proton8-5-x86_64.tar.xz
            tar -xf wine-lutris-GE-Proton8-5-x86_64.tar.xz # Extract Wine-GE custom release
            ;;
        *)
            dialog --msgbox "Invalid choice. Please try again." $DIALOG_HEIGHT $DIALOG_WIDTH
            return
            ;;
    esac

    mkdir ~/wine # Create Wine directory
    mv wine*/* ~/wine/ # Move Wine files to Wine directory
    mv lutris*/* ~/wine/ # if wine-ge-custom is downloaded do this
    sudo ln -sf ~/wine/bin/* /usr/local/bin/ # Create symbolic links for Wine binaries

    if [ $? -ne 0 ]; then
        dialog --msgbox "Error installing Wine. Please try again." $DIALOG_HEIGHT $DIALOG_WIDTH
    fi
}

# Define function to install Winetricks
function install_winetricks() {
    dialog --infobox "Installing Winetricks..." $DIALOG_HEIGHT $DIALOG_WIDTH
    wget --show-progress -O winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
    sudo chmod +x winetricks # Make Winetricks executable
    sudo mv winetricks /usr/local/bin/ # Move Winetricks to bin directory
    if [ $? -ne 0 ]; then
        dialog --msgbox "Error installing Winetricks. Please try again." $DIALOG_HEIGHT $DIALOG_WIDTH
    fi
}

# Define function to install required packages
function install_packages() {
    dialog --infobox "Installing required packages..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo apt update # Update package list
    sudo apt install -y cmake cabextract libc6:armhf libx11-6:armhf libgdk-pixbuf2.0-0:armhf \
    libgtk2.0-0:armhf libstdc++6:armhf libsdl2-2.0-0:armhf mesa-va-drivers:armhf libsdl-mixer1.2:armhf \
    libpng16-16:armhf libsdl2-net-2.0-0:armhf libopenal1:armhf libsdl2-image-2.0-0:armhf libjpeg62:armhf \
    libudev1:armhf libgl1-mesa-dev:armhf libx11-dev:armhf libsdl2-image-2.0-0:armhf libsdl2-mixer-2.0-0:armhf
    if [ $? -ne 0 ]; then
        dialog --msgbox "Error installing required packages. Please try again." $DIALOG_HEIGHT $DIALOG_WIDTH
    fi
}

# Define function to compile and install Box64 from source
function compile_install_box64() {
    dialog --infobox "Compiling Box64 from source..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo apt install zenity cmake git build-essential gcc-11 g++-11 -y
    git clone --depth=1 https://github.com/ptitSeb/box64
    cd box64
    mkdir build
    cd build
    cmake .. -DLD80BITS=1 -DNOALIGN=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_COMPILER=gcc-11
    make -j$(nproc)
    sudo make install
    if [ $? -ne 0 ]; then
        dialog --msgbox "Error compiling and installing Box64 from source. Please try again." $DIALOG_HEIGHT $DIALOG_WIDTH
    fi
}

# Define function to compile and install Box86 from source
function compile_install_box86() {
    dialog --infobox "Compiling Box86 from source..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo apt install gcc-8-arm-linux-gnueabihf -y
    git clone https://github.com/ptitSeb/box86.git
    cd box86 
    git checkout 54e13be02a 
    mkdir build 
    cd build 
    cmake .. -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc-8 -DARM_DYNAREC=ON
    make -j$(nproc)
    sudo make install
    sudo systemctl restart systemd-binfmt
    if [ $? -ne 0 ]; then
        dialog --msgbox "Error compiling and installing Box86 from source. Please try again." $DIALOG_HEIGHT $DIALOG_WIDTH
    fi
}

# Define function to remove Box64 Binary
function remove_box64() {
    dialog --infobox "Removing Box64 Binary..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo apt-get remove -y box64-tegrax1
    if [ $? -ne 0 ]; then
        dialog --msgbox "Error removing Box64 Binary. Please try again." $DIALOG_HEIGHT $DIALOG_WIDTH
    fi
}

# Define function to remove Box86 Binary
function remove_box86() {
    dialog --infobox "Removing Box86 Binary..." $DIALOG_HEIGHT $DIALOG_WIDTH
    sudo apt-get remove -y box86-tegrax1
    if [ $? -ne 0 ]; then
        dialog --msgbox "Error removing Box86 Binary. Please try again." $DIALOG_HEIGHT $DIALOG_WIDTH
    fi
}

# Define function to clean up downloaded files and uncompressed files
function clean_up() {
    dialog --infobox "Cleaning up downloaded files and uncompressed files..." $DIALOG_HEIGHT $DIALOG_WIDTH
    rm wine-*
    rm -r wine-*
    if [ $? -ne 0 ]; then
        dialog --msgbox "Error cleaning up downloaded files and uncompressed files. Please try again." $DIALOG_HEIGHT $DIALOG_WIDTH
    fi
}

# Loop through options until user exits
while true; do
    CHOICE=$(dialog --clear --title "Wine Installation Script" \
                    --menu "Choose an option:" $DIALOG_HEIGHT $DIALOG_WIDTH $DIALOG_HEIGHT \
                    "${OPTIONS[@]}" \
                    2>&1 >/dev/tty)

    # Validate user input
    if ! [[ "$CHOICE" =~ ^[0-9]+$ ]]; then
        exit 0
    fi

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
            remove_box64
            ;;
        9)
            remove_box86
            ;;
        10)
            clean_up
            ;;
        11)  
            exit 0
            ;;
    esac
done
