# cmssw-docker
This repository is copied from https://gitlab.cern.ch/cms-cloud/cmssw-docker
Makefie is updated to push to dockerhub instead of official cms cloud. 

```shell
make standalone CMSSW_VERSION=CMSSW_12_0_2 SCRAM_ARCH=slc7_amd64_gcc900 BASEIMAGE=gitlab-registry.cern.ch/cms-cloud/cmssw-docker/cc7-cms:latest DIST=cc7-cvmfs

make docker_push_standalone CMSSW_VERSION=CMSSW_12_0_2 SCRAM_ARCH=slc7_amd64_gcc900 BASEIMAGE=gitlab-registry.cern.ch/cms-cloud/cmssw-docker/cc75-cms:latest DIST=cc7-cvmfs
```


