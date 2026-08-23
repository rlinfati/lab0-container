FROM registry.access.redhat.com/ubi10/ubi

USER root
WORKDIR /tmp/

RUN dnf --assumeyes install unzip xz rsync openssh-clients python3-pip && \
    dnf clean all

ARG RCLONE_VER=v1.75.0
ARG RCLONE_MAC=amd64
ARG FFMPEG_VER=9.0
ARG FFMPEG_MAC=linux64
# FIX: https://rclone.org/downloads/
# FIX: https://github.com/BtbN/FFmpeg-Builds/releases

RUN curl --location --remote-name https://downloads.rclone.org/${RCLONE_VER}/rclone-${RCLONE_VER}-linux-${RCLONE_MAC}.zip && \
    unzip rclone-${RCLONE_VER}-linux-${RCLONE_MAC}.zip && \
    cp rclone-${RCLONE_VER}-linux-${RCLONE_MAC}/rclone /usr/local/bin/ && \
    rm -rf rclone-${RCLONE_VER}-linux-${RCLONE_MAC}.zip rclone-${RCLONE_VER}-linux-${RCLONE_MAC} && \
    rclone --version

RUN curl --location --remote-name https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n${FFMPEG_VER}-latest-${FFMPEG_MAC}-gpl-${FFMPEG_VER}.tar.xz && \
    tar Jxvf ffmpeg-n${FFMPEG_VER}-latest-${FFMPEG_MAC}-gpl-${FFMPEG_VER}.tar.xz && \
    cp ffmpeg-n${FFMPEG_VER}-latest-${FFMPEG_MAC}-gpl-${FFMPEG_VER}/bin/ffmpeg /usr/local/bin/ && \
    rm -rf ffmpeg-n${FFMPEG_VER}-latest-${FFMPEG_MAC}-gpl-${FFMPEG_VER}.tar.xz ffmpeg-n${FFMPEG_VER}-latest-${FFMPEG_MAC}-gpl-${FFMPEG_VER} && \
    ffmpeg -version
