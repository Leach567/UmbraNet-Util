#!/bin/bash
SERVICE_REPO_ROOT="/repos/UmbraNet-Util/docker"
function start_umbra_service(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
	docker compose up -d

	popd
}
export -f start_umbra_service

function stop_umbra_service(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
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
"UptimeKuma"
"HomePage"
"Dozzle"
"Nginx"
"Trillium"
"JellyFin"
"HomeAssistant"
"VaultWarden"
)
declare -a SERVICE_INIT_ORDER
function start_umbra_services(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
	for dir in ${SERVICE_INIT_ORDER[@]}; do
		echo "Starting $dir"
		#start_umbra_service ${dir}
	done

	popd
}
export -f start_umbra_services

function restart_umbra_services(){
	pushd ${SERVICE_REPO_ROOT}/$1
	
	for dir in ${SERVICE_INIT_ORDER[@]}; do
		echo "Starting $dir"
		restart_umbra_service ${dir}
	done

	popd
}
export -f restart_umbra_services
