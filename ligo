#!/bin/sh
docker run --user=`id -u` -v $PWD:$PWD -w $PWD ligolang/ligo:next "$@"