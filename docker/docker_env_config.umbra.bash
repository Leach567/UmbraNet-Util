#!/bin/bash
SERVICE_REPO_ROOT="/repos/UmbraNet-Util/docker"
SERVICE_BACKUP_ROOT="/home/umbra/Umbra-Blade_Backups/Service_Backups"
SERVICE_BACKUP_COLDSTORAGE_ROOT="/mnt/Strawhat_Share/"

if [[ -f ${UMBRA_UTIL_ROOT}/umbraScriptUtil.config.bash ]]; then
	. ${UMBRA_UTIL_ROOT}/umbraScriptUtil.config.bash
else
	. /home/umbra/repos/UmbraNet-Util/umbraScriptUtil.config.bash
fi

function force_free_port(){
	Print "Force-Freeing port $1..."
	sudo kill -9 $(sudo lsof -ti :$1)
	if [[ $? -ne 0 ]]; then
		PrintErr "Failed to kill process(s)"
	fi
}
export -f force_free_port
function umbra_service_log(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
	echo "Starting $1"
	docker compose logs -f

	popd
}
export -f umbra_service_log
function force_reset_docker(){
	Print "Stopping Docker..."
	sudo systemctl stop docker
	Print "Stopping Docker.sock..."
	sudo systemcle stop docker.sock
	Print "Removing local-kv.db..."
	sudo rm -f /var/lib/docker/network/files/local-kv.db
	Print "Restarting Docker..."
	sudo systemctl start docker
	Print "All done."
}
export -f force_reset_docker

function start_umbra_service(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
	echo "Starting $1"
	docker compose up -d
	#docker compose -u "$(id -u):$(id -g)" up -d

	popd
}
export -f start_umbra_service

function stop_umbra_service(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
	echo "Stopping $1"
	docker compose down --remove-orphans

	popd
}
export -f stop_umbra_service

function restart_umbra_service(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
	docker compose down &&
	docker compose up -d --remove-orphans

	popd
}
export -f restart_umbra_service

SERVICE_INIT_ORDER=( 
"PiHole"
"Nginx"
"Portainer"
"Dozzle"
"UptimeKuma"
#"Grafana"
"HomePage"
"Trilium"
"JellyFin"
"Plex"
"VaultWarden"
)
declare -a SERVICE_INIT_ORDER
function start_umbra_services(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
	for dir in ${SERVICE_INIT_ORDER[@]}; do
		start_umbra_service ${dir}
	done

	popd
}
export -f start_umbra_services

function stop_umbra_services(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
	for dir in ${SERVICE_INIT_ORDER[@]}; do
		stop_umbra_service ${dir}
	done

	popd
}
export -f stop_umbra_services

function restart_umbra_services(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
	for dir in ${SERVICE_INIT_ORDER[@]}; do
		echo "Starting $dir"
		restart_umbra_service ${dir}
	done

	popd
}
export -f restart_umbra_services
