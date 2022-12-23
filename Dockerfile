FROM debian:bullseye

ENV LANG C.UTF-8
ENV SNAPCASTVERSION 0.26.0

RUN set -ex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
     wget \
     apt-utils \
     gnupg2 \
 && mkdir -p /usr/local/share/keyrings \
 && wget -q -O /usr/local/share/keyrings/mopidy-archive-keyring.gpg https://apt.mopidy.com/mopidy.gpg \
 && wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/buster.list \
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
 && wget 'https://github.com/badaix/snapcast/releases/download/v'$SNAPCASTVERSION'/snapserver_'$SNAPCASTVERSION'-1_amd64.deb' \
 && dpkg -i --force-all 'snapserver_'$SNAPCASTVERSION'-1_amd64.deb' \
 && apt-get -f install -y \
 && rm 'snapserver_'$SNAPCASTVERSION'-1_amd64.deb' \
 && pip3 install mopidy-musicbox-webclient \
 && apt-get purge --auto-remove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

COPY root /

VOLUME ["/var/lib/mopidy/media", "/var/lib/mopidy/m3u"]

EXPOSE 1704 1705 6680 6600

CMD chown mopidy:audio /var/lib/mopidy && chown mopidy:audio /var/lib/mopidy/m3u && chown -R mopidy:audio /var/lib/mopidy/.config && /usr/bin/supervisord -c /etc/supervisord.conf
