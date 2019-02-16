# icon-helpers

Bash script to ***process icons*** for mobile-development use cases.

Uses imagemagick (`convert`) (`mogrify`) to manipulate the image input.
  
## Example Runs

```
$ icon-helpers.sh colorize $FILE "rgb(255,0,0)"
$ icon-helpers.sh colorize $FILE "#FF0000FF"
$ icon-helpers.sh resize $FILE 24
$ icon-helpers.sh trim $FILE
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