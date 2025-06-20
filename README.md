### Convert png to ico

```
docker run --entrypoint=magick -v ./assets/img:/imgs dpokidov/imagemagick /imgs/icon-1024.png -define icon:auto-resize=256,128,64,48,32,16 icon-1024.ico
```
