#!/usr/bin/bash
SCRIPT_NAME=`readlink -f $BASH_SOURCE`
SCRIPT_HOME=`dirname $SCRIPT_NAME`

. ${SCRIPT_HOME}/workspace_config.bash

ln -fs $UMBRA_UTIL_REPO_ROOT/_umbraNetConfig.bash $UMBRA_DEV_ROOT
ln -fs $UMBRA_UTIL_REPO_ROOT/docker/_containerConfig.bash $UMBRA_DEV_ROOT
ln -fs $UMBRA_UTIL_REPO_ROOT/build/workspace_config.bash $UMBRA_DEV_ROOT

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

pushd $_modelDepRoot > /dev/null
    _boostTar=`find /_reqs/ -name 'boost_*' | head -n 1`
    if [ -e "$_boostTar" ]
    then
        echo "Auto detected boost_package located at $_boostTar. Installing to $_modelDepRoot..."
        echo tar -xvzf $_boostTar | bash
        
        _baseName=`basename $_boostTar`
        mv $_baseName Boost
        #chmod -R u+rwx _modelDepRoot/boost_*
    fi
popd > /dev/null

popd > /dev/null