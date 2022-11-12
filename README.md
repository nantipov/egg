# egg

The tiny blurry community lamp.

### Build
todo: docker build

## Server

## Client

## Web


### Model
todo: image; with cut?

![model1](docresources/egg-3d-model1.png)
![model2](docresources/egg-3d-model2.png)
![model3](docresources/egg-3d-model3.png)
![model4](docresources/egg-3d-model4.png)

### Circuit
todo: images

![pcb](docresources/pcb.png)

### Notes

```shell
$ openscad -o e.stl -D 'egg_length=150' egg.scad 
$ openscad -o e.png egg.scad
```

### Build building docker
```shell
$ docker build . --tag nantipov/egg-build:latest
$ docker push nantipov/egg-build:latest
```
