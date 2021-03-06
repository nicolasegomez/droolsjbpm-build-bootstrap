#!/bin/bash

# Run a mvn command on all droolsjbpm repositories.

initializeWorkingDirAndScriptDir() {
    # Set working directory and remove all symbolic links
    workingDir=`pwd -P`

    # Go the script directory
    cd `dirname $0`
    # If the file itself is a symbolic link (ignoring parent directory links), then follow that link recursively
    # Note that scriptDir=`pwd -P` does not do that and cannot cope with a link directly to the file
    scriptFileBasename=`basename $0`
    while [ -L "$scriptFileBasename" ] ; do
        scriptFileBasename=`readlink $scriptFileBasename` # Follow the link
        cd `dirname $scriptFileBasename`
        scriptFileBasename=`basename $scriptFileBasename`
    done
    # Set script directory and remove other symbolic links (parent directory links)
    scriptDir=`pwd -P`
}
initializeWorkingDirAndScriptDir
droolsjbpmOrganizationDir="$scriptDir/../.."
withoutJbpm="$withoutJbpm"
# withoutUberfire="$withoutUberfire"

if [ $# = 0 ] ; then
    echo
    echo "Usage:"
    echo "  $0 [arguments of mvn]"
    echo "For example:"
    echo "  $0 --version"
    echo "  $0 -DskipTests clean install"
    echo "  $0 -Dfull clean install"
    echo
    exit 1
fi

startDateTime=`date +%s`

cd "$droolsjbpmOrganizationDir"

for repository in `cat "${scriptDir}/repository-list.txt"` ; do
    echo
    if [ ! -d "$droolsjbpmOrganizationDir/$repository" ]; then
        echo "==============================================================================="
        echo "Missing Repository: $repository. SKIPPING!"
        echo "==============================================================================="
    elif [ "${repository}" != "${repository#jbpm}" ] && [ "$withoutJbpm" = 'true' ]; then
        echo "==============================================================================="
        echo "Without repository: $repository. SKIPPING!"
        echo "==============================================================================="
    elif [ "${repository}" != "${repository#jbpm-console-ng}" ] && [ "$withoutJbpm" = 'true' ]; then
        echo "==============================================================================="
        echo "Without repository: $repository. SKIPPING!"
        echo "==============================================================================="

    # uberfire is not build anymor on master-branch
    #elif [ "${repository}" != "${repository#uberfire}" ] && [ "$withoutUberfire" = 'true' ]; then
    #    echo "==============================================================================="
    #    echo "Without repository: $repository. SKIPPING!"
    #    echo "==============================================================================="
    
else
        echo "==============================================================================="
        echo "Repository: $repository"
        echo "==============================================================================="
        cd $repository

        if [ -a $M3_HOME/bin/mvn ] ; then
            $M3_HOME/bin/mvn "$@"
        else
            mvn "$@"
        fi

        returnCode=$?
        cd ..
        if [ $returnCode != 0 ] ; then
            exit $returnCode
        fi
    fi
done

endDateTime=`date +%s`
spentSeconds=`expr $endDateTime - $startDateTime`

echo
echo "Total time: ${spentSeconds}s"
