FROM mdillon/postgis:10

RUN export DEBIAN_FRONTEND=noninteractive \
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update -qq \
    && apt-get install -yqq \
        python \
        python-psycopg2 \
        python-yaml \
        python-requests \
        python-six \
        python-dateutil \
        python-pip \
        python-setuptools \
        python-prettytable \
        python-wheel \
        python-psutil \
        locales \
    ## Required for 'patronictl edit-config'
    && apt-get install -yqq \
        less \
        vim \
    ## Make sure we have a en_US.UTF-8 locale available
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && pip install \
        kazoo==2.5.0 \
        patroni[zookeeper] \
    && apt-get remove -yqq \
        python-pip \
        python-setuptools \
    && apt-get autoremove -yqq \
    && apt-get clean -yqq \
    && rm -rf /var/lib/apt/lists/* /root/.cache

# Change postgres uid and gid, 999 is a default one
RUN usermod -u 65000 postgres \
    && groupmod -g 65000 postgres \
    && find / -uid 999 -print0 | xargs -0 chown 65000 \
    && find / -gid 999 -print0 | xargs -0 chgrp 65000

ENV PATH="/usr/lib/postgresql/10/bin/:$PATH"
ENV EDITOR=vim

RUN touch /tmp/pgpass \
    && mkdir -p /etc/patroni \
    && mkdir -p /home/postgres \
    && mkdir -p /data \
    && chown postgres:postgres -R /etc/patroni/ /home/postgres/ /tmp/pgpass /data

EXPOSE 5432 8008

VOLUME /data /etc/patroni

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

ENTRYPOINT ["patroni", "/etc/patroni/patroni.yml"]

USER postgres

