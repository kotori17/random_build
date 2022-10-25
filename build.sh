#!/bin/bash
export ci_secret
branch="6.0/master"
export branch
docker build . -t build_zen
docker run --env ci_secret="$ci_secret" --env branch="$branch" build_zen
