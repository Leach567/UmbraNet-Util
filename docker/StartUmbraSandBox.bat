docker container run -it --rm  ^
-v "%UMBRA_REPO_ROOT%":"/repos" ^
-v "%UMBRA_DEV_ROOT%":"/umbra_dev" ^
--detach-keys="ctrl-p" ^
umbra_nn_sand_gpu:v0
