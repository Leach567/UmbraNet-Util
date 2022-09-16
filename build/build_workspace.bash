#!/usr/bin/bash
SCRIPT_NAME=`readlink -f $BASH_SOURCE`
SCRIPT_HOME=`dirname $SCRIPT_NAME`

. ${SCRIPT_HOME}/workspace_config.bash

ln -fs $UMBRA_UTIL_REPO_ROOT/_umbraNetConfig.bash $UMBRA_DEV_ROOT
ln -fs $UMBRA_UTIL_REPO_ROOT/docker/_containerConfig.bash $UMBRA_DEV_ROOT

pushd $UMBRA_DEV_ROOT

mkdir -p Models
$UMBRA_BUILD_SCRIPT_ROOT/clone.bash $UMBRA_MODELS_REPO_ROOT $PWD/Models

if [ ! -e $UMBRA_MODELS_REPO_ROOT/Umbra_Cpp/config.bash ]
then
    echo "Cannot find Model config script. Terminating."
    exit 1
fi

. $UMBRA_MODELS_REPO_ROOT/Umbra_Cpp/config.bash

_modelDepRoot="$UMB_MODEL_CPP_ROOT/dep"
mkdir -p $_modelDepRoot

mkdir -p $_modelDepRoot/Boost
$UMBRA_BUILD_SCRIPT_ROOT/clone.bash $UMBRA_BOOST_REPO_ROOT $_modelDepRoot/Boost

popd