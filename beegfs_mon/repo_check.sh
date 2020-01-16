#!/bin/bash
set -euo pipefail
echo "[repo_check.sh] Attempting to run apt-get update and apt-get install iputils-ping to check if we're in an air-gapped environment."
if apt-get update && apt-get install -y iputils-ping;
then
    echo "[repo_check.sh] Successfully installed iputils-ping, leaving default Ubuntu repositories in place. Adding default BeeGFS repository."
    cp beegfs-deb9.list /etc/apt/sources.list.d/beegfs-deb9.list
    exit 0
fi

echo "[repo_check.sh] Unable to reach default Ubuntu repositories, updating source.list with repository mirrors."
cp repomirror_sources.list /etc/apt/sources.list

echo "[repo_check.sh] Attempting to run apt-get update and apt-get install iputils-ping to confirm connectivity to repository mirrors."
if apt-get update && apt-get install -y iputils-ping;
then
    echo "[repo_check.sh] Successfully installed iputils-ping from repository mirrors. Adding BeeGFS repository mirror."
    cp repomirror_beegfs-deb9.list /etc/apt/sources.list.d/beegfs-deb9.list
    exit 0
else
    echo "[repo_check.sh] Unable to install iputils-ping from repository mirrors. Are the URLs specified in in the repomirror_*.list files correct for your environment?"
    exit 1
fi