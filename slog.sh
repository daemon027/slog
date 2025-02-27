#!/bin/bash
#set -e
. ./utils.sh

if [ $# -lt 1 ];then
  usage
  exit 0
fi

CLUSTER_NAME=k8s-test
NAMESPACE=ns00
SVC_NAME=svc01
TIME_RANGE="5 mins ago"
KEY_WORDS=""
BEFORE=3
AFTER=2

while getopts "c:n:s:t:k:a:b:h" arg
do
  case $arg in
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    n)
      NAMESPACE="$OPTARG"
      ;;
    s)
      SVC_NAME="$OPTARG"
      ;;
    t)
      TIME_RANGE="$OPTARG"
      ;;
    k)
      KEY_WORDS="$OPTARG"
      ;;
    a)
      AFTER="$OPTARG"
      ;;
    b)
      BEFORE="$OPTARG"
      ;;
    h)
      usage
      exit 0
      ;;
    ?)
      usage
      exit 0
      ;;
  esac 
done

KEY_WORDS=`trim_str "$KEY_WORDS"`
BEGIN_TIME=`echo "$TIME_RANGE"|awk -F"~" '{ print $1 }'`
END_TIME=`echo "$TIME_RANGE"|awk -F"~" '{ print $2 }'`

BASE_DIR="/logs/$CLUSTER_NAME/$NAMESPACE"

BEGIN_TIME=`trim_str "$BEGIN_TIME"`
END_TIME=`trim_str "$END_TIME"`

SGREP="grep --color=always -A $AFTER -B $BEFORE -i -E "

if [[ "$BEGIN_TIME" =~ "sec" ]] || [[ "$BEGIN_TIME" =~ "min" ]] || [[ "$BEGIN_TIME" =~ "hour" ]] || [[ "$BEGIN_TIME" =~ "day" ]];then
  if [ -z "$END_TIME" ];then
    END_TIME=`date '+%Y-%m-%d %H:%M:%S'`
  fi
fi

if [ -n "$END_TIME" ];then  
  END_TIME=`date '+%Y-%m-%d %H:%M:%S' -d "$END_TIME"`
fi

CROSS_DAYS=1
IS_RANGE=0
if [ -n "$END_TIME" ];then
  BEGIN_SECONDS=`date '+%s' -d "$BEGIN_TIME"`
  END_SECONDS=`date '+%s' -d "$END_TIME"`
  if [ $END_SECONDS -lt $BEGIN_SECONDS ];then
    echo "[ERROR] time range: end time is earlier than begin time"
    exit -1
  fi
  TS_DIFF=`date '+%s' -d "1970-01-01 00:00:00"`
  TS_DIFF=$((0-TS_DIFF))
  B_DAY=$(((BEGIN_SECONDS+TS_DIFF)/(3600*24)))
  E_DAY=$(((END_SECONDS+TS_DIFF)/(3600*24)))
  CROSS_DAYS=$((E_DAY-B_DAY+1))
  IS_RANGE=1
fi

if [ $IS_RANGE -eq 1 ];then
  #DAY_STR=`date '+%Y-%m-%d' -d "$END_TIME"`
  if [ $CROSS_DAYS -eq 1 ];then
    search_range_words "$BEGIN_TIME" "$END_TIME"
  else
    BEGIN_DAY=`date '+%Y-%m-%d' -d "$BEGIN_TIME"`
    search_range_words "$BEGIN_TIME" "$BEGIN_DAY 23:59:59"
    i=2
    j=1
    while [ $i -lt $CROSS_DAYS ]
    do
      DAY_STR=`date '+%Y-%m-%d' -d "$END_TIME $j days ago"`
      #echo "[DEBUG] $DAY_STR $HOUR_STR"
      search_words "$DAY_STR"
      i=$((i+1))
      j=$((j+1))
    done
    END_DAY=`date '+%Y-%m-%d' -d "$END_TIME"`
    search_range_words "$END_DAY 00:00:00" "$END_TIME"
  fi
else
  search_words "$BEGIN_TIME"
fi
