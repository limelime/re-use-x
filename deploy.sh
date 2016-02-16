#!/bin/bash
set -e
# Description: Copy from SOURCE/ to DESTINATION/ and delete extraneous files from the receiving side. 

SOURCE_DIR=$1
DEST_DIR=$2
EXCLUDE_LIST=$2

EXCLUDE_FROM_OPTION=""
# Error handling
if [ ! -d "${SOURCE_DIR}" ]; then
  echo "$0: Error: Source directory: ${SOURCE_DIR}: no such directory. Aborted!"
  exit 1;
fi

if [ ! -d "${DEST_DIR}" ]; then
  echo "$0: Error: Destination directory: ${DEST_DIR}: no such directory. Aborted!"
  exit 1;
fi

if [ ! -z "${EXCLUDE_LIST}" ]; then
	if [ ! -f "${EXCLUDE_LIST}" ]; then
	  echo "$0: Error: Exclude list: ${EXCLUDE_LIST}: no such file. Aborted!"
	  exit 1;
	fi
fi

SOURCE_DIR=$(readlink -ev "${SOURCE_DIR}")
DEST_DIR=$(readlink -ev "${DEST_DIR}")
EXCLUDE_LIST=$(readlink -ev "${EXCLUDE_LIST}")


# Construct exclude option.
EXCLUDE_FROM_OPTION="--exclude-from=${EXCLUDE_LIST}"

# Create deploy log directory.
DEPLOY_LOG_DIR="./deploy_logs"
mkdir -p "${DEPLOY_LOG_DIR}"
DEPLOY_LOG_DIR=$(readlink -ev "${DEPLOY_LOG_DIR}")

# Deploy
DATE_STRING=$(date +"%Y-%m-%d_%0k.%M.%S")
ACTION=$1
case "${ACTION}" in
  
  commit)
    # Really commit deployment. 
    rsync -a --checksum --delete-after --progress --itemize-changes --stats --out-format='%t %p %i %n %M %l' "${EXCLUDE_FROM_OPTION}" "${SOURCE_DIR}/" "${DEST_DIR}/" > "${DEPLOY_LOG_DIR}/deploy_${DATE_STRING}.log"
    ;;
    
  *)
    rsync -a --checksum --delete-after --progress --itemize-changes --stats --out-format='%t %p %i %n %M %l' --dry-run "${EXCLUDE_FROM_OPTION}" "${SOURCE_DIR}/" "${DEST_DIR}/"
    ;;
esac

echo "Deployment log created at ${DEPLOY_LOG_DIR}/deploy_${DATE_STRING}.log."