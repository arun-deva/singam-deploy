#!/bin/sh

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
echo "["
for mp3File in $(ls music/*.mp3) ;
do
  BASENAME=$(basename -s ".mp3" $mp3File)
  NAME=`echo $BASENAME | sed -e "s/\([A-Z]\)/\ \1/g" | sed -e "s/^\ *//"`
  echo "{"
  echo "    \"name\": \"$NAME\","
  echo "    \"path\": \"$mp3File\","
  echo "    \"segment\": {\"start\": 100, \"end\": 108}"
  echo "},"
done
echo "]"
IFS=$SAVEIFS
