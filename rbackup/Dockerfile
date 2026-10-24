FROM registry.access.redhat.com/ubi10/ubi

USER root
WORKDIR /tmp/

RUN dnf --assumeyes install unzip xz rsync openssh-clients python3-pip && \
    dnf clean all

# renovate: datasource=github-releases depName=rclone/rclone
ARG RCLONE_VER=v1.75.2
ARG RCLONE_MAC=amd64
# renovate: datasource=github-tags depName=FFmpeg/FFmpeg extractVersion=^n(?<version>\d+\.\d+)(?:\.\d+)?$
ARG FFMPEG_VER=9.0
ARG FFMPEG_MAC=linux64

RUN curl --fail --location --remote-name https://downloads.rclone.org/${RCLONE_VER}/rclone-${RCLONE_VER}-linux-${RCLONE_MAC}.zip && \
    unzip rclone-${RCLONE_VER}-linux-${RCLONE_MAC}.zip && \
    cp rclone-${RCLONE_VER}-linux-${RCLONE_MAC}/rclone /usr/local/bin/ && \
    rm -rf rclone-${RCLONE_VER}-linux-${RCLONE_MAC}.zip rclone-${RCLONE_VER}-linux-${RCLONE_MAC} && \
    rclone --version

RUN curl --fail --location --remote-name https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n${FFMPEG_VER}-latest-${FFMPEG_MAC}-gpl-${FFMPEG_VER}.tar.xz && \
    tar Jxvf ffmpeg-n${FFMPEG_VER}-latest-${FFMPEG_MAC}-gpl-${FFMPEG_VER}.tar.xz && \
    cp ffmpeg-n${FFMPEG_VER}-latest-${FFMPEG_MAC}-gpl-${FFMPEG_VER}/bin/ffmpeg /usr/local/bin/ && \
    rm -rf ffmpeg-n${FFMPEG_VER}-latest-${FFMPEG_MAC}-gpl-${FFMPEG_VER}.tar.xz ffmpeg-n${FFMPEG_VER}-latest-${FFMPEG_MAC}-gpl-${FFMPEG_VER} && \
    ffmpeg -version

RUN useradd --uid 1000 --gid 100 --create-home --no-user-group rbackup

USER rbackup
WORKDIR /home/rbackup/
