# icon-helpers

Bash script to ***process icons*** for mobile-development use cases.

Uses imagemagick (`convert`) (`mogrify`) to manipulate the image input.
  
## Example Runs

```
$ icon-helpers.sh colorize $SOURCE_FILE "rgb(255,0,0)" $DEST_FOLDER
$ icon-helpers.sh colorize $SOURCE_FILE "#FF0000FF" $DEST_FOLDER
$ icon-helpers.sh resize $SOURCE_FILE 24 $DEST_FOLDER
$ icon-helpers.sh trim $SOURCE_FILE $DEST_FOLDER
```
## Dependencies

The script uses `basename`, `convert` and `mogrify`.

##### apt-get
```
sudo apt-get install imagemagick
```
##### yum
```
sudo yum install imagemagick
```
##### homebrew MacOS
```
brew install imagemagick --build-from-source
```