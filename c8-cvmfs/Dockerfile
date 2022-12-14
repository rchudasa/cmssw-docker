# A container where CernVM-FS is up and running for CMSSW

# Make the base image configurable:
#ARG BASEIMAGE=gitlab-registry.cern.ch/cms-cloud/cmssw-docker/cc7-cms:latest
ARG BASEIMAGE=cmscloud/c8-cms:latest

# Set up the SLC6 CMSSW base:
FROM ${BASEIMAGE}

LABEL maintainer="CMS Data Preservation and Open Access Group <cms-dpoa-coordinators@cern.ch>"

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION
LABEL   org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.name="C8 CMSSW Docker images using CVMFS" \
        org.label-schema.description="Provide lightweight images for running CMSSW." \
        org.label-schema.url="http://cms-sw.github.io/" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url=$VCS_URL \
        org.label-schema.vendor="CERN" \
        org.label-schema.version=$VERSION \
        org.label-schema.schema-version="1.0"

USER root

# install cvmfs repos
ADD c8-cvmfs/etc-yum-cernvm.repo /etc/yum.repos.d/cernvm.repo

RUN     yum install -y cvmfs cvmfs-config-default fuse && \
        yum clean -y all

# afs does not work when building on Mac
# add kerberos and afs configs
# ADD krb5.conf /etc/krb5.conf
# ADD afs/etc /usr/vice/etc
# ADD openafs.ko /lib/modules/2.6.32-696.30.1.el6.x86_64/fs/openafs/openafs.ko
# RUN echo /lib/modules/2.6.32-696.30.1.el6.x86_64/fs/openafs/openafs.ko | openafs-modules --add-modules && \
    # /sbin/chkconfig --add afs && \
    # /sbin/service afs start

# add CVMFS mounting
RUN mkdir -p /cvmfs/cms.cern.ch && \
    echo "cms.cern.ch /cvmfs/cms.cern.ch cvmfs defaults 0 0" >> /etc/fstab && \
    mkdir -p /cvmfs/cms-opendata-conddb.cern.ch && \
    echo "cms-opendata-conddb.cern.ch /cvmfs/cms-opendata-conddb.cern.ch cvmfs defaults 0 0" >> /etc/fstab
ADD cvmfs/cms.cern.ch.local /etc/cvmfs/config.d/cms.cern.ch.local
ADD cvmfs/run-cvmfs.sh /etc/cvmfs/run-cvmfs.sh
RUN chmod uga+rx /etc/cvmfs/run-cvmfs.sh
ADD cvmfs/default.local /etc/cvmfs/default.local

WORKDIR /code
USER cmsusr
ENV USER cmsusr
ENV HOME /home/cmsusr

ADD     entrypoints/entrypoint-cvmfs.sh /opt/cms/entrypoint.sh
RUN     sudo chmod 755 /opt/cms/entrypoint.sh && \
        sudo chown -R cmsusr /home/cmsusr && \
        chmod 755 /home/cmsusr

ENTRYPOINT ["/opt/cms/entrypoint.sh"]
CMD     ["/bin/zsh"]