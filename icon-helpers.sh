#!/bin/bash

#set -x

colorize() {
convert "$1" \
-fill "$2" \
-colorize 100% \
"$3/$(basename $1)"
}

# https://www.smashingmagazine.com/2015/06/efficient-image-resizing-with-imagemagick/
resize() {
mogrify -path "$3" \
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
}

trim() {
convert "$1" \
-trim \
+repage \
"$2/$(basename $1)"
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