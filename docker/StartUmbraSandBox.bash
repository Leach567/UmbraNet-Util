#!/bin/bash
docker container run -it --rm  \
-v "${REPO_ROOT}":"/repos" \
-v "${DEV_ROOT}":"/umbra_dev" \
--detach-keys="ctrl-d" \
umbra_nn_sand_gpu:v0
