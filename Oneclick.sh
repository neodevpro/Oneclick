#!bin/bash

wget -O system.tar ftp://neodev.ddns.net/Files/Samsung/Offical/AP_G9500ZCS5DTC1_CL17975032_QB29748280_REV00_user_low_ship_MULTI_CERT_meta_OS9.tar.md5

tar -xf system.tar

rm -rf ./meta-data boot.img.lz4 persist.img.ext4.lz4 recovery.img.lz4 userdata.img.ext4.lz4 system.tar

unlz4 system.img.ext4.lz4

rm -rf system.img.ext4.lz4

mkdir ./system

mkdir ./tempsystem

simg2img system.img.ext4 system.img

rm -rf system.img.ext4

sudo mount -t ext4 -o loop system.img tempsystem/

sudo cp -rf ./tempsystem/* ./system/

sudo umount ./tempsystem

rm -rf ./tempsystem system.img

wget -O csc.tar ftp://neodev.ddns.net/Files/Samsung/Offical/CSC_CHC_G9500CHC5DTC1_CL17975032_QB29748280_REV00_user_low_ship_MULTI_CERT.tar.md5

tar -xf csc.tar 

rm -rf ./meta-data DREAMQLTE_CHN_OPEN.pit csc.tar

unlz4 cache.img.ext4.lz4

rm -rf cache.img.ext4.lz4

simg2img cache.img.ext4 cache.img

rm -rf cache.img.ext4

mkdir ./cache

sudo mount -t ext4 -o loop cache.img cache/

sudo unzip ./cache/recovery/sec_csc.zip -d ./csc

sudo cp -rf ./csc/system/* ./system/

sudo umount ./cache

rm -rf ./cache ./csc cache.img

wget ftp://neodev.ddns.net/Files/Samsung/Offical/fix.zip

unzip fix.zip

rm -rf fix.zip

cp -rf ./fix/drivers/* ./system/

cp -rf ./fix/model/9500/* ./system/

cp -rf ./fix/fstab.qcom ./system/vendor/etc

rm -rf ./fix

wget ftp://neodev.ddns.net/Files/Samsung/Offical/META-INF.zip

unzip META-INF.zip

rm -rf META-INF.zip

mkdir ./rootzip

wget -O ./rootzip/Magsik.zip https://github.com/topjohnwu/Magisk/releases/download/v20.4/Magisk-v20.4.zip

wget -O boot.img wget ftp://neodev.ddns.net/Files/Samsung/Offical/G9500.img

zip -r -y SamsungStockRom.zip ./META-INF ./rootzip ./system boot.img




