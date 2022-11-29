# CC8 OS capable of using/running CMS software release(s).

# Make the base image configurable:

# Use Centos Stream 8
ARG BASEIMAGE=gitlab-registry.cern.ch/linuxsupport/cs8-base:20220601-1.x86_64

# Set up the C8 CMSSW base:
FROM ${BASEIMAGE}

LABEL maintainer="CMS Data Preservation and Open Access Group <cms-dpoa-coordinators@cern.ch>"

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION
LABEL   org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.name="C8 CMS base OS" \
        org.label-schema.description="C8 OS capable of using/running CMS software release(s)." \
        org.label-schema.url="http://cms-sw.github.io/" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url=$VCS_URL \
        org.label-schema.vendor="CERN" \
        org.label-schema.version=$VERSION \
        org.label-schema.schema-version="1.0"

# Perform the installation as root
USER root
WORKDIR /root

RUN     yum install -y libX11-devel libXext-devel mesa-libGLU-devel \
        mesa-libGL-devel libSM libXft libXext \
        pciutils glx-utils mesa-dri-drivers libX11 libXi libXrender \
        tcsh zsh tcl tk e2fsprogs perl-ExtUtils-Embed libXmu e2fsprogs-libs libXpm bc libaio \
        tar patch krb5-devel perl-Data-Dumper perl-CGI perl-DBI perl-YAML gcc unzip zip perl-libwww-perl libXpm-devel libXft-devel svn \
        gcc-c++ strace cern-wrappers krb5-workstation wget hostname readline-devel nano bzip2 perl-Switch perl-Storable \
        perl-Env perl-Thread-Queue CERN-CA-certs tk-devel tcl-devel which \
        java-1.8.0-openjdk java-1.8.0-openjdk-devel popt popt-devel libXcursor libXrandr libXinerama nspr nss nss-util nss-devel file file-libs \
        readline bzip2-libs libgfortran time \
        git \
        openssl \
        glibc-devel.i686 glibc-devel \
        glibc-headers \
        sudo nano && \
        yum clean -y all

# Note the second-to-last line (beginning with echo command) is needed for now since the
# new LSC file configuration for C8 provides only the lsc files but not the vomses configs
# See https://twiki.cern.ch/twiki/bin/view/LCG/VOMSLSCfileConfiguration for more information
RUN     wget http://repository.egi.eu/sw/production/cas/1/current/repo-files/EGI-trustanchors.repo && \
        mv EGI-trustanchors.repo /etc/yum.repos.d/ && \
        wget http://repository.egi.eu/sw/production/cas/1/GPG-KEY-EUGridPMA-RPM-3 && \
        mv GPG-KEY-EUGridPMA-RPM-3 /etc/pki/rpm-gpg/ && \
        wget http://linuxsoft.cern.ch/wlcg/wlcg-centos8.repo && \
        mv wlcg-centos8.repo /etc/yum.repos.d/ && \
        wget http://linuxsoft.cern.ch/wlcg/RPM-GPG-KEY-wlcg && \
        mv RPM-GPG-KEY-wlcg /etc/pki/rpm-gpg/ && \
        yum install -y ca-policy-egi-core wlcg-repo.noarch wlcg-iam-lsc-cms HEP_OSlibs && \
	mkdir /etc/vomses && \
	echo '"cms" "voms-cms-auth.app.cern.ch" "443" "/DC=ch/DC=cern/OU=computers/CN=cms-auth.web.cern.ch" "cms"' > /etc/vomses/voms-cms-auth.app.cern.ch.vomses && \ 
        yum clean -y all

ADD 	c8-cms/eos.repo /etc/yum.repos.d/eos.repo
RUN 	yum --enablerepo=extras install -y epel-release && \
	yum install -y voms-clients-cpp && \
	yum install -y eos-client && \
    	yum clean -y all

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
