# From where to resolve the containers (e.g. "otel/weaver").
WEAVER_CONTAINER_REPOSITORY=docker.io
# Versioned, non-qualified references to containers used in this Makefile.
# These are parsed from dependencies.Dockerfile so dependabot will autoupdate
# the versions of docker files we use.
VERSIONED_WEAVER_CONTAINER_NO_REPO=$(shell cat dependencies.Dockerfile | awk '$$4=="weaver" {print $$2}')
# Versioned, non-qualified references to containers used in this Makefile.
WEAVER_CONTAINER=$(WEAVER_CONTAINER_REPOSITORY)/$(VERSIONED_WEAVER_CONTAINER_NO_REPO)

# Next - we want to run docker as our local file user, so generated code is not
# owned by root, and we don't give unecessary access.
#
# Determine if "docker" is actually podman
DOCKER_VERSION_OUTPUT := $(shell docker --version 2>&1)
DOCKER_IS_PODMAN := $(shell echo $(DOCKER_VERSION_OUTPUT) | grep -c podman)
ifeq ($(DOCKER_IS_PODMAN),0)
    DOCKER_COMMAND := docker
else
    DOCKER_COMMAND := podman
endif
DOCKER_RUN=$(DOCKER_COMMAND) run
DOCKER_USER=$(shell id -u):$(shell id -g)
DOCKER_USER_IS_HOST_USER_ARG=-u $(DOCKER_USER)
ifeq ($(DOCKER_COMMAND),podman)
 # On podman, additional arguments are needed to make "-u" work
 # correctly with the host user ID and host group ID.
 #
 #      Error: OCI runtime error: crun: setgroups: Invalid argument
 DOCKER_USER_IS_HOST_USER_ARG=--userns=keep-id -u $(DOCKER_USER)
endif
#
# A previous iteration of calculating "LATEST_RELEASED_VERSION"
# relied on "git describe". However, that approach does not work with
# light-weight developer forks/branches that haven't synced tags. Hence the
# more complex implementation of this using "git ls-remote".
#
# The output of "git ls-remote" looks something like this:
#
#    e531541025992b68177a68b87628c5dc75c4f7d9        refs/tags/v1.21.0
#    cadfe53949266d33476b15ca52c92f682600a29c        refs/tags/v1.22.0
#    ...
#
# .. which is why some additional processing is required to extract the
# latest version number and strip off the "v" prefix.
# LATEST_RELEASED_VERSION := $(shell git ls-remote --tags https://github.com/jsuereth/semantic-conventions.git | cut -f 2 | sort --reverse | head -n 1 | tr '/' ' ' | cut -d ' ' -f 3 | $(SED) 's/v//g')
# .PHONY: check-policies
# check-policies:
# 	$(DOCKER_RUN) --rm \
# 		--mount 'type=bind,source=$(PWD)/policies,target=/home/weaver/policies,readonly' \
# 		--mount 'type=bind,source=$(PWD)/model,target=/home/weaver/source,readonly' \
# 		${WEAVER_CONTAINER} registry check \
# 		--registry=/home/weaver/source \
# 		--baseline-registry=https://github.com/open-telemetry/semantic-conventions/archive/refs/tags/v$(LATEST_RELEASED_SEMCONV_VERSION).zip[model] \
# 		--policy=/home/weaver/policies

.PHONY: generate-go
generate-go:
	mkdir -p go/o11y
	$(DOCKER_RUN) --rm \
		$(DOCKER_USER_IS_HOST_USER_ARG) \
		--mount 'type=bind,source=$(PWD)/o11y,target=/home/weaver/source,readonly' \
		--mount 'type=bind,source=$(PWD)/templates,target=/home/weaver/templates,readonly' \
		--mount 'type=bind,source=$(PWD)/go/o11y,target=/home/weaver/target' \
		${WEAVER_CONTAINER} registry generate \
		--registry=/home/weaver/source \
		go \
		--future \
		/home/weaver/target
	cd go; go fmt ./o11y

generate-rust:
	mkdir -p generated/rust
	$(DOCKER_RUN) --rm \
		$(DOCKER_USER_IS_HOST_USER_ARG) \
		--mount 'type=bind,source=$(PWD)/o11y,target=/home/weaver/source,readonly' \
		--mount 'type=bind,source=$(PWD)/templates,target=/home/weaver/templates,readonly' \
		--mount 'type=bind,source=$(PWD)/generated/rust,target=/home/weaver/target' \
		${WEAVER_CONTAINER} registry generate \
		--registry=/home/weaver/source \
		rust \
		--future \
		/home/weaver/target

check:
	$(DOCKER_RUN) --rm \
		$(DOCKER_USER_IS_HOST_USER_ARG) \
		--mount 'type=bind,source=$(PWD)/o11y,target=/home/weaver/source,readonly' \
		--mount 'type=bind,source=$(PWD)/templates,target=/home/weaver/templates,readonly' \
		--mount 'type=bind,source=$(PWD)/policies,target=/home/weaver/policies' \
		${WEAVER_CONTAINER} registry check \
		--registry=/home/weaver/source \
		-p policies/ \
		--future \
