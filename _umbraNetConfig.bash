#!/usr/bin/bash
# Name: UmbraNetConfig ( Master config script )
# Author: NLeach
# Date: 02/03/2020
# Version: 1.0
# Description:
#	Master config script for the 'UmbraNet' system.
#	Defines basic global functionality and updates
#	tool paths appropriately
#



#Getting the absolute path of this script....
#you have no idea how much effort this took....
function umb_rootPath(){
	echo $(readlink -f ${BASH_SOURCE})
}

#Gets the absolute path of whatever script
#calls it. This is the easiest and cleanest
#way i can think of to get the called script's
#reference point
function umb_realPath(){
	_r=$(dirname $0)
	echo $_r
	#echo $( readlink -f $(_r) )
}
export -f umb_realPath

_rootPath=$(umb_rootPath) 
#echo "ROOT PATH: $_rootPath"

#Find a file
function umb_findFile(){
	find -L $1 -mindepth 1 -type f -iname "*$2*"
}
export -f umb_findFile

#Find a directory 
function umb_findDir(){
	find -L $1 -mindepth 1 -type d -iname "*$2*"
}
export -f umb_findDir

#Find any source files in a given directory
function umb_findSource(){
	find -L "$1" -mindepth 1 -type f -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp"
}
export -f umb_findSource

#Find any text files
function umb_findText(){
	find -L "$1" -mindepth 1 -type f -iname "*txt" -o -iname "*.c" -o -iname "*.h" -o -iname "*.cpp"
}
export -f umb_findText

#Find any text files
function umb_findTextAll(){
	find -L "$1" -mindepth 1 -type f -not -empty
}
export -f umb_findTextAll

#Find any image files
function umb_findImage(){
	find -L "$1" -mindepth 1 -type f -iname "*.png" -o -iname "*.jpg"
}
export -f umb_findImage

export UMB_DIE_ON_ERRORS="false"

#Handy function to grab the extension of a file
function umb_getExtension(){
	_fn=$(basename -- $1)
	_ext=${_fn##*.}
	echo $_ext
}
export -f umb_getExtension

#Check the return value of the last command
function umb_checkReturn(){
	if [ "$?" -ne "0" ]; then

		if [ ! -z "$2" ];then
			echo -e "\e[90mUmbraNet::\e[33m$2\e[0m"			
		else		
			echo -e "\e[90mUmbraNet::\e[33mNon Zero Return\e[0m"
		fi
			
		if [ "${UMB_DIE_ON_ERRORS}" -eq "true"]; then
			exit 1
		fi 

	else
		if [ ! -z "$1" ]; then
			echo -e "\e[90mUmbraNet::\e[32m$1\e[0m"
		fi
	fi 
}
export -f umb_checkReturn

#Parse all commonly-recognized arguments
#TODO: 4/21/2020: This needs to process the argument list
#			without consuming the arguments before the
#			callling script can process them
export UMB_ARGLIST=":hd:f:r:"
function umb_parseArgs(){
	_argSet=$@
	echo -e "\e[90UmbraNet::\e[33mParsing Common Umbra Args...\e[0m"
	_argDescription="
		[-d true|false] [-f <file_path>]

		-d	Debug Toggle
		-f 	Input File Path(s)
	"
	while getopts $UMB_ARGLIST opt; do
		case ${opt} in

			d )	
				if [ "$UMB_DEBUG" == "true" ]; then
					echo "UmbraNet::Setting UMB_DEBUG to $OPTARG"
				fi
				export UMB_DEBUG=$OPTARG
				;;
			f )
				if [ "$UMB_DEBUG" == "true" ]; then
					echo "UmbraNet::Setting UMB_ARG_FPATH Path to $OPTARG"
				fi
				if [ ! -f "$OPTARG" ]; then
					echo "UmbraNetERROR::File Path Not Valid. Exiting."
					exit
				fi	
				export UMB_ARG_FPATH=$OPTARG
				;;
			h )
				if [ -z "$UMB_ARG_DESC" ]; then
					echo "UmbraNet::No Description stored in UMB_ARG_DESC envvar"
				else 	
					echo "
						$UMB_ARG_DESC
						$_argDescription
					"
				fi
				exit
				;;
			r ) 
				if [ "$UMB_DEBUG" == "true" ]; then
					echo "UmbraNet::UMB_ARG_RETRAIN set to $OPTARG"
				fi
				export UMB_ARG_RETRAIN=$OPTARG
				;;
			\? )
				echo "UmbraNet::Unrecognized Arg"
				;;
		esac
	done
	
	#Reset the arg list so the calling script can
	#Parse it for additional arguments
	set -- "$_argSet"
	export OPTIND=1 #If this isn't reset to 1, 'getopts' wont run anymore
}
export -f umb_parseArgs

#Setting important script/model locations
export UMB_NET_ROOT="$( dirname $_rootPath )"
export UMB_MODEL_ROOT="${UMB_NET_ROOT}/Models"
export UMB_UTIL_ROOT="${UMB_NET_ROOT}/NN_Util"
export UMB_TEST_ROOT="${UMB_NET_ROOT}/Tests"
export UMB_DATA_ROOT="${UMB_NET_ROOT}/DataSets"

#Other important settings
#export UMB_UCC_ROOT=${UMB_NET_ROOT}/_Projects/UmbraCC




#Add the Utility Directory to the system path
_path=$PATH:$UMB_NET_ROOT
_path=$_path:$UMB_MODEL_ROOT
_path=$_path:$UMB_UTIL_ROOT/bin
# Usually, all scripts would be soft-linked into 
# the bin folder, but as long as my dev folder is
# a docker volume i can't use links
_path=$_path:$UMB_UTIL_ROOT/UmbraWebScraper
_path=$_path:$UMB_TEST_ROOT

export PATH=$_path

if [ "$UMB_DEBUG" == "true" ];then
	echo -e "
		\e[90mUmbraNet::\e[37m UPDATED SYSTEM PATH:\e[94m $PATH\e[0m
	"
fi


#Copy the altered path to PYTHONPATH,
#so i can access necessary modules
export PYTHONPATH=$_path

if [ "$UMB_DEBUG" == "true" ]; then
	echo -e "
		\e[90mUmbraNet::\e[37m Python Path envvar set to:\e[94m $PYTHONPATH\e[0m
	"
fi
