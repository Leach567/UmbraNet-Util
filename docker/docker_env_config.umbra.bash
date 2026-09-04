#!/bin/bash
SERVICE_REPO_ROOT="/repos/UmbraNet-Util/docker"
function force_reset_docker(){
	sudo systemctl stop docker
	sudo rm -f /var/lib/docker/network/files/local-kv.db
	sudo systemctl start docker
}
export -f force_reset_docker

function start_umbra_service(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
	echo "Starting $1"
	docker compose up -d

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
"Dozzle"
"UptimeKuma"
"HomePage"
"Trillium"
"JellyFin"
"Plex"
"VSCode"
"HomeAssistant"
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
