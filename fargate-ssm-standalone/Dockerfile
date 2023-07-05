FROM ubuntu:kinetic

RUN apt-get update     && DEBIAN_FRONTEND=noninteractive apt-get install -y       curl       dnsutils       iproute2       iputils-ping       jq       language-pack-ja       net-tools       stress       tcpdump       tzdata       unzip       vim       wget       awscli     && rm -rf /var/lib/apt/lists/*     && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime     && dpkg-reconfigure -f noninteractive tzdata

RUN curl https://s3.ap-northeast-1.amazonaws.com/amazon-ssm-ap-northeast-1/latest/debian_amd64/amazon-ssm-agent.deb -o /tmp/amazon-ssm-agent.deb     && dpkg -i /tmp/amazon-ssm-agent.deb     && cp /etc/amazon/ssm/seelog.xml.template /etc/amazon/ssm/seelog.xml

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

ENV LANG ja_JP.UTF-8
ENV TZ Asia/Tokyo
