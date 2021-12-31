#!/bin/sh

MUSIC_DIR=$1
if [ -z "$MUSIC_DIR" ]; then
  echo "Please provide MUSIC dir as first arg!"
  exit 1
fi

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
echo "["
for mp3File in "$MUSIC_DIR"/*.mp3 ;
do
  BASENAME=$(basename -s ".mp3" "$mp3File")
  BASENAME_WITH_EXT=$(basename "$mp3File")
  MUSIC_DIR_RELATIVE=$(basename "$MUSIC_DIR")
  FILEPATH=$(echo "$MUSIC_DIR_RELATIVE/$BASENAME_WITH_EXT")
  #NAME=`echo $BASENAME | sed -e "s/\([A-Z]\)/\ \1/g" | sed -e "s/^\ *//"`
#  NAME=`echo $BASENAME | sed -e "s/^\ *//"`
  NAME=$BASENAME
#  echo name "$NAME" and file "$mp3File"
  echo "{"
  echo "    \"name\": \"$NAME\","
  echo "    \"path\": \"$FILEPATH\","
  echo "    \"segment\": {\"start\": 0, \"end\": 0}"
  echo "},"
done
echo "]"
IFS=$SAVEIFS
