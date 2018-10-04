#/bin/bash

ServerIP=$1
ImageName=$2
UserID=$3
Threshold=$4
ScanDate=`date +%Y%m%d-%H%M%S`
JsonFilePath=`pwd`
ScanResultFile=$JsonFilePath/$UserID-$ScanDate.json

## Functions Section
GrepResult() {
  local ResultFile=$1
  local Threshold=$2
  local Serverity=`grep $Threshold $ResultFile | wc -l`
  return $Serverity
}


## Main Program Section

# chekc number of parameter
[ "$#" -lt 4 ] && echo "The number of parameter is less than 3.  Stop here." && exit 0

# pull images from registry & scan image
docker pull $ImageName && clair-scanner --ip $ServerIP -r $JsonFilePath/$UserID-$ScanDate.json $ImageName 1>/dev/null

# check report & return serverity
if [ -e $ScanResultFile ]; then
    GrepResult $ScanResultFile $Threshold
    Serverity=$?
    docker rmi $ImageName
    exit $Serverity
else
    echo "No Such Scan Report"
fi


