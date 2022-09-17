#!/usr/bin/bash
_sourceDir=`readlink -f $1`
_destDir=`readlink -f $2`

if [ ! -d $_sourceDir ] 
then
    echo "Source Not a dir"
    exit 1
fi

if [ ! -d $_destDir ] 
then
    echo "Dest Not a dir"
    exit 1
fi
echo "Cloning from $_sourceDir to $_destDir"
#Soft-link all the flat files
#Using min and max depth args to confine it to the current directory
_files=`find $_sourceDir -mindepth 1 -maxdepth 1 -type f -not -wholename "*.git*"`
_fileCount=`echo $_files | tr ' ' '\n' | wc -l`
for _file in $_files
do
    ln -fs $_file $_destDir
done
echo -e "\tLinked $_fileCount files."

#Gather a list of all child folders on the current level only
source_dirs=`find $_sourceDir -mindepth 1 -maxdepth 1 -type d -not -wholename '*.git*'`

#Prep the child directories, create their
#mirrors in the destination directory
for _dir in $source_dirs
do
    _base=`basename $_dir`
    echo -e "\tNew folder basename: $_destDir/$_base"
    mkdir -p $_destDir/$_base
done

#Run the script again recursively
#on all child directories
#echo $source_dirs | tr ' ' '\n' | \
#xargs -I% readlink -f % | \
#xargs -I% echo $BASH_SOURCE % $_destDir/`basename %` #| bash

echo -e "\n"
for _src in $source_dirs
do
    #echo $_src
    _destSubDir=`basename $_src`
    echo "$BASH_SOURCE $_src $_destDir/$_destSubDir" | bash
done

echo "Clone is done."