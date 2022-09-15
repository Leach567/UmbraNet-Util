#!/bin/bash

. ./_umbraNetConfig.bash

pushd ./_Projects/UmbraCC
. ./_umbraCC_Config.bash
popd

pushd ./Models/Umbra_Cpp
. ./config.bash
popd
