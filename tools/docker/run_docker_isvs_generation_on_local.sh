#!/bin/bash

# NOTE: You can run this script on your local machine e.g. macOS where Docker is installed.

set -euo pipefail

if [ -z ${1+x} ]
then
      VERSION="DEMO"
else
      VERSION=$1
fi

echo "Version = ${VERSION}"

# Note: eventually ,we need to upload a version of the docker container,
# similar to the MASVS project's (see code below):
#export IMG="owasp/masvs-docgenerator:0.2"
#docker pull $IMG

# For now, we are using the local dockerfile
#only use this when you are updating the docker tooling
export IMG="owasp/isvs-docgenerator:latest2"
if [[ "$(docker images -q $IMG 2> /dev/null)" == "" ]]; then
   docker build --tag $IMG tools/docker/
fi

# If more languages are added, update this part of the code
for folder in ./en; do
  echo "Generating $folder"
  [ -f $folder-temp ] && rm -rf $folder-temp
  cp -r $folder $folder-temp
  docker run --rm -u `id -u`:`id -g` -v ${PWD}:/pandoc $IMG "/pandoc_makedocs.sh $folder-temp ${VERSION}" || echo "$folder failed" &

done

wait

echo "Cleaning up"
for folder in Document*; do
    if [ -d "$folder-temp" ]; then 
        rm -Rf $folder-temp
    fi
done

# --- Below MASVS code for Persian conversion, reinstate if Persian translation added

#echo "Do Persian PDF conversion with a small hack"
#mkdir /tmp/unoconv && cp OWASP_MASVS-SNAPSHOT-fa_WIP_.docx /tmp/unoconv/ && \
#docker run -d -e FILEEXT=docx -e TIMETOEXIT=300 -v /tmp/unoconv:/tmp --name unoconv sfoxdev/unoconv-alpine && \
#sleep 10s && \
#cp /tmp/unoconv/OWASP_MASVS-SNAPSHOT-fa_WIP_.pdf .

#echo "Cleanup"
#rm -rf /tmp/unoconv
#docker container rm unoconv