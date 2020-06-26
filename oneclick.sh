#!bin/bash
echo "   Welcome to use THis Tool "
echo ""
echo "    Power by Neodev Team"

link="https://raw.githubusercontent.com/neodevpro/Oneclick/master/"
sc="samcatcher.zip"
f=".sh"
d="download.sh"
getc=$link$sc
getd=$link$d

wget $getc
unzip *.zip
wget -N --no-check-certificate $getd && bash ./download.sh

echo "Enter Model Region (Example:SM-N9500 CHC): "
read model
info=$(python3 main.py checkupdate $model)
python3 main.py download $info $model base.enc4
python3 main.py decrypt4 $info $model base.enc4 base.zip

base=${model:3:5}
gete=$link$base$f
wget -N --no-check-certificate $gete && bash $base$f.sh
