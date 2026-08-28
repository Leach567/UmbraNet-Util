#!/usr/bin/bash
# Script Source: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

echo -e "RUNNING"
#
#curl https://get.docker.com | sh \
#  && sudo systemctl --now enable docker

distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list \
   | sudo tee /etc/apt/sources.list.d/nvidia-docker.list


#"To get access to experimental features such as CUDA on WSL
#or the new MIG capability on A100, you may want to add the
#experimental branch to the repository listing:"
#
curl -s -L https://nvidia.github.io/nvidia-container-runtime/experimental/$distribution/nvidia-container-runtime.list \
  | sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
