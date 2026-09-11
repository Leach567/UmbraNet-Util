. /repos/UmbraNet-Util/docker/docker_env_config.umbra.bash
. /repos/UmbraNet-Util/umbraScriptUtil.config.bash

#UMBRA_BACKUP_DIR="/mnt/WorkshopShare/Umbra-Blade_Backups/Service_Backups"
UMBRA_BACKUP_DIR="/home/umbra/Umbra-Blade_Backups/Service_Backups"
UMBRA_SECONDARY_BACKUP_DIR=""
UMBRA_BACKUP_FILENAME=".umbra_backup.json"

Print "${TIME_ZULU} - Starting Umbra Service Backup Script..."
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
	pushd ${SERVICE_REPO_ROOT}/${dir} > /dev/null

	# If no backup json file is found, generate a new one
	if [[ ! -f "./${UMBRA_BACKUP_FILENAME}" ]]; then
		Print "Unable to find ${UMBRA_BACKUP_FILENAME} in the current dir. Creating one and filling it with template data."
		Print "Be sure to fill it out before the next run of this script"
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
		

		# Parsing json data from the backup file
		data=`FILE=${UMBRA_BACKUP_FILENAME} python3 -c 'import json,os; print(json.load(open(os.environ["FILE"]))["data"])'`
		pkg_name=`FILE=${UMBRA_BACKUP_FILENAME} python3 -c 'import json,os; print(json.load(open(os.environ["FILE"]))["data"]["package-name"])'`
		paths=`FILE=${UMBRA_BACKUP_FILENAME} python3 -c 'import json,os; [print(p, end=" ") for p in json.load(open(os.environ["FILE"]))["data"]["paths"]]'`
		
		# DBG
		PrintDbg "${data}"
		
		# Integrity Checking
		if [[ -z "${pkg_name}" ]]; then
			PrintErr "Invalid package name found in ${UMBRA_BACKUP_FILENAME}."
			exit 1
		fi
		if [[ ${#paths[@]} -lt 1 ]]; then
			PrintErr "No paths found for backup. Ensure that the paths in ${UMBRA_BACKUP_FILENAME} are valid."
			exit 1
		fi

		Print "Found backup data..."
		Print "\tPackage Name: ${BRIGHT_RED}${pkg_name}${RESET}"
		Print "\t\tStripped paths: ${ITALIC}${BRIGHT_MAGENTA}${paths}${RESET}"

		# Turn on verbose ouput if DEBUG is set to 1
		if [[ "$DEBUG" == "1" ]]; then
			backup_command="tar -czf ${UMBRA_BACKUP_DIR}/${dir}/${pkg_name}__${DATE_STAMP}.tgz ${paths}"
		else
			backup_command="tar -cvzf ${UMBRA_BACKUP_DIR}/${dir}/${pkg_name}__${DATE_STAMP}.tgz ${paths}"
		fi
		
		Print "sudo mkdir -p ${UMBRA_BACKUP_DIR}/${dir}"
		sudo mkdir -p ${UMBRA_BACKUP_DIR}/${dir}
		Print "sudo ${backup_command}"
		sudo ${backup_command}
		Print "sudo ln -fs ${UMBRA_BACKUP_DIR}/${dir}/${pkg_name}__${DATE_STAMP}.tgz ${UMBRA_BACKUP_DIR}/${dir}/${pkg_name}_latest"
		sudo ln -fs ${pkg_name}__${DATE_STAMP}.tgz ${UMBRA_BACKUP_DIR}/${dir}/${pkg_name}_latest
	fi
	popd > /dev/null

	
done

if [[ -d "${UMBRA_SECONDARY_BACKUP_DIR}" ]]; then
	Print "${BRIGHT_YELLOW}Cloning latest backups to secondary backup location...${RESET}"
	Print "\t Secondary Backup Dir: ${BRIGHT_CYAN}${UMBRA_SECONDARY_BACKUP_DIR}${RESET}"
	Print "cp -vrL ${UMBRA_BACKUP_DIR}/*/*_latest ${UMBRA_SECONDARY_BACKUP_DIR}"
	sudo cp -vrfL ${UMBRA_BACKUP_DIR}/*/*_latest ${UMBRA_SECONDARY_BACKUP_DIR}
fi
