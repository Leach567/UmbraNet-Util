#!/usr/bin/bash

. ./workspace_config.bash

ln -fs $UMBRA_UTIL_REPO_ROOT/_umbraNetConfig.bash $UMBRA_DEV_ROOT
ln -fs $UMBRA_UTIL_REPO_ROOT/docker/_containerConfig.bash $UMBRA_DEV_ROOT
