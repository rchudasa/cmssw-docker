# A container containing a specific CMSSW release

# Make the base image configurable:
ARG BASEIMAGE=gitlab-registry.cern.ch/cms-cloud/cmssw-docker/slc6-cms:latest

# Set up the SLC6 CMSSW base:
FROM ${BASEIMAGE}

LABEL maintainer="CMS Data Preservation and Open Access Group <cms-dpoa-coordinators@cern.ch>"

ARG SCRAM_ARCH=slc6_amd64_gcc481
ARG CMSSW_VERSION=CMSSW_7_1_25_patch5
ARG CMS_INSTALL_DIR=/cvmfs/cms.cern.ch

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION
LABEL   org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.name="CMSSW Docker standalone images ${SCRAM_ARCH} ${CMSSW_VERSION}" \
        org.label-schema.description="Provide completely offline-runnable CMSSW images." \
        org.label-schema.url="http://cms-sw.github.io/" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url=$VCS_URL \
        org.label-schema.vendor="CERN" \
        org.label-schema.version=$VERSION \
        org.label-schema.schema-version="1.0"

USER root
RUN chmod -R 777 /cvmfs

# cannot install CMSSW as root
USER    cmsinst
WORKDIR /opt/cms

RUN     wget -O /opt/cms/bootstrap.sh http://cmsrep.cern.ch/cmssw/repos/bootstrap.sh \
        && sh /opt/cms/bootstrap.sh setup -r cms -architecture ${SCRAM_ARCH} -server cmsrep.cern.ch -path ${CMS_INSTALL_DIR} \
        && if [[ $SCRAM_ARCH = "slc5"* ]] || [[ $SCRAM_ARCH = "slc6"* ]]; \
        then \
          ${CMS_INSTALL_DIR}/common/cmspkg -a ${SCRAM_ARCH} install -y cms+local-cern-siteconf+sm111124; \
        else \
          wget -q https://github.com/cms-sw/siteconf/archive/master.tar.gz \
          && tar -xzf master.tar.gz \
          && mv siteconf-master SITECONF; \
        fi \
        && if [[ $CMSSW_VERSION = *"patch"* ]]; \
        then \
          export BASE_VERSION=$(echo "${CMSSW_VERSION}"| cut -d '_' -f -4); \
        else \
          export BASE_VERSION=${CMSSW_VERSION}; \
        fi \
        && ${CMS_INSTALL_DIR}/common/cmspkg -a ${SCRAM_ARCH} install -y cms+cmssw+${BASE_VERSION} \
        && if [[ $CMSSW_VERSION = *"patch"* ]]; \
        then \
          ${CMS_INSTALL_DIR}/common/cmspkg -a ${SCRAM_ARCH} install -y cms+cmssw-patch+${CMSSW_VERSION}; \
        fi \
        && ${CMS_INSTALL_DIR}/common/cmspkg -a ${SCRAM_ARCH} clean

RUN 	if [[ $SCRAM_ARCH = "slc5"* ]] || [[ $SCRAM_ARCH = "slc6"* ]]; \
	then \
	     LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:${LD_LIBRARY_PATH} \
	     git clone https://github.com/cms-sw/cms-common.git \
	     && sed -i -e 's|@CMS_PREFIX@|'"$CMS_INSTALL_DIR"'|g;s|@SCRAM_ARCH@|'"$SCRAM_ARCH"'|' \
	     cms-common/cmsset_default.* \
	     && cp -f cms-common/cmsset_default.sh ${CMS_INSTALL_DIR}/ \
	     && cp -f cms-common/cmsset_default.csh ${CMS_INSTALL_DIR}/ \
	     && rm -rf cms-common; \
	fi

USER    root
RUN     /bin/cp -f ${CMS_INSTALL_DIR}/cmsset_default.sh /etc/profile.d/

# Add siteconfig
WORKDIR /cvmfs/cms.cern.ch/SITECONF
ADD --chown=cmsinst:cmsinst siteconf/T3_CH_PublicCloud T3_CH_PublicCloud
RUN rm -rf local && ln -s T3_CH_PublicCloud local 

USER    cmsusr
WORKDIR /code
RUN     sudo chown -R cmsusr:cmsusr /code && sudo chmod -R 777 /code
ENV     CMSSW_VERSION=${CMSSW_VERSION}
ENV     SCRAM_ARCH=${SCRAM_ARCH}
ENV     CMS_INSTALL_DIR=${CMS_INSTALL_DIR}
ADD     entrypoints/entrypoint-standalone.sh /opt/cms/entrypoint.sh
RUN     sudo chmod 755 /opt/cms/entrypoint.sh && \
        sudo chown -R cmsusr /home/cmsusr && \
        chmod 755 /home/cmsusr

ENTRYPOINT ["/opt/cms/entrypoint.sh"]
CMD     ["/bin/zsh"]
