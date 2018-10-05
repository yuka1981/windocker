#/bin/bash

ServerIP=$1
ImageName=$2
UserID=$3
Threshold=$4
ScanDate=`date +%Y%m%d-%H%M%S`
JsonFilePath=`pwd`
ScanResultFile=$JsonFilePath/$UserID-$ScanDate.json
ClairScanner=`which clair-scanner`


## Functions Section
GrepResult() {
  local ResultFile=$1
  local Threshold=$2
  local Serverity=`grep $Threshold $ResultFile | wc -l`
  return $Serverity
}


## Main Program Section

# chekc number of parameter
[ "$#" -lt 4 ] && echo "The number of parameter is less than 4.  Stop here." && exit

# pull images from registry & scan image
[ ! -e `which clair-scanner` ] && echo "No clair-scanner found" && exit 
docker pull $ImageName && $ClairScanner --ip $ServerIP -r $JsonFilePath/$UserID-$ScanDate.json $ImageName 1>/dev/null

# check report & return serverity
if [ -e $ScanResultFile ]; then
    GrepResult $ScanResultFile $Threshold
    echo "{ \"Serverity\": \"$?\" }" >  $JsonFilePath/$UserID-$ScanDate-Serverity.json
    docker rmi $ImageName
else
    echo "No Such Scan Report" && exit
fi
