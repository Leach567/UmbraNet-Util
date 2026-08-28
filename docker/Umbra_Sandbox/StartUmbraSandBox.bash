#!/bin/bash
docker container run -it --rm  \
-v "${UMBRA_REPO_ROOT}":"/Repos" \
-v "${UMBRA_DEV_ROOT}":"/Umbra_Dev" \
--detach-keys="ctrl-d" \
umbra_nn_sand_gpu:v0
