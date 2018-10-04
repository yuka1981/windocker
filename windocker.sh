#/bin/bash

ServerIP=$1
ImageName=$2
UserID=$3
ScanDate=`date +%Y%m%d-%H%M%S`

clair-scanner --ip $ServerIP -r $UserID-$ScanDate.json $ImageName
