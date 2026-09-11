. ./docker_env_config.umbra.bash
. ../umbraScriptUtil.config.bash

UMBRA_BACKUP_DIR="/mnt/WorkshopShare/Umbra-Blade_Backups/Service_Backups"
UMBRA_BACKUP_FILENAME=".umbra_backup.json"

PrintCaller
Print "Gathering Service Backup Targets..."
PrintDbg "Services:\n\t${BRIGHT_GREEN}${SERVICE_INIT_ORDER[*]}${RESET}"

# Verify that the list is populated
if [[ ${#SERVICE_INIT_ORDER[@]} -lt 1 ]]; then
	PrintErr "No service list found. Ensure that \$SERVICE_INIT_ORDER is defined."
	exit 1
fi

# Begin going through the service dirs and search for the required files
for dir in ${SERVICE_INIT_ORDER[@]}; do
	Print "Preparing to backup ${BOLD}${UNDERLINE}${BRIGHT_GREEN}${dir}${RESET}..."
	pushd ${SERVICE_REPO_ROOT}/${dir}

	# If no backup json file is found, generate a new one
	if [[ ! -f "./${UMBRA_BACKUP_FILENAME}" ]]; then
		Print "Unable to find ${UMBRA_BACKUP_FILENAME} in the current dir. Creating one and filling it with template data"
		echo '{
	"data": {
		"package-name": "tar-package-name",
		"paths": [
			"path/to/data",
			"path/to/data"
		]
	}
}
		' >> ${UMBRA_BACKUP_FILENAME}
	# If the backup json is found, verify the most recent backup, and proceed if needed
	else
		Print "Found backup data..."
		data=`FILE=${UMBRA_BACKUP_FILENAME} python3 -c 'import json,os; print(json.load(open(os.environ["FILE"]))["data"])'`
		pkg_name=`FILE=${UMBRA_BACKUP_FILENAME} python3 -c 'import json,os; print(json.load(open(os.environ["FILE"]))["data"]["package-name"])'`
		paths=`FILE=${UMBRA_BACKUP_FILENAME} python3 -c 'import json,os; [print(p, end=" ") for p in json.load(open(os.environ["FILE"]))["data"]["paths"]]'`
		PrintDbg "${data}"
		Print "\tPackage Name: ${LIGHT_CYAN}${pkg_name}${RESET}"
		Print "\t\tStripped paths: ${LIGHT_GREEN}${paths}${RESET}"
		
		# TODO: Integrity Checking

		backup_command="tar -xvzf ${UMBRA_BACKUP_DIR}/${dir}/${pkg_name}__${DATE_STAMP}.tgz ${paths}"
		Print "mkdir -p ${UMBRA_BACKUP_DIR}/${dir}"
		Print "${backup_command}"
	fi
	popd
done
