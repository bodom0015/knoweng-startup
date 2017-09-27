#!/bin/bash

docker run -it --rm --privileged -v $HOME/.docker:/root/.docker -v /var/run/docker.sock:/var/run/docker.sock -v /home/ubuntu/ndslabs-knoweng:/workdir -w /workdir docker/compose:1.15.0 "$@"
