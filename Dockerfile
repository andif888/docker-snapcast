FROM debian:bookworm

ENV LANG C.UTF-8
ENV SNAPCASTVERSION 0.31.0

RUN set -ex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
     wget \
     apt-utils \
     gnupg2 \
&& mkdir -p /etc/apt/keyring \
 && wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg https://apt.mopidy.com/mopidy-archive-keyring.gpg \
 && wget -q -O /etc/apt/sources.list.d/mopidy.sources https://apt.mopidy.com/bookworm.sources \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        gir1.2-gst-plugins-base-1.0 \
        gir1.2-gstreamer-1.0 \
        python3-gst-1.0 \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav \
        gstreamer1.0-tools \
        gstreamer1.0-plugins-base-apps \
        libsndfile1-dev \
        libasound2-dev \
        python3-pip \
        mopidy \
        supervisor \
        nano \
 && wget 'https://github.com/badaix/snapcast/releases/download/v'$SNAPCASTVERSION'/snapserver_'$SNAPCASTVERSION'-1_amd64_bookworm.deb' \
 && dpkg -i --force-all 'snapserver_'$SNAPCASTVERSION'-1_amd64_bookworm.deb' \
 && apt-get -f install -y \
 && rm 'snapserver_'$SNAPCASTVERSION'-1_amd64_bookworm.deb' \
 && pip3 install --break-system-packages mopidy-musicbox-webclient \
 && apt-get purge --auto-remove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

COPY root /

VOLUME ["/var/lib/mopidy/media", "/var/lib/mopidy/m3u"]

EXPOSE 1704 1705 1780 6680 6600

CMD chown mopidy:audio /var/lib/mopidy && chown mopidy:audio /var/lib/mopidy/m3u && chown -R mopidy:audio /var/lib/mopidy/.config && /usr/bin/supervisord -c /etc/supervisord.conf
