FROM ubuntu:22.04

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
      iperf3 \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

# ENV LANG=ja_JP.UTF-8
# ENV TZ=Asia/Tokyo
