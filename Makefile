default: build

# Build Docker image
build: docker_build output

# Build and push Docker image
release: docker_build docker_push output

# Build a Docker standalone image
standalone: docker_build_standalone output

# Build and push a Docker standalone image
standalone_release: docker_build_standalone docker_push_standalone output

# If making a standalone image (and release) these need to be set (and re-set)
ifneq (,$(findstring standalone, $(MAKECMDGOALS)))
# variables need to be overwritten
SCRAM_ARCH=slc6_amd64_gcc481
CMSSW_VERSION=CMSSW_7_1_25_patch5
BASEIMAGE=gitlab-registry.cern.ch/cms-cloud/cmssw-docker/slc6-cms

# function to return base version
get_version = $(strip $(subst CMSSW_, ,$1))
BASE_VERSION = $(call get_version,$(CMSSW_VERSION))

DOCKER_IMAGE = cmscloud/cmssw
CERN_IMAGE = gitlab-registry.cern.ch/cms-cloud/cmssw-docker/cmssw_$(BASE_VERSION)-$(SCRAM_ARCH)

# If not, then proceed with another target release, specified by DIST
else

# check for DIST
ifeq (,$(DIST))
$(error echo set the DIST argument)
endif

# Image can be overidden with env var.
DOCKER_IMAGE = cmscloud/$(DIST)
CERN_IMAGE = gitlab-registry.cern.ch/cms-cloud/cmssw-docker/$(DIST)
endif

#$(error echo $(DOCKER_IMAGE) $(CERN_IMAGE))

# Get the latest commit.
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

# Get the date as version number
CODE_VERSION = $(strip $(shell date +"%Y-%m-%d"))

# Find out if the working directory is clean
GIT_NOT_CLEAN_CHECK = $(shell git status --porcelain)
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
DOCKER_TAG_SUFFIX = "-dirty"
endif

# If we're releasing to Docker Hub, and we're going to mark it with the latest tag, it should exactly match a version release
ifeq ($(MAKECMDGOALS),release)
# Use the version number as the release tag.
DOCKER_TAG = $(CODE_VERSION)

# See what commit is tagged to match the version
VERSION_COMMIT = $(strip $(shell git rev-list $(CODE_VERSION) -n 1 | cut -c1-7))
ifneq ($(VERSION_COMMIT), $(GIT_COMMIT))
$(error echo You are trying to push a build based on commit $(GIT_COMMIT) but the tagged release version is $(VERSION_COMMIT))
endif

# Don't push to Docker Hub if this isn't a clean repo
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
$(error echo You are trying to release a build based on a dirty repo)
endif

else
# Add the commit ref for development builds. Mark as dirty if the working directory isn't clean
DOCKER_TAG = $(CODE_VERSION)-$(GIT_COMMIT)$(DOCKER_TAG_SUFFIX)
endif

docker_build:
	# Build Docker image
	docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VERSION=$(CODE_VERSION) \
  --build-arg VCS_URL=`git config --get remote.origin.url` \
  --build-arg VCS_REF=$(GIT_COMMIT) \
	-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
	-f $(DIST)/Dockerfile \
	--compress --squash .
	# Tag image as latest
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest

docker_push:
	# Tag image also for CERN GitLab container registry
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(CERN_IMAGE):$(DOCKER_TAG)
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(CERN_IMAGE):latest

	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest

	# Push to CERN GitLab container registry
	docker push $(CERN_IMAGE):$(DOCKER_TAG)
	docker push $(CERN_IMAGE):latest

docker_build_standalone:
	# Build Docker image
	docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg BASEIMAGE=$(BASEIMAGE) \
  --build-arg SCRAM_ARCH=$(SCRAM_ARCH) \
  --build-arg CMSSW_VERSION=$(CMSSW_VERSION) \
  --build-arg VERSION=$(CODE_VERSION) \
  --build-arg VCS_URL=`git config --get remote.origin.url` \
  --build-arg VCS_REF=$(GIT_COMMIT) \
	-t $(DOCKER_IMAGE):$(BASE_VERSION) \
        -f standalone/Dockerfile \
	--compress --squash .

docker_push_standalone:
	# Tag image also for CERN GitLab container registry
	

	# Push to DockerHub
	docker push rchudasa/cmssw:$(BASE_VERSION)

	# Push to CERN GitLab container registry


output:
	@echo Docker Image: $(DOCKER_IMAGE):$(DOCKER_TAG)
