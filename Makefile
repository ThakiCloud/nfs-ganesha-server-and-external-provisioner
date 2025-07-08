# Copyright 2019 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CMDS=nfs-provisioner
all: build

include release-tools/build.make

ifeq ($(REGISTRY),)
	REGISTRY = ghcr.io/yunjae-park1111/nfs-provisioner
endif

ifeq ($(VERSION),)
	VERSION = thaki-v1.0.0
endif

IMAGE_ARM = $(REGISTRY)nfs-provisioner-arm:$(VERSION)
MUTABLE_IMAGE_ARM = $(REGISTRY)nfs-provisioner-arm:latest

IMAGE_AMD64 = $(REGISTRY)/nfs-provisioner-amd64:$(VERSION)
MUTABLE_IMAGE_AMD64 = $(REGISTRY)/nfs-provisioner-amd64:latest

build-docker-arm:
	GOOS=linux GOARCH=arm GOARM=7 go build -o deploy/docker/nfs-provisioner ./cmd/nfs-provisioner
.PHONY: build-docker-arm

container-arm: build-docker-arm quick-container-arm
.PHONY: container-arm

quick-container-arm:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker build -t $(MUTABLE_IMAGE_ARM) deploy/docker
	docker tag $(MUTABLE_IMAGE_ARM) $(IMAGE_ARM)
.PHONY: quick-container-arm

push-arm: container-arm
	docker push $(IMAGE_ARM)
	docker push $(MUTABLE_IMAGE_ARM)
.PHONY: push-arm

build-docker-amd64:
	GOOS=linux GOARCH=amd64 go build -o deploy/docker/nfs-provisioner ./cmd/nfs-provisioner
.PHONY: build-docker-amd64

container-amd64: build-docker-amd64 quick-container-amd64
.PHONY: container-amd64

quick-container-amd64:
	docker build -t $(MUTABLE_IMAGE_AMD64) deploy/docker
	docker tag $(MUTABLE_IMAGE_AMD64) $(IMAGE_AMD64)
.PHONY: quick-container-amd64

push-amd64: container-amd64
	docker push $(IMAGE_AMD64)
	docker push $(MUTABLE_IMAGE_AMD64)
.PHONY: push-amd64

clean-binary:
	rm -f deploy/docker/nfs-provisioner
.PHONY: clean-binary

