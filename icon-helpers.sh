#!/bin/bash

#set -x

colorize() {
convert "$1" \
-fill "$2" \
-colorize 100% \
"${1%.*}_${FUNCNAME[0]}.${1##*.}"
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