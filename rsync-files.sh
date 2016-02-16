#!/bin/bash
set -e
# Description: Copy specific list of files from SOURCE/ to DESTINATION/.
# Usage: this_script.sh <ACTION> <SOURCE_DIR> <DESTINATION_DIR> [FILE_LIST]
#   [FILE_LIST] is optional.

ACTION=$1
SOURCE_DIR=$2
DEST_DIR=$3
FILE_LIST=$4

FILES_FROM_OPTION=""

# Error handling
  CMD_EXAMPLES=$(printf " %s\n %s\n %s\n" \
                        " e.g. $0 <ACTION> <SOURCE_DIR> <DESTINATION_DIR> [FILE_LIST]"\
                        " e.g. $0 try    /some/source/ /some/destination/"\
                        " e.g. $0 commit /some/source/ /some/destination/ exclude.txt"\
                )
	if [ -z "${ACTION}" ]; then
	  echo "$0: Error: Action can't be empty. Aborted!"
	  echo "${CMD_EXAMPLES}"
	  exit 1;
	fi
	
	if [ ! -d "${SOURCE_DIR}" ]; then
	  echo "$0: Error: Source directory: ${SOURCE_DIR}: no such directory. Aborted!"
	  echo "${CMD_EXAMPLES}"
	  exit 1;
	fi
	
	if [ ! -d "${DEST_DIR}" ]; then
	  echo "$0: Error: Destination directory: ${DEST_DIR}: no such directory. Aborted!"
	  echo "${CMD_EXAMPLES}"
	  exit 1;
	fi
	
	if [ ! -z "${FILE_LIST}" ]; then
		if [ ! -f "${FILE_LIST}" ]; then
		  echo "$0: Error: Specific file list: ${FILE_LIST}: no such file. Aborted!"
		  echo "${CMD_EXAMPLES}"
		  exit 1;
		else
		  # Construct exclude option.
		  FILES_FROM_OPTION="--files-from=${FILE_LIST}"	
		  FILE_LIST=$(readlink -ev "${FILE_LIST}")
	  fi
	fi
	
	SOURCE_DIR=$(readlink -ev "${SOURCE_DIR}")
	DEST_DIR=$(readlink -ev "${DEST_DIR}")


# Rsync
DATE_STRING=$(date +"%Y-%m-%d_%0k.%M.%S")
case "${ACTION}" in
  
  commit)
    # Really commit deployment. 
    rsync -a --checksum --progress --itemize-changes --stats --out-format='%i %n %M %l' "${FILES_FROM_OPTION}" "${SOURCE_DIR}/" "${DEST_DIR}/"
    ;;
    
  try)
    rsync -a --checksum --progress --itemize-changes --stats --out-format='%i %n %M %l' --dry-run "${FILES_FROM_OPTION}" "${SOURCE_DIR}/" "${DEST_DIR}/"
    ;;
    
  *)
    echo "Error: Unknown action: ${ACTION}. Aborted!"
    echo "${CMD_EXAMPLES}"
    exit 1
    ;;    
esac
