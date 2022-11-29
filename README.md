# cmssw-docker

Dockerfiles for CMSSW

There are different sets of Dockerfiles in this repository:

- [standalone](standalone) images
- [c8-cvmfs](c8-cvmfs)-based images
- [cc7-cvmfs](cc7-cvmfs)-based images [![cc7-cvmfs container badge](https://images.microbadger.com/badges/image/cmscloud/cc7-cmssw-cvmfs.svg)](https://microbadger.com/images/cmscloud/cc7-cvmfs) [![cc7-cvmfs container version](https://images.microbadger.com/badges/version/cmscloud/cc7-cvmfs.svg)](https://microbadger.com/images/cmscloud/cc7-cvmfs)
- [slc6-cvmfs](slc6-cvmfs)-based images [![slc6-cvmfs container badge](https://images.microbadger.com/badges/image/cmscloud/slc6-cvmfs.svg)](https://microbadger.com/images/cmscloud/slc6-cvmfs) [![slc6-cvmfs container version](https://images.microbadger.com/badges/version/cmscloud/slc6-cvmfs.svg)](https://microbadger.com/images/cmscloud/slc6-cvmfs)
- [c8-cms](c8-cms) images
- [cc7-cms](cc7-cms) images [![cc7-cms container badge](https://images.microbadger.com/badges/image/cmscloud/cc7-cms.svg)](https://microbadger.com/images/cmscloud/cc7-cms) [![cc7-cms container version](https://images.microbadger.com/badges/version/cmscloud/cc7-cms.svg)](https://microbadger.com/images/cmscloud/cc7-cms)
- [slc6-cms](slc6-cms) images [![slc6-cms container badge](https://images.microbadger.com/badges/image/cmscloud/slc6-cms.svg)](https://microbadger.com/images/cmscloud/slc6-cms) [![slc6-cms container version](https://images.microbadger.com/badges/version/cmscloud/slc6-cms.svg)](https://microbadger.com/images/cmscloud/slc6-cms)
- [slc5-cms](slc5-cms) images [![slc5-cms container badge](https://images.microbadger.com/badges/image/cmscloud/slc5-cms.svg)](https://microbadger.com/images/cmscloud/slc5-cms) [![slc5-cms container version](https://images.microbadger.com/badges/version/cmscloud/slc5-cms.svg)](https://microbadger.com/images/cmscloud/slc5-cms)

The non-standalone images need a network connection, and can be slow, since CMSSW is loaded via the network. The advantage is that they are much smaller (few hundreds of MB) while the standalone images contain the full CMSSW release (>= 15 GB).

The images are based on different sets of CERN Linux distributions:

- [Scientific Linux 5 (SLC5)](http://linux.web.cern.ch/linux/scientific5/).
- [Scientific Linux 6 (SLC5)](http://linux.web.cern.ch/linux/scientific6/).
- [CERN CentOS 7 (CC7)](http://linux.web.cern.ch/linux/centos7/).
- [CERN CentOS 8 (C8)](https://linux.web.cern.ch/centos8/).

## Building containers

The images need to be built from the base directory of the repository, pointing to the respective `Dockerfile` in the subdirectory using `docker build -f <path_to_Dockerfile>`. A `Makefile` at the top level can be used to simplify this process.

For properly tagging the containers and the `docker_push` to work you need to `docker login` to the container registry of your preference and pass additional parameters to the `make docker_push` command. The current default for the standalone images at the moment is:

```shell
DOCKER_IMAGE = cmscloud/cmssw
CERN_IMAGE = gitlab-registry.cern.ch/cms-cloud/cmssw-docker/cmssw_$(BASE_VERSION)-$(SCRAM_ARCH)
```

where `$(BASE_VERSION)` is extracted automatically from the CMSSW release version, e.g. `5_3_32` for `CMSSW_5_3_32`.

### Building standalone versions

Examples are given for different `CMSSW_VERSION` and `SCRAM_ARCH`:

Production releases:

```shell
make standalone CMSSW_VERSION=CMSSW_9_2_1 SCRAM_ARCH=slc6_amd64_gcc530
make docker_push_standalone CMSSW_VERSION=CMSSW_9_2_1 SCRAM_ARCH=slc6_amd64_gcc530
```

Patch releases work in the same way:

```shell
make standalone CMSSW_VERSION=CMSSW_7_1_25_patch5 SCRAM_ARCH=slc6_amd64_gcc481
make docker_push_standalone CMSSW_VERSION=CMSSW_7_1_25_patch5 SCRAM_ARCH=slc6_amd64_gcc481
```

Releases for other Linux distribution than SLC6 (here e.g. SLC5):

```shell
make standalone CMSSW_VERSION=CMSSW_4_2_8 SCRAM_ARCH=slc5_amd64_gcc434 BASEIMAGE=gitlab-registry.cern.ch/cms-cloud/cmssw-docker/slc5-cms:latest
make docker_push_standalone CMSSW_VERSION=CMSSW_4_2_8 SCRAM_ARCH=slc5_amd64_gcc434 BASEIMAGE=gitlab-registry.cern.ch/cms-cloud/cmssw-docker/slc5-cms:latest
```

### Building CVMFS versions

Since these containers load CMSSW via the network, any CMSSW version can be set up.
Note that you must specify the supported distribution using the `DIST` variable.

```shell
make DIST=c8-cvmfs
make docker_push DIST=c8-cvmfs
```

### Building SLC5/SLC6/CC7-CMS/C8-CMS versions

These images do not know about CMSSW, they are only an SLC5/SLC6/CC7/C8 image with some additional packages installed. More information on Linux@CERN see the [CERN IT Linux webpage](http://linuxsoft.cern.ch/). CVMFS needs to be mounted as volume (see below):

```shell
make DIST=c8-cms
make docker_push DIST=c8-cms
```

## Running containers

All base images are available in [docker hub](http://hub.docker.com/r/cmscloud/) as well as in the [CERN GitLab container registry](https://gitlab.cern.ch/cms-cloud/cmssw-docker/container_registry), which in addition contains a selection of standalone images. We recommend using the CERN registry by default. In order to use the images on docker hub, the run commands below need to be changed replacing `gitlab-registry.cern.ch/cmscloud/cmssw-docker` by `cmscloud`. For the standalone images the image name needs to be adjust as well, see example below.

### Running the standalone version

Currently supported for automatic CMSSW setup are `bash` and `zsh`. _These images are only available at the [CERN registry](https://gitlab.cern.ch/cms-cloud/cmssw-docker/container_registry/eyJuYW1lIjoiY21zLWNsb3VkL2Ntc3N3LWRvY2tlci9jbXNzdyIsInRhZ3NfcGF0aCI6Ii9jbXMtY2xvdWQvY21zc3ctZG9ja2VyL3JlZ2lzdHJ5L3JlcG9zaXRvcnkvNzE0OC90YWdzP2Zvcm1hdD1qc29uIiwiaWQiOjcxNDh9)!_ Please check which ones exactly are available before executing the commands below.

`bash`:

```shell
docker run --rm -it gitlab-registry.cern.ch/cms-cloud/cmssw-docker/cmssw_10_1_1-slc6_amd64_gcc630:2020-07-15-b57de653 /bin/bash
```

`zsh`:

```shell
docker run --rm -it gitlab-registry.cern.ch/cms-cloud/cmssw-docker/cmssw_10_1_1-slc6_amd64_gcc630:2020-07-15-b57de653 /bin/zsh
```

### Running the CVMFS version

Setting up CVMFS uses `fuse`, which needs special rights from docker:

```shell
docker run --rm --cap-add SYS_ADMIN --device /dev/fuse -it gitlab-registry.cern.ch/cms-cloud/cmssw-docker/cc7-cvmfs /bin/bash
```

Alternatively, one can also just use `--privileged` instead of `--cap-add SYS_ADMIN --device /dev/fuse`, see the [Docker run reference](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities).

If you get an error similar to:

```shell
/bin/sh: error while loading shared libraries: libtinfo.so.5: failed to map segment from shared object: Permission denied
```

you need to turn off SElinux security policy enforcing:

```shell
sudo setenforce 0
```

This can be changed permanently by editing `/etc/selinux/config`, setting `SELINUX` to `permissive` or `disabled`.

### Running the SLC5/SLC6/CC7/C8-only version

On a machine that has `/cvmfs` mounted (and available to the docker process):

```shell
docker run --rm -it -v /cvmfs:/cvmfs gitlab-registry.cern.ch/cms-cloud/cmssw-docker/slc6-cms /bin/zsh
```

On CERN OpenStack (see [OpenStack CVMFS documentation](http://clouddocs.web.cern.ch/clouddocs/containers/tutorials/cvmfs.html)):

```shell
docker run --rm -it --volume-driver cvmfs -v cms.cern.ch:/cvmfs/cms.cern.ch gitlab-registry.cern.ch/cms-cloud/cmssw-docker/slc6-cms /bin/zsh
```

and for CMS OpenData usage extend this to:

```shell
docker run --rm -it --volume-driver cvmfs -v cms.cern.ch:/cvmfs/cms.cern.ch -v cms-opendata-conddb.cern.ch:/cvmfs/cms-opendata-conddb.cern.ch gitlab-registry.cern.ch/cms-cloud/cmssw-docker/slc6-cms /bin/zsh
```

## Grid proxy

If you would like to be able to get a voms/grid proxy, mount your `.globus` directory by adding `-v ~/.globus:/home/cmsusr/.globus` to your `docker run` command.

## Testing

To test if everything is working, start a container, set up the desired CMSSW release (in case of non-standalone images), download the [GenXSecAnalyzer](https://twiki.cern.ch/twiki/bin/viewauth/CMS/HowToGenXSecAnalyzer#Running_the_GenXSecAnalyzer_on_a), and run it on a file:

```shell
cmsrel CMSSW_5_3_32
cd CMSSW_5_3_32/src
cmsenv
curl -O https://raw.githubusercontent.com/syuvivida/generator/master/cross_section/runJob/ana.py
cmsRun ana.py inputFiles="root://eospublic.cern.ch//eos/opendata/cms/MonteCarlo2011/Summer11LegDR/SMHiggsToZZTo4L_M-125_7TeV-powheg15-JHUgenV3-pythia6/AODSIM/PU_S13_START53_LV6-v1/20000/F8DC5130-4E92-E411-BDCA-E0CB4E29C4BB.root" maxEvents=-1
# With a grid proxy mounted:
cmsRun ana.py inputFiles="/store/mc/RunIIFall17MiniAOD/BulkGravToWW_narrow_M-2000_13TeV-madgraph/MINIAODSIM/94X_mc2017_realistic_v10-v1/70000/DC096708-7BEB-E711-9D6F-C45444922AFC.root " maxEvents=-1
```
