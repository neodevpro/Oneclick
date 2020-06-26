#!bin/bash
echo "Enter Model Region (Example:SM-N9500 CHC): "
read model
info=$(python3 main.py checkupdate $model)
python3 main.py download $info $model base.enc4
python3 main.py decrypt4 $info $model base.enc4 base.zip
