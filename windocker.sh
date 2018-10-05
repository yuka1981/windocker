#/bin/bash

#ServerIP=$1
ServerIP="localhost"
ImageName=$1
#UserID=$2
ScanID=$2
ServerityThreshold=("High" "Medium" "Low")
ScanDate=`date +%Y%m%d-%H%M%S`
JsonFilePath=`pwd`
#OutputFileName=$UserID-$ScanID-$ScanDate
OutputFileName=$ScanID
ScanResultFile=$JsonFilePath/$OutputFileName.json
ServerityFile=$JsonFilePath/$OutputFileName-Serverity.json
ClairScanner=`which clair-scanner`


## Main Program Section

# chekc number of parameter
[ "$#" -lt 2 ] && echo "The number of parameter is less than 4.  Stop here." && exit

# pull images from registry & scan image
[ ! -e `which clair-scanner` ] && echo "No clair-scanner found" && exit 
docker pull $ImageName && $ClairScanner --ip $ServerIP -r $ScanResultFile $ImageName 1>/dev/null

# check report & return serverity
if [ -e $ScanResultFile ]; then
    
    Count=${#ServerityThreshold[@]}

    # 這段之後不產生檔案，直接把資料塞到 api 
    for (( i=0 ; i < $Count ; i++ ))
    do 
      # 取得各 Threshold 的 Serverity 數量
      Serverity=`grep ${ServerityThreshold[i]} $ScanResultFile | wc -l | awk '{print $1}'`
      
      # 產生 Json 格式
      [ $i -eq 0 ] && echo "{" > $ServerityFile  
      if [ $i -ne $((Count-1)) ]; then
        echo " \"${ServerityThreshold[i]}\" : \"$Serverity\", " >> $ServerityFile
      else
        echo " \"${ServerityThreshold[i]}\" : \"$Serverity\" " >> $ServerityFile
      fi      
      [ $i -eq $((Count-1)) ] && echo "}" >> $ServerityFile
    
    done

    docker rmi $ImageName
else
    echo "No Such Scan Report" && exit
fi
