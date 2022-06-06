#!/bin/bash
# shelcheck ignore=SC2162,SC2015

[[ "$1" != "" ]] && BRANCH="$1" || BRANCH=main
[[ "$BRANCH" == "main" ]] && TAG="latest" || TAG="$BRANCH"
[[ "$ARCHS" == "" ]] && ARCHS="linux/386,linux/amd64,linux/arm/v7,linux/arm/v6,linux/arm64"

BASETARGET1=ghcr.io/kx1t
BASETARGET2=kx1t

SECONDARG="$2"

#IMAGE1="$BASETARGET1/$(pwd | sed -n 's|.*/docker-\(.*\)|\1|p'):$TAG"
#IMAGE2="$BASETARGET2/$(pwd | sed -n 's|.*/docker-\(.*\)|\1|p'):$TAG"

IMAGE1="$BASETARGET1/${PWD##*/}:$TAG"
IMAGE2="$BASETARGET2/${PWD##*/}:$TAG"

echo "press enter to start building $IMAGE1 and $IMAGE2 from $BRANCH"
read

starttime="$(date +%s)"
# rebuild the container
if [[ "${SECONDARG,,}" != "nopull" ]]
then
	git checkout "$BRANCH" || exit 2
	git pull -a
else
	SECONDARG=""
fi

docker buildx build --compress --push "$SECONDARG" --platform "$ARCHS" --tag "$IMAGE1" .
[[ "$?" == "0" ]] && docker buildx build --compress --push "$SECONDARG" --platform "$ARCHS" --tag "$IMAGE2" .

echo "Total build time: $(( $(date +%s) - starttime )) seconds"
