FROM ubuntu:kinetic

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      curl \
      dnsutils \
      iproute2 \
      iputils-ping \
      jq \
      language-pack-ja \
      net-tools \
      stress \
      tcpdump \
      tzdata \
      unzip \
      vim \
      wget \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

ENV LANG ja_JP.UTF-8
ENV TZ Asia/Tokyo
