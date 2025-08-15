#!/bin/bash
set -e

echo "   Welcome to use This Tool "
echo ""
echo "    Power by Neodev Team"

echo -n "Checking environment... "
echo ""

# Efficient OS detection
release=""
for file in /etc/issue /proc/version /etc/os-release; do
    if grep -Eqi "debian" "$file"; then
        release="debian"
        break
    elif grep -Eqi "ubuntu" "$file"; then
        release="ubuntu"
        break
    fi
done

if [[ -z "$release" ]]; then
    echo "==============="
    echo "Not supported"
    echo "==============="
    exit 1
fi
clear

read -p "Do you want to check the require dependencies ? It is recommned to check at first time .(y/n) " check
if [[ "$check" == "y" ]]; then
    echo -n "Checking dependencies... "
    echo ""
    echo "Preparing proper environment.." 

    packages=(
        android-sdk-libsparse-utils dh-python pkg-config python2-dev python2 python3
        build-essential libssl-dev libffi-dev python3-dev python3-pip simg2img
        liblz4-tool curl cargo unzip zip
    )

    sudo apt update -y

    # Parallel install for efficiency
    for package in "${packages[@]}"; do
        echo "Installing $package using apt..."
        sudo apt install -y "$package" &
    done
    wait

    echo "Downloading Tools.."
    cargo install --git https://github.com/FusionPlmH/frigg-update.git --force
    export PATH=/root/.cargo/bin:$PATH
else
    echo "Skip dependencies Check."
    echo ""
fi

clear

read -p "Enter Model(Example:SM-G9550): " model
read -p "Enter Region (Example:TGY): " region
read -p "Enter IMEI (Example:354763080305191): " imei
echo ""
version=$(frigg check -m "$model" -r "$region" --imei "$imei" | grep Version | cut -c 1-25 --complement)
echo "Dowloading and Decrypting firmware..."
frigg download -m "$model" -r "$region"  --imei "$imei"
name=$(find . -maxdepth 1 -name "${model}*.zip" | head -n 1)
echo "Done!.."
echo ""
clear

