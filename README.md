These Docker images allow you to very easily build [QGroundControl](https://github.com/mavlink/qgroundcontrol) for android and get an useable .apk file.

QGroundControl Android Docker images
==========================

Qt 5.12.3 LTS
* `a12e/docker-qt:5.12-android_armv7` (Platform 21, NDK r18b [clang], OpenSSL 1.0.2r)
* Other platform need updates.

Build the Docker
---------------
```sh
git clone https://github.com/Williangalvani/QGC-Android-Arm-Docker.git
git submodule update --init --recursive
cd QGC-Android-Arm-Docker
docker build -f 5.12-android_armv7.Dockerfile .
```

Android example
---------------

`docker run -it --rm williangalvani/docker-qt:5.12-android_armv7`

```sh
./build-qgc.sh
```
When it is done, `exit` and then copy the on-screen command to copy the apk to the current folder.
