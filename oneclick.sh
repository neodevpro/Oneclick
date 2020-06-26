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
base=${model:3:5}
gete=$link$base$f
wget -N --no-check-certificate $gete && bash ./base.sh
