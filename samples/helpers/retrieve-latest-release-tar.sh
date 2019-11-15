#! /bin/bash
USER=$1
REPO=$2

LATEST_URL=https://api.github.com/repos/$USER/$REPO/releases/latest

TAR_URL=$(curl -s $LATEST_URL | grep tarball_url | cut -d\" -f 4)

echo -n $TAR_URL
