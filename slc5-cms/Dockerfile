# SLC5 OS capable of using/running CMS software release(s).

# Make the base image configurable:
ARG BASEIMAGE=cern/slc5-base:20190724

# Set up the SLC5 CMSSW base:
FROM ${BASEIMAGE} AS cmssw-base

LABEL maintainer="CMS Data Preservation and Open Access Group <cms-dpoa-coordinators@cern.ch>"

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION
LABEL   org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.name="SLC5 CMS base OS" \
        org.label-schema.description="SLC5 OS capable of using/running CMS software release(s)." \
        org.label-schema.url="http://cms-sw.github.io/" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url=$VCS_URL \
        org.label-schema.vendor="CERN" \
        org.label-schema.version=$VERSION \
        org.label-schema.schema-version="1.0"

# Perform the installation as root
USER root
WORKDIR /root

ADD slc5-cms/epel.repo /etc/yum.repos.d/epel.repo

RUN     yum install -y libXft-devel libX11-devel libXpm-devel libXext-devel mesa-libGLU-devel \
        libXmu libXpm libSM libXft libXext \
        wget git \
        glibc-devel \
        tcsh zsh tcl \
        perl-libwww-perl \
        compat-libstdc++-33 zip \
        voms-clients-cpp python-simplejson \
        tk mesa-libGLU mesa-libGL \
        krb5-devel cern-wrappers krb5-workstation \
        time strace sudo nano && \
        yum clean -y all

RUN     wget http://repository.egi.eu/sw/production/cas/1/current/repo-files/EGI-trustanchors.repo && \
        mv EGI-trustanchors.repo /etc/yum.repos.d/ && \
        wget http://repository.egi.eu/sw/production/cas/1/GPG-KEY-EUGridPMA-RPM-3 && \
        mv GPG-KEY-EUGridPMA-RPM-3 /etc/pki/rpm-gpg/ && \
        wget http://linuxsoft.cern.ch/wlcg/wlcg-sl5.repo && \
        mv wlcg-sl5.repo /etc/yum.repos.d/ && \
        wget http://linuxsoft.cern.ch/wlcg/RPM-GPG-KEY-wlcg && \
        mv RPM-GPG-KEY-wlcg /etc/pki/rpm-gpg/ && \
        yum install -y HEP_OSlibs_SL5 ca-policy-lcg ca-policy-egi-core wlcg-repo.noarch wlcg-voms-cms && \
        yum clean -y all

ENV UPDATE_PATH /usr/local
RUN mkdir -p ${UPDATE_PATH}

FROM cmssw-base AS git-update

ARG GETTEXT_VERSION=gettext-0.20.1
ARG CURL_VERSION=curl-7.65.0
ARG OPENSSL_VERSION=openssl-1.1.1l
ARG M4_VERSION=m4-1.4.18
ARG AUTOCONF_VERSION=autoconf-2.69
ARG GIT_VERSION=git-2.21.0
ARG PERL_VERSION=perl-5.30.2

ADD http://ftp.gnu.org/pub/gnu/gettext/${GETTEXT_VERSION}.tar.gz ${UPDATE_PATH}
ADD https://curl.se/download/${CURL_VERSION}.tar.gz ${UPDATE_PATH}
ADD http://www.openssl.org/source/${OPENSSL_VERSION}.tar.gz ${UPDATE_PATH}
ADD http://mirrors.edge.kernel.org/pub/software/scm/git/${GIT_VERSION}.tar.gz ${UPDATE_PATH}
ADD http://ftp.gnu.org/gnu/m4/${M4_VERSION}.tar.gz ${UPDATE_PATH}
ADD http://ftp.gnu.org/gnu/autoconf/${AUTOCONF_VERSION}.tar.gz ${UPDATE_PATH}
ADD http://www.cpan.org/src/5.0/${PERL_VERSION}.tar.gz ${UPDATE_PATH}

ADD     slc5-cms/update_script.sh /root/update_script.sh
RUN     chmod +x /root/update_script.sh && source /root/update_script.sh

FROM cmssw-base AS slim

COPY --from=git-update ${UPDATE_PATH} ${UPDATE_PATH}

RUN     groupadd -g 1000 cmsusr && adduser -u 1000 -g 1000 -G root cmsusr && \
        echo "cmsusr ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers && \
        groupadd -g 1001 cmsinst && adduser -u 1001 -g 1001 cmsinst && \
        install -d /opt && install -d -o cmsinst /opt/cms

# Make Images grid/singularity compatible
RUN mkdir -p /cvmfs /afs /eos /pool /code && \
    chmod 1777 /cvmfs /afs /eos /pool /code && \
    chown -R cmsusr:cmsusr /code

ADD dotfiles/dot-pythonrc.py /etc/pythonrc.py
ADD dotfiles/dot-bashrc      /etc/profile.d/bashrc.sh

# Add a couple of useful files to cmsusr account
WORKDIR /code
USER cmsusr
ENV USER cmsusr
ENV HOME /home/cmsusr

ADD     entrypoints/entrypoint-cms.sh /opt/cms/entrypoint.sh
RUN     sudo chmod 755 /opt/cms/entrypoint.sh && \
        sudo chown -R cmsusr /home/cmsusr && \
        chmod 755 /home/cmsusr

ENTRYPOINT ["/opt/cms/entrypoint.sh"]
CMD     ["/bin/zsh"]
