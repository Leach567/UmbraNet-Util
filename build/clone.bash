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
find $_sourceDir -mindepth 1 -type f | xargs -I% ln -fs % $_destDir
#echo $?

#Copy only the folder names
source_dirs=`find $_sourceDir -mindepth 1 -type d`
echo $source_dirs | tr ' ' '\n' | \
xargs -I% basename % | \
xargs -I% mkdir -p $_destDir/%

#Run the script again recursively
#on all child directories
#echo $source_dirs | tr ' ' '\n' | \
#xargs -I% readlink -f % | \
#xargs -I% echo $BASH_SOURCE % $_destDir/`basename %` #| bash
for _src in $source_dirs
do
    #echo $_src
    _destSubDir=`basename $_src`
    echo "$BASH_SOURCE $_src $_destDir/$_destSubDir" | bash
done

echo "Clone is done."