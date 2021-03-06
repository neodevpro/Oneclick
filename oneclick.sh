#!bin/bash
echo "   Welcome to use THis Tool "
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

echo -n "Checking dependencies... "
echo ""

echo "Preparing proper environment.."
sudo apt update
sudo apt install -y python-dev python3 build-essential libssl-dev libffi-dev python3-dev python3-pip simg2img liblz4-1 libxml2-dev libxslt1-dev zlib1g-dev
clear

echo "Preparing proper library.."
for pip3 in setuptools wheel progress clint simple-crypt aes click requests
do
echo ""
pip3 install $pip3
done
clear

echo -n "Checking done. "
echo ""

echo "Downloading Sam-get tool.."
wget -N --no-check-certificate https://raw.githubusercontent.com/neodevpro/sam-get/master/sam-get.zip
unzip sam-get.zip
clear
 
echo "Enter Model and Region (Example:SM-N9500 CHC): "
read model
info=$(python3 main.py checkupdate $model)
name=${model:0:8}"_"${model:9:3}"_"${info:0:13}
python3 main.py download $info $model $name.enc4
python3 main.py decrypt4 $info $model $name.enc4 $name.zip
rm -rf $name.enc4 main.py sam-get.zip samcatcher

echo "You have download the firmware successfully "
echo ""

link="https://raw.githubusercontent.com/neodevpro/Oneclick/master/"
f=".sh"

echo "Now Deploying firmware "
echo ""
basefw=${model:0:8}
gete=$link$basefw$f
cat $name.zip >> base.zip
wget -N --no-check-certificate $gete && sudo bash $basefw$f
clear

echo "You have port the rom successfully "
echo ""
echo "Samsung Odin Firmware Fame : $name.zip "
echo ""
echo "Custom Stock Rom Name : $basefw.zip "
