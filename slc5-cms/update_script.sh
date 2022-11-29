#!/bin/bash
set -e

yum -y install make
yum -y groupinstall 'Development Tools'

export INSTALL_DIR=${UPDATE_PATH}
export LD_LIBRARY_PATH=${INSTALL_DIR}/lib:${INSTALL_DIR}/lib64:${LD_LIBRARY_PATH}
export PATH=${INSTALL_DIR}/bin:${PATH}
cd ${INSTALL_DIR}

tar xzf ${GETTEXT_VERSION}.tar.gz
cd ${GETTEXT_VERSION}
./configure --prefix=${INSTALL_DIR}
make
make install
cd ..
rm ${GETTEXT_VERSION}.tar.gz
rm -rf ${GETTEXT_VERSION}

tar -xzf ${PERL_VERSION}.tar.gz
cd ${PERL_VERSION}
./Configure -des -Dprefix=/usr/local
make
make install
cd ..
rm ${PERL_VERSION}.tar.gz
rm -rf ${PERL_VERSION}

tar xzf ${OPENSSL_VERSION}.tar.gz
cd ${OPENSSL_VERSION}
CFLAGS=-fPIC ./config --prefix=${INSTALL_DIR} shared zlib
make
make install
cd ..
rm ${OPENSSL_VERSION}.tar.gz
rm -rf ${OPENSSL_VERSION}

tar xzf ${CURL_VERSION}.tar.gz
cd ${CURL_VERSION}
./configure --prefix=${INSTALL_DIR}
make
make install
cd ..
rm ${CURL_VERSION}.tar.gz
rm -rf ${CURL_VERSION}

tar xzf ${M4_VERSION}.tar.gz
cd ${M4_VERSION}
./configure --prefix=${INSTALL_DIR}
make
make install
cd ..
rm ${M4_VERSION}.tar.gz
rm -rf ${M4_VERSION}

tar xzf ${AUTOCONF_VERSION}.tar.gz
cd ${AUTOCONF_VERSION}
./configure --prefix=${INSTALL_DIR}
make
make install
cd ..
rm ${AUTOCONF_VERSION}.tar.gz
rm -rf ${AUTOCONF_VERSION}

tar xzf ${GIT_VERSION}.tar.gz
cd ${GIT_VERSION}
make configure
./configure --prefix=${INSTALL_DIR}
make
make strip
make install
cd ..
rm ${GIT_VERSION}.tar.gz
rm -rf ${GIT_VERSION}

# remove files that aren't part of standard package
rm ${INSTALL_DIR}/libexec/git-core/git-cvs* && \
rm ${INSTALL_DIR}/libexec/git-core/git-daemon && \
rm ${INSTALL_DIR}/libexec/git-core/git-fast-import && \
rm ${INSTALL_DIR}/libexec/git-core/git-http-backend && \
rm ${INSTALL_DIR}/libexec/git-core/git-instaweb && \
rm ${INSTALL_DIR}/libexec/git-core/git-shell && \
rm ${INSTALL_DIR}/libexec/git-core/git-svn && \
rm ${INSTALL_DIR}/libexec/git-core/*p4* && \
rm ${INSTALL_DIR}/libexec/git-core/mergetools/*p4* && \
rm ${INSTALL_DIR}/libexec/git-core/*email* && \
rm ${INSTALL_DIR}/libexec/git-core/*imap*
