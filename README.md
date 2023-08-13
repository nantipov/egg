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

### Device software

#### Flash Micropython

#### Upload code

Consider using [pyboard](https://docs.micropython.org/en/latest/reference/pyboard.py.html) utility.

```shell
$ python3 pyboard.py --device /dev/cu.usbmodem14101 --filesystem ls
```

``` shell
nantipov@MBP-von-Nikolai egg %  python3 ~/tools/micropython/tools/pyboard.py --device /dev/cu.usbmodem14101 --filesystem cp client/core.py :/
cp client/core.py :/
nantipov@MBP-von-Nikolai egg %  python3 ~/tools/micropython/tools/pyboard.py --device /dev/cu.usbmodem14101 --filesystem cp client/main.py :/
cp client/main.py :/
```

```shell
python3 ~/tools/micropython/tools/pyboard.py --device /dev/cu.usbmodem14101 client/main.py
```
