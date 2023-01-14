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
apt update
apt install -y python-dev python3 build-essential libssl-dev libffi-dev python3-dev python3-pip simg2img liblz4-tool curl
clear
echo "Downloading Samloader.."
pip3 install git+https://github.com/samloader/samloader.git
else
echo "Skip dependencies Check."
echo ""
fi

clear
 
echo "Enter Model(Example:SM-G9550): "
read model
echo "Enter Region (Example:CHC): "
read region
echo ""
check=$(samloader -m $model -r $region checkupdate)
echo "Dowloading firmware..."
samloader -m $model -r $region download -v $check -O .
input=$(find -name "$model*.zip.enc4" | tee log)
cat log > tmpf
sed -i 's/.enc4//' tmpf
name=$(cat tmpf)
echo ""
echo "Decrypting firmware..."
samloader -m $model -r $region decrypt -v $check -V 4 -i $input -o $name
echo "Done!.."
echo ""

echo ""
rm -rf log tmpf $input
echo "You have download the firmware successfully "
echo ""
clear

if [[ "$model" == *"SM-G9500"* || "$model" == *"SM-G9550"* || "$model" == *"SM-N9500"* ]] ; then
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

cp -arf 8sbasefix/system/. system/

rm -rf 8sbasefix

echo "Downloding Installation Scripts ... "
echo ""
if [[ "$model" == *"SM-G9500"* || "$model" == *"SM-G9550"* ]] ; then
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

mkdir system/preload/Magisk
path=`wget -qO- -t1 -T2 "https://api.github.com/repos/topjohnwu/Magisk/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'`
wget -q -O system/preload/Magisk/Magisk.apk https://github.com/topjohnwu/Magisk/releases/download/$path/Magisk-$path.apk

echo "Downloding ${model:0:8} Kernel ... "
echo ""
if [[ "$model" == *"SM-G9500"* ]] ; then 
wget -q -O boot.img https://raw.githubusercontent.com/neodevpro/resources/master/G9500.img
elif [[ "$model" == *"SM-G9550"* ]] ; then 
wget -q -O boot.img https://raw.githubusercontent.com/neodevpro/resources/master/G9550.img
elif [[ "$model" == *"SM-N9500"* ]] ; then 
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

bash ./add_to_buildprop.sh

wget -q https://raw.githubusercontent.com/neodevpro/resources/master/csc_tweaks.sh

sh ./csc_tweaks.sh

rm -rf csc_tweaks.sh add_to_buildprop.sh

rm -rf system/recovery-from-boot.p
rm -rf system/app/BBCAgent
rm -rf system/app/KnoxAttestationAgent
rm -rf system/app/MDMApp
rm -rf system/app/SecurityLogAgent
rm -rf system/app/SecurityProviderSEC
rm -rf system/app/UniversalMDMClient
rm -rf system/priv-app/ContainerAgent*
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




