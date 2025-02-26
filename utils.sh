#!/bin/bash
#set -e

usage() {
  echo '
   USAGE:
   -c CLUSTER_NAME, default is "k8s-test"
   -n NAMESPACE, default is "test"
   -s SVC_NAME, default is "hello"
   -t TIME_RANGE, time range such as "t1 ~ t2" or specific time such as "t1"
      default is "now - 5mins ~ now" (the same as "5 mins ago")
      use relative time "XX mins/hours ago"
      use absolute time "YYYY-MM-DD HH:mm:ss"
   -k KEY_WORDS, default is "", print all in the time range
   -b BEFORE, print lines before keyword match, default is "0"
   -a AFTER, print lines after keyword match, default is "0"

  Example:
  slog.sh -t "1 hour ago" -k "hi"

 ' 
}

trim_str() {
  str=`echo "$1"|awk '{$1=$1; print}'` 
  echo "$str"
}

get_match_line_num() {
  TS_STR="$1"
  LOOP=3
  LINE_NUM=-1
  #get the first match line num
  if [ $3 -eq 0 ];then
    i=0
    while [ $i -lt $LOOP ]
    do
      FIRST_MATCH_LINE=`grep -n -m 1 "$TS_STR" $2|cut -d: -f1`
      if [ -z "$FIRST_MATCH_LINE" ];then
        TS_STR="${TS_STR%:*}:"
        i=$((i+1))
      else
        LINE_NUM=$FIRST_MATCH_LINE
        i=3
      fi
    done
  #get the last match line num
  else
    i=0
    while [ $i -lt $LOOP ]
    do
      LAST_MATCH_LINE=`grep -n "$TS_STR" $f|tail -1|cut -d: -f1`
      if [ -z "$LAST_MATCH_LINE" ];then
        TS_STR="${TS_STR%:*}:"
        i=$((i+1))
      else
        LINE_NUM=$LAST_MATCH_LINE
        i=3
      fi
    done
  fi
  echo $LINE_NUM
}

search_words() {
  DAY_STR=`date '+%Y-%m-%d' -d "$1"`
  HOUR_STR=`echo "$1"|awk -F" " '{ print $2 }'`
  HOUR_STR=`trim_str "$HOUR_STR"`
  for f in `ls $BASE_DIR/$SVC_NAME/$DAY_STR/*`
  do
    echo -e "\033[42m$f\033[0m"
    if [ -n "$HOUR_STR" ];then
      TS=$HOUR_STR
      if [ ${HOUR_STR:(-1)} != ":" ];then
        COLON_COUNT=`echo "$HOUR_STR"|grep -o ":"|wc -l`
        if [ $COLON_COUNT -lt 2 ];then
          TS="${HOUR_STR}:"
        fi
      fi
      # full ts string for exact match
      grep "$DAY_STR $TS" $f|$SGREP "$KEY_WORDS"
    else
      $SGREP "$KEY_WORDS" $f
    fi
  done
}

search_range_words() {
  DAY_STR=`date '+%Y-%m-%d' -d "$1"`
  HOUR_STR=`date '+%H:%M:%S' -d "$1"`
  LAST_MATCH_LINE=-1
  for f in `ls $BASE_DIR/$SVC_NAME/$DAY_STR/*`
  do
    echo -e "\033[42m$f\033[0m"
    #FIRST_MATCH_LINE=`grep -n -m 1 "$HOUR_STR" $f|cut -d: -f1`
    FIRST_MATCH_LINE=`get_match_line_num "$DAY_STR $HOUR_STR" $f 0`
    if [ $FIRST_MATCH_LINE -eq -1 ];then
      #FIRST_MATCH_LINE=1
      continue
    fi
    if [ -n "$2" ];then
      HOUR_STR2=`date '+%H:%M:%S' -d "$2"`
      #LAST_MATCH_LINE=`grep -n "$HOUR_STR" $f|tail -1|cut -d: -f1`
      LAST_MATCH_LINE=`get_match_line_num "$DAY_STR $HOUR_STR2" $f 1`
    fi
      
    if [ $LAST_MATCH_LINE -ne -1 ];then
      sed -n "$FIRST_MATCH_LINE,${LAST_MATCH_LINE}p" $f|$SGREP "$KEY_WORDS"
    #else
    #  echo "sed -n "$FIRST_MATCH_LINE,\$p" $f|grep --color=always -i -E "$KEY_WORDS""
    fi
  done

}
