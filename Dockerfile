FROM mono:4.6
MAINTAINER Dmitry  K "d.p.karpov@gmail.com"

ENV DUPLICATI_VER 2.0.1.56_canary_2017-04-21

ENV D_CODEPAGE UTF-8 
ENV D_LANG en_US

ADD ./entrypoint.sh /entrypoint.sh

RUN apt-get -o Acquire::ForceIPv4=true -o Acquire::http::No-Cache=True update && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true -o Acquire::http::No-Cache=True -o Dpkg::Options::=--force-confold install -y --no-install-recommends \
        expect \
        libsqlite3-0 \
        unzip \
        locales && \
    curl -sSL https://updates.duplicati.com/canary/duplicati-${DUPLICATI_VER}.zip -o /duplicati-${DUPLICATI_VER}.zip && \
    unzip duplicati-${DUPLICATI_VER}.zip -d /app && \
    rm /duplicati-${DUPLICATI_VER}.zip && \
    localedef -v -c -i ${D_LANG} -f ${D_CODEPAGE} ${D_LANG}.${D_CODEPAGE} || : && \
    update-locale LANG=${D_LANG}.${D_CODEPAGE} && \
    cert-sync /etc/ssl/certs/ca-certificates.crt && \
    apt-get purge -y --auto-remove unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chmod a+x /entrypoint.sh

VOLUME /root/.config/Duplicati
VOLUME /docker-entrypoint-init.d

EXPOSE 8200

ENTRYPOINT ["/entrypoint.sh"]
