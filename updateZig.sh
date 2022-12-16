#/bin/bash

TempPath="./tmp"
arch="x86_64-linux"

# Don't write space when set value in shell
ZipUrl="NoUrlFound"
Cversion=`zig version`
echo "Current Zig Version: "$Cversion
curl https://ziglang.org/download/index.json > index.json


if [ ! -f ./index.json ]
then
    echo "Zig offcial Json File Download Filed, Please Retry."
    exit
else 
    echo "Zig offcial Json File Download Successful, Start Parse VersionInfo."
fi



ZipUrl=`cat ./index.json | jq ' .master | ."'$arch'" | .tarball ' | tr -d '"'`
echo $ZipUrl

if [ ! ${#ZipUrl} -gt 5 ]
then
    echo "Url: "$ZipUrl 
    echo "Parse Download Url Failed"
    exit
fi

# GetFileName 
FileName="NotFound"
FileName=`echo "${ZipUrl##*/}"`
NewVersion=`echo $FileName | grep -E '[0-9]\.[0-9]{2}\.[0-9][\^-]([a-z]+)\.([0-9a-z\+]+)' -o`
echo "FindFileName: "$FileName" NewVersion: $NewVersion CurrentVersion: "$Cversion
if [ $NewVersion = $Cversion ]
then
    echo "SameVersion with Zig offical server, ignore update"
    exit
fi

# Downloadile
echo "Start to Download New Version of Zig"
if [ "$(curl -L -w '%{http_code}' $ZipUrl -o $FileName )" = "200" ]; 
then
    echo "Download Success"
else
    echo "Download Failed, Restart this scirpt may fix this problem."
    exit
fi


# UnCompress
mkdir -p $TempPath
tar -xf $FileName -C $TempPath --strip-components 1

echo "UnCompress Finished, Start to Delete and Update Zig to: $FileName "
# Delele the old Version

# This line will clean the directory but only zig and zls will leave .
# Know & Use
# ls | grep -v 'zls\|tmp\|updateZig.sh' | xargs rm -rf


rm -rf ./doc
rm -rf ./lib
rm ./zig

cp -r ./tmp/* ./
mv $FileName ./tmp
mv index.json ./tmp
# Clean

rm -rf ./tmp

echo "Update Zig finished!"
