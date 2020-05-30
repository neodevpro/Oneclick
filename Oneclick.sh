#!bin/bash

wget -O system.tar ftp://neodev.ddns.net/Files/Samsung/Offical/AP_G9500ZCS5DTC1_CL17975032_QB29748280_REV00_user_low_ship_MULTI_CERT_meta_OS9.tar.md5

tar -xf system.tar

unlz4 system.img.ext4.lz4

mkdir ./system

mkdir ./tempsystem

simg2img system.img.ext4 system.img

sudo mount -t ext4 -o loop system.img tempsystem/

ls -lR ./tempsystem | grep " -> " > ./fic.txt

sudo cp -rf ./tempsystem/* ./system/

sudo umount ./tempsystem

rm -rf ./tempsystem

wget -O csc.tar ftp://neodev.ddns.net/Files/Samsung/Offical/CSC_CHC_G9500CHC5DTC1_CL17975032_QB29748280_REV00_user_low_ship_MULTI_CERT.tar.md5

tar -xf csc.tar

unlz4 cache.img.ext4.lz4

simg2img cache.img.ext4 cache.img

mkdir ./cache

sudo mount -t ext4 -o loop cache.img cache/

sudo unzip ./cache/recovery/sec_csc.zip -d ./csc

sudo cp -rf ./csc/system/* ./system/

sudo umount ./cache

rm -rf ./cache

wget ftp://neodev.ddns.net/Files/Samsung/Offical/fix.zip

unzip fix.zip

cp -rf ./fix/drivers/* ./system/

cp -rf ./fix/model/9500/* ./system/

cp -rf ./fix/fstab.qcom ./system/vendor/etc

wget ftp://neodev.ddns.net/Files/Samsung/Offical/META-INF.zip

unzip META-INF.zip

mkdir ./rootzip

wget -O ./rootzip/Magsik.zip https://github.com/topjohnwu/Magisk/releases/download/v20.4/Magisk-v20.4.zip

wget -O boot.img wget ftp://neodev.ddns.net/Files/Samsung/Offical/G9500.img

zip -r -y SamsungStockRom.zip ./META-INF ./rootzip ./system boot.img


