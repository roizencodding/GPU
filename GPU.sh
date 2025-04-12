#!/bin/bash

# Check if zenity is installed, if not install it
if ! command -v zenity &> /dev/null; then
    echo "Zenity not found. Installing..."
    sudo pacman -S zenity --noconfirm
fi

# Ask for GPU type
gpu=$(zenity --list --title="What is your GPU?" --radiolist \
    --column="Select" --column="GPU" \
    FALSE "NVIDIA" FALSE "AMD" FALSE "Intel")

if [ "$gpu" == "NVIDIA" ]; then
    # Ask for NVIDIA driver type
    nvidia_driver=$(zenity --list --title="Select NVIDIA Driver" --radiolist \
        --column="Select" --column="Driver" \
        FALSE "Open Source" FALSE "Proprietary" FALSE "Nouveau (Old GPU)")
    pkexec --disable-internal-agent bash -c "echo 'Authentication successful' > /dev/null"
    if [ "$nvidia_driver" == "Open Source" ]; then
        pkexec --disable-internal-agent bash -c "pacman -S nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings lib32-opencl-nvidia opencl-nvidia libxnvctrl lib32-vulkan-icd-loader libva-nvidia-driver --noconfirm"
    fi
    if [ "$nvidia_driver" == "Proprietary" ]; then
        pkexec --disable-internal-agent bash -c "pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings lib32-opencl-nvidia opencl-nvidia libxnvctrl vulkan-icd-loader lib32-vulkan-icd-loader libva-nvidia-driver --noconfirm"
    fi
    if [ "$nvidia_driver" == "Nouveau" ]; then
        pkexec --disable-internal-agent bash -c "pacman -S mesa lib32-mesa libva-mesa-driver lib32-libva-mesa-driver vulkan-nouveau lib32-vulkan-nouveau opencl-rusticl-mesa lib32-opencl-rusticl-mesa --noconfirm"
    fi
    echo "Selected NVIDIA driver: $nvidia_driver"
elif [ "$gpu" == "AMD" ]; then
    pkexec --disable-internal-agent bash -c "pacman -S mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-mesa-layers opencl-rusticl-mesa lib32-opencl-rusticl-mesa --noconfirm"
elif [ "$gpu" == "Intel" ]; then
    pkexec --disable-internal-agent bash -c "pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel opencl-rusticl-mesa lib32-opencl-rusticl-mesa intel-media-driver libva-intel-driver lib32-libva-intel-driver --noconfirm"
else
    zenity --error --text="No GPU selected. Exiting."
    exit 1
fi

# Notify user of successful installation
zenity --info --text="Everything has been installed successfully!"