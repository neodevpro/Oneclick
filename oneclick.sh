#!bin/bash
echo "   Welcome to use This Tool "
echo ""
echo "    Power by Neodev Team"

echo -n "Checking environment... "
echo ""
if cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/os-release | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/os-release | grep -Eqi "debian"; then
    release="debian"
else
    echo "==============="
    echo "Not supported"
    echo "==============="
    exit
fi
clear

echo "Do you want to check the require dependencies ? It is recommned to check at first time .(y/n)"
read check
if [ $check = "y" ] ; then
echo -n "Checking dependencies... "
echo ""
echo "Preparing proper environment.." 

packages=(
    "android-sdk-libsparse-utils"
    "dh-python"
    "pkg-config"
    "python2-dev"
    "python2"
    "python3"
    "build-essential"
    "libssl-dev"
    "libffi-dev"
    "python3-dev"
    "python3-pip"
    "simg2img"
    "liblz4-tool"
    "curl"
    "cargo"
    "unzip"
    "zip"

)

sudo apt update

# Loop through each package and install it using apt
for package in "${packages[@]}"; do
    echo "Installing $package using apt..."
    if sudo apt install -y "$package"; then
        echo "$package installed successfully."
    else
        echo "Failed to install $package. It may not be available in the repository."
    fi
done


echo "Downloading Tools.."
cargo install --git https://github.com/FusionPlmH/frigg-update.git
export PATH=/root/.cargo/bin:$PATH
else
echo "Skip dependencies Check."
echo ""
fi

clear
 
echo "Enter Model(Example:SM-G9550): "
read model
echo "Enter Region (Example:TGY): "
read region
echo "Enter IMEI (Example:354763080305191): "
read imei
echo ""
version=$(frigg check -m $model -r $region --imei $imei | grep Version | cut -c 1-25 --complement)
echo "Dowloading and Decrypting  firmware..."
frigg download -m $model -r $region  --imei $imei
name=$(find -name "$model*.zip")
echo "Done!.."
echo ""
clear

if [[ "$model" == *"SM-G9500"* || "$model" == *"SM-G9550"* || "$model" == *"SM-N9500"* || "$model" == *"SM-SCV35"* || "$model" == *"SM-SCV36"* || "$model" == *"SM-SCV37"* || "$model" == *"SM-SC02J"* || "$model" == *"SM-SC03J"* || "$model" == *"SM-SC01K"* ]] ; then
echo "Now Deploying firmware "
echo ""
echo "Extrating System Image... "
echo ""
unzip -q -o $name AP*.tar.md5 
tar -xf AP*.tar.md5 system.img.ext4.lz4

rm -rf AP*.tar.md5 

lz4 -d -q system.img.ext4.lz4 system.img.ext4

rm -rf system.img.ext4.lz4

mkdir system

mkdir tempsystem

echo "Converting System Image... "
echo ""
simg2img system.img.ext4 system.img

rm -rf system.img.ext4

echo "Mount System Image... "
echo ""
sudo mount -t ext4 -o loop system.img tempsystem/

sudo cp -arf tempsystem/* system/

sudo umount tempsystem

rm -rf tempsystem system.img

echo "Extrating CSC Files... "
echo ""
unzip -q -o $name CSC*.tar.md5 

tar -xf CSC*.tar.md5 cache.img.ext4.lz4

rm -rf CSC*.tar.md5

lz4 -d -q cache.img.ext4.lz4 cache.img.ext4

rm -rf cache.img.ext4.lz4

simg2img cache.img.ext4 cache.img

rm -rf cache.img.ext4

mkdir cache

sudo mount -t ext4 -o loop cache.img cache/

unzip -q cache/recovery/sec_csc.zip -d csc

sudo cp -arf csc/system/* system/

sudo umount cache

rm -rf cache csc cache.img

echo "Fixing the System ... "
echo ""
wget -q https://raw.githubusercontent.com/neodevpro/resources/master/8sbasefix.zip

unzip -q 8sbasefix.zip

rm -rf 8sbasefix.zip

sudo cp -arf 8sbasefix/system/. system/

rm -rf 8sbasefix

echo "Downloding Installation Scripts ... "
echo ""
if [[ "$model" == *"SM-G9500"* || "$model" == *"SM-G9550"*  || "$model" == *"SM-SCV35"* || "$model" == *"SM-SCV36"* || "$model" == *"SM-SC02J"* || "$model" == *"SM-SC03J"* ]] ; then
wget -q https://raw.githubusercontent.com/neodevpro/resources/master/s8sflash.zip
unzip -q s8sflash.zip
rm -rf s8sflash.zip
else
wget -q https://raw.githubusercontent.com/neodevpro/resources/master/n8sflash.zip
unzip -q n8sflash.zip
rm -rf n8sflash.zip
fi

echo "Downloding Magisk ... "
echo ""


mkdir rootzip

sudo mkdir system/preload/Magisk
path=`wget -qO- -t1 -T2 "https://api.github.com/repos/topjohnwu/Magisk/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'`
sudo wget -q -O system/preload/Magisk/Magisk.apk https://github.com/topjohnwu/Magisk/releases/download/$path/Magisk-$path.apk

echo "Downloding ${model:0:8} Kernel ... "
echo ""
if [[ "$model" == *"SM-G9500"*  || "$model" == *"SM-SC02J"*  || "$model" == *"SM-SCV36"*  ]] ; then 
wget -q -O boot.img https://raw.githubusercontent.com/neodevpro/resources/master/G9500.img
elif [[ "$model" == *"SM-G9550"* || "$model" == *"SM-SC03J"*  || "$model" == *"SM-SCV35"*  ]] ; then 
wget -q -O boot.img https://raw.githubusercontent.com/neodevpro/resources/master/G9550.img
elif [[ "$model" == *"SM-N9500"* || "$model" == *"SM-SC01K"*  || "$model" == *"SM-SCV37"*  ]] ; then 
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
