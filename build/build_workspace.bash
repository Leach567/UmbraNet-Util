#!/usr/bin/bash
SCRIPT_NAME=`readlink -f $BASH_SOURCE`
SCRIPT_HOME=`dirname $SCRIPT_NAME`

. ${SCRIPT_HOME}/workspace_config.bash

ln -fs $UMBRA_UTIL_REPO_ROOT/_umbraNetConfig.bash $UMBRA_DEV_ROOT
ln -fs $UMBRA_UTIL_REPO_ROOT/docker/_containerConfig.bash $UMBRA_DEV_ROOT
ln -fs $UMBRA_UTIL_REPO_ROOT/build/workspace_config.bash $UMBRA_DEV_ROOT

mkdir -p $UMBRA_DEV_ROOT/bin
ln -fs $UMBRA_UTIL_REPO_ROOT/docker/*.bash $UMBRA_DEV_ROOT/bin
ln -fs $UMBRA_UTIL_REPO_ROOT/build/*.bash $UMBRA_DEV_ROOT/bin

pushd $UMBRA_DEV_ROOT > /dev/null

echo "Linking MODELS"
mkdir -p Models
$UMBRA_BUILD_SCRIPT_ROOT/clone.bash $UMBRA_MODELS_REPO_ROOT $PWD/Models

if [ ! -e $UMBRA_MODELS_REPO_ROOT/Umbra_Cpp/config.bash ]
then
    echo "Cannot find Model config script. Terminating."
    exit 1
fi

echo "Linking Umbra_Cpp Dependencies..."
. $UMBRA_MODELS_REPO_ROOT/Umbra_Cpp/config.bash

_modelDepRoot="$UMB_MODEL_CPP_ROOT/dep"
mkdir -p $_modelDepRoot

_modelDepRoot="$UMB_MODEL_CPP_ROOT/dep/Boost"
mkdir -p $_modelDepRoot
$UMBRA_BUILD_SCRIPT_ROOT/clone.bash $UMBRA_BOOST_REPO_ROOT $_modelDepRoot

popd > /dev/null