if [[ "$model" =~ SM-G9500|SM-G9550|SM-N9500|SM-SCV35|SM-SCV36|SM-SCV37|SM-SC02J|SM-SC03J|SM-SC01K ]]; then
    echo "Now Deploying firmware "
    echo ""
    echo "Extrating System Image... "
    echo ""
    unzip -q -o "$name" 'AP*.tar.md5' &
    wait
    tar -xf AP*.tar.md5 system.img.ext4.lz4 &
    wait
    rm -rf AP*.tar.md5

    lz4 -d -q system.img.ext4.lz4 system.img.ext4 &
    wait
    rm -rf system.img.ext4.lz4

    mkdir -p system tempsystem

    echo "Converting System Image... "
    echo ""
    simg2img system.img.ext4 system.img &
    wait
    rm -rf system.img.ext4

    echo "Mount System Image... "
    echo ""
    sudo mount -t ext4 -o loop system.img tempsystem/
    sudo cp -arf tempsystem/* system/
    sudo umount tempsystem
    rm -rf tempsystem system.img

    echo "Extrating CSC Files... "
    echo ""
    unzip -q -o "$name" 'CSC*.tar.md5' &
    wait
    tar -xf CSC*.tar.md5 cache.img.ext4.lz4 &
    wait
    rm -rf CSC*.tar.md5

    lz4 -d -q cache.img.ext4.lz4 cache.img.ext4 &
    wait
    rm -rf cache.img.ext4.lz4

    simg2img cache.img.ext4 cache.img &
    wait
    rm -rf cache.img.ext4

    mkdir -p cache csc
    sudo mount -t ext4 -o loop cache.img cache/
    unzip -q cache/recovery/sec_csc.zip -d csc &
    wait
    sudo cp -arf csc/system/* system/
    sudo umount cache
    rm -rf cache csc cache.img

    echo "Fixing the System ... "
    echo ""
    wget -q https://raw.githubusercontent.com/neodevpro/resources/master/8sbasefix.zip
    unzip -q 8sbasefix.zip &
    wait
    rm -rf 8sbasefix.zip
    sudo cp -arf 8sbasefix/system/. system/
    rm -rf 8sbasefix

    echo "Downloding Installation Scripts ... "
    echo ""
    if [[ "$model" =~ SM-G9500|SM-G9550|SM-SCV35|SM-SCV36|SM-SC02J|SM-SC03J ]]; then
        wget -q https://raw.githubusercontent.com/neodevpro/resources/master/s8sflash.zip
        unzip -q s8sflash.zip &
        wait
        rm -rf s8sflash.zip
    else
        wget -q https://raw.githubusercontent.com/neodevpro/resources/master/n8sflash.zip
        unzip -q n8sflash.zip &
        wait
        rm -rf n8sflash.zip
    fi

    echo "Downloding Magisk ... "
    echo ""
    mkdir -p rootzip system/preload/Magisk
    path=$(wget -qO- -t1 -T2 "https://api.github.com/repos/topjohnwu/Magisk/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
    sudo wget -q -O system/preload/Magisk/Magisk.apk "https://github.com/topjohnwu/Magisk/releases/download/$path/Magisk-$path.apk"

    echo "Downloding ${model:0:8} Kernel ... "
    echo ""
    if [[ "$model" =~ SM-G9500|SM-SC02J|SM-SCV36 ]]; then 
        wget -q -O boot.img https://raw.githubusercontent.com/neodevpro/resources/master/G9500.img
    elif [[ "$model" =~ SM-G9550|SM-SC03J|SM-SCV35 ]]; then 
        wget -q -O boot.img https://raw.githubusercontent.com/neodevpro/resources/master/G9550.img
    elif [[ "$model" =~ SM-N9500|SM-SC01K|SM-SCV37 ]]; then 
        wget -q -O boot.img https://raw.githubusercontent.com/neodevpro/resources/master/N9500.img
    fi

    echo "Configuring the System ... "
    echo ""
    sudo sed -i "/ro.build.display.id/d" system/build.prop
    sudo sed -i "3a\ro.build.display.id=Neo-Rom_Slim_0.4" system/build.prop
    sudo sed -i "s/ro.config.tima=1/ro.config.tima=0/g" system/build.prop
    sudo sed -i "s/ro.config.timaversion_info=Knox3.2_../ro.config.timaversion_info=0/g" system/build.prop
    sudo sed -i "s/ro.config.iccc_version=3.0/ro.config.iccc_version=iccc_disabled/g" system/build.prop
    sudo sed -i "s/ro.config.timaversion=3.0/ro.config.timaversion=0/g" system/build.prop
    sudo sed -i "s/ro.config.dmverity=A/ro.config.dmverity=false/g" system/build.prop
    sudo sed -i "s/ro.config.kap_default_on=true/ro.config.kap_default_on=false/g" system/build.prop
    sudo sed -i "s/ro.config.kap=true/ro.config.kap=false/g" system/build.prop

    wget -q https://raw.githubusercontent.com/neodevpro/resources/master/add_to_buildprop.sh
    sudo bash ./add_to_buildprop.sh
    wget -q https://raw.githubusercontent.com/neodevpro/resources/master/csc_tweaks.sh
    sudo sh ./csc_tweaks.sh
    rm -rf csc_tweaks.sh add_to_buildprop.sh
    wget -q https://raw.githubusercontent.com/neodevpro/resources/master/debloat.sh
    sudo sh ./debloat.sh

    echo "Packing the Rom ... "
    echo ""
    sudo zip -r -q -y StockMod.zip META-INF system rootzip boot.img

    sudo rm -rf META-INF system rootzip boot.img 

    echo "You have port the rom successfully " 
    echo ""
    echo ""
else
    echo "Currently Not supported Stock deploy."
    echo ""
fi

echo "All the jobs are done , please enjoy !"
echo ""
du -h *.zip
exit 0
