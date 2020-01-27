#!/bin/bash

#set -x

round() {
    echo $(printf %.$2f $(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc -l))
};

colorize() {
convert "$1" \
-fill "$2" \
-colorize 100% \
"${1%.*}_${FUNCNAME[0]}.${1##*.}"
}

# https://google.github.io/material-design-icons/#sizing
# Tab-Icons 24dp/pt:
# https://material.io/design/components/tabs.html#spec
# https://developer.apple.com/design/human-interface-guidelines/ios/icons-and-images/custom-icons/#tab-bar-icon-size
createicons() (
# Check if width-parameter is given else state an error and exit
if [ -z "$2" ]; then
  echo 'Script usage: ./icon-tools.sh createicons $FILE width';
  exit 1;
fi
MDPI="$(round $2 0)"
FLOAT_HDPI="$(echo "$MDPI * 1.5" | bc -l)"
HDPI="${FLOAT_HDPI%.*}"
XHDPI="$(($MDPI * 2))"
XXHDPI="$(($MDPI * 3))"
XXXHDPI="$(($MDPI * 4))"

rszmvios() {
  resize "$1" "$2"
  mv "${1%.*}_resize.${1##*.}" "$DIRNAME/$DIRIOS/$FILENAME$3.$EXTENSION"
}

contentsjson() {
contents="{\
  \"images\": [
    {
      \"idiom\": \"universal\"
    },
    {
      \"filename\": \""$FILENAME".png\",
      \"scale\": \"1x\",
      \"idiom\": \"universal\"
    },
    {
      \"filename\": \""$FILENAME"@2x.png\",
      \"scale\": \"2x\",
      \"idiom\": \"universal\"
    },
    {
      \"filename\": \""$FILENAME"@3x.png\",
      \"scale\": \"3x\",
      \"idiom\": \"universal\"
    }
  ],
  \"info\": {
    \"version\": 1,
    \"author\": \"xcode\"
  }
}"
echo "$contents" >"$DIRNAME/$DIRIOS/Contents.json"
}

rszmvandroid() {
  resize "$1" "$2"
  mv "${1%.*}_resize.${1##*.}" "$DIRNAME/android/$3/$FILENAME.$EXTENSION"
}

create_icons_directories() {
DIRNAME="$(dirname "${1}")"  
FILENAME="$(basename "${1%.*}")"
EXTENSION="${1##*.}"
# Create Android directory
mkdir -p -m 755 "${1%/*}"/android/{drawable-xxxhdpi,drawable-xxhdpi,drawable-xhdpi,drawable-hdpi,drawable-mdpi}
# Create iOS directory
DIRIOS="iOS/"$FILENAME".imageset"
mkdir -p -m 755 "${1%/*}/$DIRIOS"
}

create_png_icons_from_png() {
create_icons_directories "$1"
# Android
rszmvandroid "$1" "$XXXHDPI" drawable-xxxhdpi
rszmvandroid "$1" "$XXHDPI" drawable-xxhdpi
rszmvandroid "$1" "$XHDPI" drawable-xhdpi
rszmvandroid "$1" "$HDPI" drawable-hdpi
rszmvandroid "$1" "$MDPI" drawable-mdpi
# iOS
rszmvios "$1" "$XXHDPI" @3x
rszmvios "$1" "$XHDPI" @2x
rszmvios "$1" "$MDPI"
contentsjson
}

create_png_icons() {
WIDTH="$(convert "$1" -format "%w" info:)"
HEIGHT="$(convert "$1" -format "%h" info:)"
MINEQSIZE=$(($WIDTH<=$HEIGHT?$WIDTH:$HEIGHT))
shopt -s nocasematch
case ${1: -4} in
 	".png")
    if [ "$MINEQSIZE" -lt "$XXXHDPI" ]; then
      echo "Requires at least $XXXHDPI px"; exit 1
    fi
    create_png_icons_from_png "$1"
		;;
  ".svg")
    SCALE="$(echo "$XXXHDPI / $MINEQSIZE" | bc -l)"
    PNG_FILE=${1%.*}.png
    cairosvg "$1" -s "$SCALE" -o "$PNG_FILE"
    create_png_icons_from_png "$PNG_FILE"
    rm -f "$PNG_FILE"
		;;
  *)
		echo "Only png and svg formats are supported!"; exit 1
		;; 
esac
shopt -u nocasematch
}

create_png_icons "$1"
)

# http://www.fmwconcepts.com/imagemagick/dominantcolor/index.php
dominantcolor() {
dominantcolor=`convert $1 \
-scale 50x50! \
+dither \
-colors 256 \
-depth 8 \
-format "%c" \
histogram:info: \
| sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' | sort -r -n -k 1 -t "," \
| head -2 | grep -v "#00000000"`
lines=`echo "$dominantcolor" | wc -l`
if [ "$lines" -eq "2" ]; then
  dominantcolor=`echo "$dominantcolor" | sed '$d'`
fi
dominantcolor="${dominantcolor#*#}"
echo "$dominantcolor"
}

# https://www.smashingmagazine.com/2015/06/efficient-image-resizing-with-imagemagick/
resize() {
TEMP_DIR="${1%/*}/${FUNCNAME[0]}"
mkdir -p -m 755 "$TEMP_DIR"
mogrify \
-path "$TEMP_DIR" \
-filter Triangle \
-define filter:support=2 \
-thumbnail "$2" \
-dither None \
-posterize 136 \
-quality 82 \
-define jpeg:fancy-upsampling=off \
-define png:compression-filter=5 \
-define png:compression-level=9 \
-define png:compression-strategy=1 \
-define png:exclude-chunk=all \
-interlace none \
-colorspace sRGB \
"$1"
mv "$TEMP_DIR/${1##*/}" "${1%.*}_${FUNCNAME[0]}.${1##*.}"
rm -rf "$TEMP_DIR"
}

# http://www.imagemagick.org/Usage/thumbnails/#pad
square() {
convert "$1" \
\( +clone -rotate 90 +clone -mosaic +level-colors "$2" \) \
+swap \
-gravity center \
-composite \
"${1%.*}_${FUNCNAME[0]}.${1##*.}"   
}

trim() {
convert "$1" \
-trim \
+repage \
"${1%.*}_${FUNCNAME[0]}.${1##*.}"
}

# Check if the function exists
if declare -f "$1" > /dev/null
then
  # call arguments verbatim
  "$@"
  #FUNC_CALL="$1"; shift;
  #"$FUNC_CALL" "$@"
else
  # Show a helpful error
  echo "'$1' is not a known function name" >&2
  exit 1
fi

#set +x