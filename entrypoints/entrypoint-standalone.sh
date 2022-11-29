#!/bin/bash
set  -e

cd /code
echo "Setting up ${CMSSW_VERSION}"
source ${CMS_INSTALL_DIR}/cmsset_default.sh
scramv1 project CMSSW ${CMSSW_VERSION}
cd ${CMSSW_VERSION}/src
eval `scramv1 runtime -sh`
echo "CMSSW should now be available."
echo "This is a standalone image for ${CMSSW_VERSION} ${SCRAM_ARCH}."

export LD_LIBRARY_PATH=${UPDATE_PATH}/lib:${UPDATE_PATH}/lib64:${LD_LIBRARY_PATH}
export PATH=${UPDATE_PATH}/bin:${PATH}
export GIT_EXEC_PATH=${UPDATE_PATH}/libexec/git-core

# After CMSSW_6_2_X these steps are needed in order to ensure that
# mkedanlzr works
ver=( $(echo ${CMSSW_VERSION} | tr '_', '\n') )

if [[ ${ver[1]}${ver[2]} -ge 62 ]]
then

    if [[ ${CMSSW_VERSION} = *"patch"* ]]
    then
	BASE_VERSION=$(echo "${CMSSW_VERSION}"| cut -d '_' -f -4);
	CMSSW_VERSION=${BASE_VERSION}
    fi
    
   sudo sed -i '/import os/a import pwd' ${CMS_INSTALL_DIR}/${SCRAM_ARCH}/cms/cmssw/${CMSSW_VERSION}/python/FWCore/Skeletons/pkg.py
   sudo sed -i 's/os.getlogin()/pwd.getpwuid(os.geteuid())[0]/g' ${CMS_INSTALL_DIR}/${SCRAM_ARCH}/cms/cmssw/${CMSSW_VERSION}/python/FWCore/Skeletons/pkg.py
   sudo sed -i 's/os.getlogin()/pwd.getpwuid(os.geteuid())[0]/g' ${CMS_INSTALL_DIR}/${SCRAM_ARCH}/cms/cmssw/${CMSSW_VERSION}/python/FWCore/Skeletons/utils.py
fi

exec "$@"
