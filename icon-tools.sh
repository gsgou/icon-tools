#!/bin/bash

#set -x

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
WIDTH="$(convert "$1" -format "%w" info:)"
HEIGHT="$(convert "$1" -format "%h" info:)"
MINEQSIZE=$(($WIDTH<=$HEIGHT?$WIDTH:$HEIGHT))
case "$2" in
	18)
    if [ "$MINEQSIZE" -lt 72 ]; then
		  echo "Requires at least 72px"; exit 1
    fi
		;;
	24)
    if [ "$MINEQSIZE" -lt 96 ]; then
		  echo "Requires at least 96px"; exit 1
    fi  
		;;
	36)
    if [ "$MINEQSIZE" -lt 144 ]; then
		  echo "Requires at least 144px"; exit 1
    fi  
		;;
	48)
    if [ "$MINEQSIZE" -lt 192 ]; then
		  echo "Requires at least 192px"; exit 1
    fi  
		;;
  96)
    if [ "$MINEQSIZE" -lt 384 ]; then
		  echo "Requires at least 384px"; exit 1
    fi  
		;;   
	*)
		echo "Only sizes of 18, 24, 36, 48 and 96 dp/pt are supported!"; exit 1
		;; 
esac

DIRNAME="$(dirname "${1}")"  
FILENAME="$(basename "${1%.*}")"
EXTENSION="${1##*.}"

DIRIOS="iOS/"$FILENAME".imageset"
mkdir -p -m 755 "${1%/*}/$DIRIOS"
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

mkdir -p -m 755 "${1%/*}"/android/{drawable-xxxhdpi,drawable-xxhdpi,drawable-xhdpi,drawable-hdpi,drawable-mdpi}
rszmvandroid() {
  resize "$1" "$2"
  mv "${1%.*}_resize.${1##*.}" "$DIRNAME/android/$3/$FILENAME.$EXTENSION"
}

if [ "$2" -eq 18 ]; then
  # Android
  rszmvandroid "$1" 72 drawable-xxxhdpi
  rszmvandroid "$1" 54 drawable-xxhdpi
  rszmvandroid "$1" 36 drawable-xhdpi
  rszmvandroid "$1" 27 drawable-hdpi
  rszmvandroid "$1" 18 drawable-mdpi
  # iOS
  rszmvios "$1" 54 @3x
  rszmvios "$1" 36 @2x
  rszmvios "$1" 18
  contentsjson
elif [ "$2" -eq 24 ]; then
  # Android
  rszmvandroid "$1" 96 drawable-xxxhdpi
  rszmvandroid "$1" 72 drawable-xxhdpi
  rszmvandroid "$1" 48 drawable-xhdpi
  rszmvandroid "$1" 36 drawable-hdpi
  rszmvandroid "$1" 24 drawable-mdpi
  # iOS
  rszmvios "$1" 72 @3x
  rszmvios "$1" 48 @2x
  rszmvios "$1" 24
  contentsjson
elif [ "$2" -eq 36 ]; then
  # Android
  rszmvandroid "$1" 144 drawable-xxxhdpi
  rszmvandroid "$1" 108 drawable-xxhdpi
  rszmvandroid "$1" 72 drawable-xhdpi
  rszmvandroid "$1" 54 drawable-hdpi
  rszmvandroid "$1" 36 drawable-mdpi
  # iOS
  rszmvios "$1" 108 @3x
  rszmvios "$1" 72 @2x
  rszmvios "$1" 36
  contentsjson
elif [ "$2" -eq 48 ]; then
  # Android
  rszmvandroid "$1" 192 drawable-xxxhdpi
  rszmvandroid "$1" 144 drawable-xxhdpi
  rszmvandroid "$1" 96 drawable-xhdpi
  rszmvandroid "$1" 72 drawable-hdpi
  rszmvandroid "$1" 48 drawable-mdpi
  # iOS
  rszmvios "$1" 144 @3x
  rszmvios "$1" 96 @2x
  rszmvios "$1" 48
  contentsjson
elif [ "$2" -eq 96 ]; then
  # Android
  rszmvandroid "$1" 384 drawable-xxxhdpi
  rszmvandroid "$1" 288 drawable-xxhdpi
  rszmvandroid "$1" 192 drawable-xhdpi
  rszmvandroid "$1" 144 drawable-hdpi
  rszmvandroid "$1" 96 drawable-mdpi
  # iOS
  rszmvios "$1" 288 @3x
  rszmvios "$1" 192 @2x
  rszmvios "$1" 96
  contentsjson
fi
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