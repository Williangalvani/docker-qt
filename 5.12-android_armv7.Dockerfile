# Docker container to build Qt 5.12 for Android armv7 projects with OpenSSL
# Image: a12e/docker-qt:5.12-android_armv7

FROM ubuntu:18.04
MAINTAINER Willian Galvani <williangalvani@gmail.com>

ARG NDK_VERSION=r18b
ARG OPENSSL_VERSION=1.0.2r
ARG QT_VERSION=5.12.3
ARG SDK_BUILD_TOOLS=28.0.3
ARG SDK_PACKAGES="tools platform-tools"
ARG SDK_PLATFORM=android-21

ENV \
    ANDROID_HOME=/opt/android-sdk \
    ANDROID_NDK_ARCH=arch-arm \
    ANDROID_NDK_EABI=llvm \
    ANDROID_NDK_HOST=linux-x86_64 \
    ANDROID_NDK_TOOLCHAIN_PREFIX=arm-linux-androideabi \
    ANDROID_NDK_TOOLCHAIN_VERSION=4.9 \
    CLANG_TARGET=arm-none-linux-android \
    DEBIAN_FRONTEND=noninteractive \
    QMAKESPEC=android-clang \
    QT_PATH=/opt/qt \
    QT_PLATFORM=android_armv7

ENV \
    ANDROID_SDK_ROOT=${ANDROID_HOME} \
    ANDROID_NDK_PLATFORM=${SDK_PLATFORM} \
    ANDROID_NDK_ROOT=${ANDROID_HOME}/ndk-${NDK_VERSION} \
    ANDROID_NDK_TOOLS_PREFIX=${ANDROID_NDK_TOOLCHAIN_PREFIX}

ENV \
    ANDROID_DEV=${ANDROID_NDK_ROOT}/platforms/${ANDROID_NDK_PLATFORM}/${ANDROID_NDK_ARCH}/usr \
    ANDROID_NDK_TOOLCHAIN=${ANDROID_NDK_ROOT}/toolchains/${ANDROID_NDK_TOOLCHAIN_PREFIX}-${ANDROID_NDK_TOOLCHAIN_VERSION}/prebuilt/${ANDROID_NDK_HOST}
    
ENV \
    PATH=${QT_PATH}/${QT_VERSION}/${QT_PLATFORM}/bin:${ANDROID_NDK_TOOLCHAIN}/${ANDROID_NDK_TOOLCHAIN_PREFIX}/bin:${ANDROID_NDK_ROOT}/toolchains/${ANDROID_NDK_EABI}/prebuilt/${ANDROID_NDK_HOST}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}
  
# Install updates & requirements:
#  * unzip - unpack platform tools
#  * git, openssh-client, ca-certificates - clone & build
#  * locales, sudo - useful to set utf-8 locale & sudo usage
#  * curl - to download Qt bundle
#  * make, openjdk-8-jdk-headless, ant - basic build requirements
#  * libsm6, libice6, libxext6, libxrender1, libfontconfig1, libdbus-1-3, libx11-xcb1 - dependencies of Qt bundle run-file
#  * libc6:i386, libncurses5:i386, libstdc++6:i386, libz1:i386 - dependencides of android sdk binaries
#  * patch - to apply patches
RUN dpkg --add-architecture i386 && apt update && apt full-upgrade -y && apt install -y --no-install-recommends \
    unzip \
    git \
    openssh-client \
    ca-certificates \
    locales \
    sudo \
    curl \
    make \
    openjdk-8-jdk-headless \
    openjdk-8-jre-headless \
    ant \
    libsm6 \
    libice6 \
    libxext6 \
    libxrender1 \
    libfontconfig1 \
    libdbus-1-3 \
    libx11-xcb1 \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    libz1:i386 \
    patch \
    && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

# Download & unpack Qt toolchain
COPY scripts/install-qt.sh /tmp/build/
RUN /tmp/build/install-qt.sh

# Download & unpack android SDK
COPY scripts/install-android-sdk.sh /tmp/build/
RUN /tmp/build/install-android-sdk.sh

# Download & unpack android NDK
COPY scripts/install-android-ndk.sh /tmp/build/
RUN /tmp/build/install-android-ndk.sh

# Download, build & install OpenSSL for Android
COPY scripts/install-openssl-android-clang.sh /tmp/build/
RUN /tmp/build/install-openssl-android-clang.sh \    
# Reconfigure locale
    && locale-gen en_US.UTF-8 && dpkg-reconfigure locales \
# Add group & user, and make the SDK directory writable
    && groupadd -r user \
    && useradd --create-home --gid user user \
    && echo 'user ALL=NOPASSWD: ALL' > /etc/sudoers.d/user \
    && chown -R user:user $ANDROID_HOME

# Copy self-signed key
COPY /others/selfsigned.keystore /tmp/build/

COPY scripts/install-gstreamer.sh /tmp/build/
RUN /tmp/build/install-gstreamer.sh

COPY scripts/build-qgc.sh /home/user/

USER user
WORKDIR /home/user
ENV HOME /home/user
CMD ["/home/user/build-qgc.sh"]