rm -rf system/preload/Excel_SamsungStub
rm -rf system/preload/Gear360Editor_Beyond
rm -rf system/preload/LinkedIn_SamsungStub
rm -rf system/preload/PowerPoint_SamsungStub
rm -rf system/preload/SamsungVideo
rm -rf system/preload/SAssistant_downloadable
rm -rf system/preload/Word_SamsungStub
rm -rf system/preload/StoryEditor_Dream_N
rm -rf system/preload/SlowMotionVideoEditor
rm -rf system/preload/SmartSwitch
rm -rf system/preload/SmartSwitchAgent
rm -rf system/preload/CocktailQuickTool
rm -rf system/preload/SamsungMagnifier3
rm -rf system/preload/SearchWidgetAPP
rm -rf system/preload/SPdfNote
rm -rf system/preload/VideoTrimmer
rm -rf system/preload/VideoEditorLite_Dream_N
rm -rf system/preload/NaverV_N
rm -rf system/preload/HongbaoAssistant
rm -rf system/preload/MateAgent
rm -rf system/preload/LedCoverAppDream
rm -rf system/preload/SamsungCloudClient
rm -rf system/preload/SecEmail_P
rm -rf system/preload/VisionIntelligence2_stub
rm -rf system/preload/WechatPluginMiniApp
rm -rf system/preloadFotaOnly
rm -rf system/preload/LinkSharing*
rm -rf system/app/ChinaUnionPay
rm -rf system/app/PDFViewer
rm -rf system/app/ClipboardEdge
rm -rf system/app/CocktailQuickTool
rm -rf system/app/Facebook_stub
rm -rf system/app/GearManagerStub
rm -rf system/app/MSSkype_stub
rm -rf system/app/PlayAutoInstallConfig
rm -rf system/app/SBrowserEdge
rm -rf system/app/SlowMotionVideoEditor
rm -rf system/app/StoryEditor_Dream_N
rm -rf system/app/VideoTrimmer
rm -rf system/app/VisionIntelligence2_stub
rm -rf system/app/WebManual
rm -rf system/app/Yahoo*
rm -rf system/app/YouTube
rm -rf system/app/CarmodeStub
rm -rf system/app/EasterEgg
rm -rf system/app/EasymodeContactsWidget81
rm -rf system/app/FBAppManager_NS
rm -rf system/app/FlipboardBriefing
rm -rf system/app/InteractivePanoramaViewer_WQHD
rm -rf system/app/KidsHome_Installer
rm -rf system/app/Maps
rm -rf system/app/MirrorLink
rm -rf system/app/Panorama360Viewer
rm -rf system/app/SmartSwitchAgent
rm -rf system/app/SmartReminder
rm -rf system/app/PreloadAppDownload
rm -rf system/app/Gmail2
rm -rf system/app/MotionPanoramaViewer
rm -rf system/app/SelfMotionPanoramaViewer
rm -rf system/app/WebViewStub
rm -rf system/app/VideoEditorLite_Dream_N
rm -rf system/app/Kaiti
rm -rf system/app/Miao
rm -rf system/app/ShaoNv
rm -rf system/app/EasyOneHand3
rm -rf system/app/ARCore
rm -rf system/app/GoogleVrServices
rm -rf system/app/SmartMirroring
rm -rf system/app/LinkSharing*
rm -rf system/priv-app/LinkSharing*
rm -rf system/priv-app/HybridRadio_P
rm -rf system/priv-app/AlipayService
rm -rf system/priv-app/AppsEdgePanel_v3.2
rm -rf system/priv-app/Excel_SamsungStub
rm -rf system/priv-app/FBInstaller_NS
rm -rf system/priv-app/FBServices
rm -rf system/priv-app/Finder
rm -rf system/priv-app/FotaAgent
rm -rf system/priv-app/GalaxyAppsWidget_Phone_Dream
rm -rf system/priv-app/Gear360Editor_Beyond
rm -rf system/priv-app/OneDrive_Samsung_v3
rm -rf system/priv-app/PowerPoint_SamsungStub
rm -rf system/priv-app/TaskEdgePanel_v3.2
rm -rf system/priv-app/Velvet
rm -rf system/priv-app/Word_SamsungStub
rm -rf system/priv-app/GearVRService
rm -rf system/priv-app/GoogleDaydreamCustomization
rm -rf system/priv-app/LinkedIn_SamsungStub
rm -rf system/priv-app/BixbyHome
rm -rf system/priv-app/HotwordEnrollment*
rm -rf system/priv-app/AuthFramework
rm -rf system/priv-app/BeaconManager
rm -rf system/priv-app/Bixby
rm -rf system/priv-app/BixbyAgentStub
rm -rf system/priv-app/BixbyService
rm -rf system/priv-app/BixbyWakeup
rm -rf system/priv-app/EasySetup
rm -rf system/priv-app/knoxanalyticsagent
rm -rf system/priv-app/LedCoverAppDream
rm -rf system/priv-app/LedCoverService
rm -rf system/priv-app/ManagedProvisioning
rm -rf system/priv-app/MateAgent
rm -rf system/priv-app/PaymentFramework
rm -rf system/priv-app/PeopleStripe
rm -rf system/priv-app/SamsungCloudClient
rm -rf system/priv-app/SamsungBilling
rm -rf system/priv-app/SamsungMagnifier3
rm -rf system/priv-app/SendHelpMessage
rm -rf system/priv-app/SVoicePLM
rm -rf system/priv-app/SettingsBixby
rm -rf system/priv-app/SystemUIBixby2
rm -rf system/priv-app/CocktailBarService_v3.2
rm -rf system/priv-app/SetupWizard
rm -rf system/priv-app/GoogleRestore
rm -rf system/priv-app/BixbyHome_Disable
rm -rf system/priv-app/DynamicLockscreen
rm -rf system/priv-app/SamsungCloudEnabler
rm -rf system/priv-app/SmartEpdgTestApp
rm -rf system/priv-app/SVoiceIME

rm -rf system/priv-app/StickerCenter
rm -rf system/priv-app/StickerFaceAR
rm -rf system/priv-app/StickerWatermark


echo "Packing the Rom ... "
echo ""
zip -r -q -y StockMod.zip META-INF system rootzip boot.img

rm -rf META-INF system rootzip boot.img 

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
