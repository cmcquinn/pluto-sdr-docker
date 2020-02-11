#!/usr/bin/env bash
docker build -v "${HOME}/.ccache:/ccache" -e CCACHE_DIR=/ccache -t cmcquinn/pluto-sdr-docker -f ./Dockerfile .