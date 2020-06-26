#!bin/bash
echo "   Welcome to use THis Tool "
echo ""
echo "    Power by Neodev Team"
link="https://raw.githubusercontent.com/neodevpro/Oneclick/"
f=".sh"
d="download.sh"
getd=$link$d
wget -N --no-check-certificate $getd && bash ./download.sh
echo base=${model:3:5}
download=$link$base$f
wget -N --no-check-certificate $download && bash ./base.sh
