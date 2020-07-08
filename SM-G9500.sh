#!bin/bash

unzip -o base.zip AP*.tar.md5 

tar -xf AP*.tar.md5 system.img.ext4.lz4

rm -rf AP*.tar.md5 

unlz4 system.img.ext4.lz4

rm -rf system.img.ext4.lz4

mkdir system

mkdir tempsystem

simg2img system.img.ext4 system.img

rm -rf system.img.ext4

sudo mount -t ext4 -o loop system.img tempsystem/

sudo cp -arf tempsystem/* system/

sudo umount tempsystem

rm -rf tempsystem system.img

unzip -o base.zip CSC*.tar.md5 

tar -xf CSC*.tar.md5 cache.img.ext4.lz4

rm -rf CSC*.tar.md5

unlz4 cache.img.ext4.lz4

rm -rf cache.img.ext4.lz4

simg2img cache.img.ext4 cache.img

rm -rf cache.img.ext4

mkdir cache

sudo mount -t ext4 -o loop cache.img cache/

sudo unzip cache/recovery/sec_csc.zip -d csc

sudo cp -arf csc/system/* system/

sudo umount cache

rm -rf cache csc cache.img

wget https://raw.githubusercontent.com/neodevpro/resources/master/8sbasefix.zip

unzip 8sbasefix.zip

rm -rf 8sbasefix.zip

sudo cp -arf 8sbasefix/system/. system/

mkdir data

sudo cp -arf 8sbasefix/data/. data/

sudo cp -arf 8sbasefix/fstab.qcom system/vendor/etc

rm -rf 8sbasefix

wget https://raw.githubusercontent.com/neodevpro/resources/master/s8sflash.zip

unzip s8sflash.zip

rm -rf s8sflash.zip

mkdir rootzip

wget -O rootzip/Magisk.zip https://github.com/topjohnwu/Magisk/releases/download/v20.4/Magisk-v20.4.zip

unzip -o rootzip/Magisk.zip common/magisk.apk
mkdir system/app/MagiskManager
sudo cp -arf common/magisk.apk ./system/app/MagiskManager
rm -rf common

wget -O boot.img https://raw.githubusercontent.com/neodevpro/resources/master/G9500.img

sed -i "s/ro.config.tima=1/ro.config.tima=0/g" system/build.prop
sed -i "s/ro.config.timaversion_info=Knox3.2_../ro.config.timaversion_info=0/g" system/build.prop
sed -i "s/ro.config.iccc_version=3.0/ro.config.iccc_version=iccc_disabled/g" system/build.prop
sed -i "s/ro.config.timaversion=3.0/ro.config.timaversion=0/g" system/build.prop

sed -i "s/ro.config.dmverity=A/ro.config.dmverity=false/g" system/build.prop
sed -i "s/ro.config.kap_default_on=true/ro.config.kap_default_on=false/g" system/build.prop
sed -i "s/ro.config.kap=true/ro.config.kap=false/g" system/build.prop

wget https://raw.githubusercontent.com/neodevpro/resources/master/add_to_buildprop.sh

sudo bash ./add_to_buildprop.sh

wget https://raw.githubusercontent.com/neodevpro/resources/master/csc_tweaks.sh

sudo sh ./csc_tweaks.sh

rm -rf csc_tweaks.sh add_to_buildprop.sh

rm -rf system/recovery-from-boot.p
rm -rf system/app/BBCAgent
rm -rf system/app/KnoxAttestationAgent
rm -rf system/app/MDMApp
rm -rf system/app/SecurityLogAgent
rm -rf system/app/SecurityProviderSEC
rm -rf system/app/UniversalMDMClient
rm -rf system/container
rm -rf system/etc/permissions/knoxsdk_edm.xml
rm -rf system/etc/permissions/knoxsdk_mdm.xml
rm -rf system/etc/recovery-resource.dat
rm -rf system/priv-app/DiagMonAgent
rm -rf system/priv-app/KLMSAgent
rm -rf system/priv-app/KnoxCore
rm -rf system/priv-app/knoxvpnproxyhandler
rm -rf system/priv-app/Rlc
rm -rf system/priv-app/SamsungPayStub
rm -rf system/priv-app/SecureFolder
rm -rf system/priv-app/SPDClient
rm -rf system/priv-app/TeeService

rm -rf system/lib/libvkservice
rm -rf system/lib64/libvkservice

rm -rf system/lib/libvkjni
rm -rf system/lib64/libvkjni

rm -rf system/etc/init/bootchecker.rc
rm -rf system/secure_storage_daemon_system.rc

rm -rf system/lib/liboemcrypto

sudo cp -arf system/preload/GoogleCalendarSyncAdapter ./system/app
sudo cp -arf system/preload/GoogleContactsSyncAdapter ./system/app
sudo cp -arf system/preload/MateAgent ./system/app
sudo cp -arf system/preload/MtpShareApp ./system/app
sudo cp -arf system/preload/ScreenRecorder ./system/app
sudo cp -arf system/preload/Weather_SEP10.1 ./system/app
sudo cp -arf system/preload/WechatPluginMiniApp ./system/app

rm -rf system/preload
rm -rf system/preloadFotaOnly

zip -r -y SM-G9500.zip META-INF rootzip system boot.img data

sudo rm -rf data META-INF base.zip rootzip boot.img system




