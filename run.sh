#!/bin/sh
BUILD_DIR=/build
SCRIPTS_DIR=/scripts

VALID_PATTERN=amazonlinux-
DOCKER_BASE_IMAGE=amazonlinux-latest

if [ $# -ne 0 ]; then
    DOCKER_BASE_IMAGE=$1
fi

DOCKER_TAG=`echo $DOCKER_BASE_IMAGE | sed "s/$VALID_PATTERN//"`

echo "USING TAG: $DOCKER_TAG"

validate_input () {
    if [[ $DOCKER_BASE_IMAGE != $VALID_PATTERN* ]]; then
        echo "bad argument: $1, need start with $VALID_PATTERN*"
        exit 1
    fi

    if ! [ -d $DOCKER_BASE_IMAGE ]; then
        echo "bad argument: $1, is not a valid option"
        exit 1
    fi
}

docker_build () {
    docker volume create sox-build-$DOCKER_TAG
    docker build --build-arg BUILD_DIR=$BUILD_DIR --build-arg SCRIPTS_DIR=$SCRIPTS_DIR -f $DOCKER_BASE_IMAGE/Dockerfile -t vnator/aws-lambda-compiler:$DOCKER_TAG .
}

docker_run () {
    docker run -v $(pwd)/scripts:$SCRIPTS_DIR -v sox-build-$DOCKER_TAG:$BUILD_DIR --name soxcontainer_$DOCKER_TAG vnator/aws-lambda-compiler:$DOCKER_TAG
}
docker_start () {
    docker start -i soxcontainer_$DOCKER_TAG
}

docker_exist_container () {
    # return 1 if nonexistent
    # return 0 if exists
    container_counter=`docker ps -a -q -f name=soxcontainer_$DOCKER_TAG | wc -l`
    if [ $? -eq 0 -a $container_counter -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

docker_rm_container () {
    docker_exist_container
    if [ $? -eq 0 ]; then
        docker rm soxcontainer_$DOCKER_TAG
    fi
}

install_sox () {
    docker cp soxcontainer_$DOCKER_TAG:$BUILD_DIR/bin . && echo "Binary available in bin directory"
}

docker_clean () {
    docker_rm_container
    docker rmi -f vnator/aws-lambda-compiler:$DOCKER_TAG
}

update_image () {
    docker_rm_container && \
    docker_build && \
    docker_run && \
    install_sox
}

use_previous_image () {
    docker_exist_container
    if [ $? -eq 0 ]; then
        docker_start && \
        install_sox
    else
        update_image
    fi
}

validate_input

if [ $# -lt 2 ]; then
    use_previous_image
elif [ $2 = "update" ]; then
    update_image
elif [ $2 = "install" ]; then
    install_sox
elif [ $2 = "clean" ]; then
    docker_clean
else
    echo "bad argument: $2"
    exit 1
fi

exit 0
