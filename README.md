# icon-tools

Bash script to ***process icons*** for mobile-development use cases.

Uses [ImageMagick](https://github.com/ImageMagick/ImageMagick) (`convert`) (`mogrify`) to manipulate the image input
and [CairoSVG](https://github.com/Kozea/CairoSVG) to convert SVG files to PDF and PNG.
  
## Example Runs

```
$ ./icon-tools.sh colorize $FILE "rgb(255,0,0)"
$ ./icon-tools.sh colorize $FILE "#FF0000FF"
$ ./icon-tools.sh createicons $FILE 48
$ ./icon-tools.sh createvectoricons $FILE
$ ./icon-tools.sh dominantcolor $FILE
$ ./icon-tools.sh resize $FILE 24
$ ./icon-tools.sh square $FILE transparent
$ ./icon-tools.sh trim $FILE
```
## Dependencies

The script uses `basename`,`dirname`,`grep`,`head`,`mkdir`,`mv`,`rm`,`sed`,`sort`,`convert,`mogrify` and `cairosvg`.

##### homebrew MacOS
```
brew install imagemagick --build-from-source
brew install cairo libffi python3
pip3 install cairosvg
```