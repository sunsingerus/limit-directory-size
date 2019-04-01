#!/bin/bash

# directory to limit and size limit
DIR=""
DIR_SIZE_LIMIT=""

# how many files to delete on each loop
# the lower this number is - more precisly size limit is applied, but the script requires more iterations
# the greater this number is - less precisely size limit is applied, but the script requires less iterations
FILES_NUMBER_TO_DEL="3"

# directory to limit and size limit provieded as ENV var
ENV_DIR="${DIR:-}"
ENV_DIR_SIZE_LIMIT="${DIR_SIZE_LIMIT:-}"
ENV_FILES_NUMBER_TO_DEL="${FILES_NUMBER_TO_DEL:-}"

# directory to limit and size limit provided as CLI option
CLI_DIR="$1"
CLI_DIR_SIZE_LIMIT="$2"
CLI_FILES_NUMBER_TO_DEL="$3"

# appli CLI or ENV values to vars
if [ -n "$CLI_DIR" ]; then
	# directory explicitly specified as CLI option
	DIR=$CLI_DIR
else if [ -n "$ENV_DIR" ]; then
	# CLI option is empty, but directory is explicitly specified as ENV var
	DIR=$ENV_DIR
else
	# neither CLI nor ENV var provided, can't continue
	echo "Please specify directory to limit either as param or as ENV var"
	exit 1
fi

if [ -n "$CLI_DIR_SIZE_LIMIT" ]; then
	# directory size limit explicitly specified as CLI option
	DIR_SIZE_LIMIT=$CLI_DIR_SIZE_LIMIT
else if [ -n "$ENV_DIR_SIZE_LIMIT" ]; then
	# CLI option is empty, but directory size limit is explicitly specified as ENV var
	DIR_SIZE_LIMIT=$ENV_DIR_SIZE_LIMIT
else
	# neither CLI nor ENV var provided, can't continue
	echo "Please specify directory size limit either as param or as ENV var"
	exit 2
fi

if [ -n "$CLI_FILES_NUMBER_TO_DEL" ]; then
	# files number to del explicitly specified as CLI option
	FILES_NUMBER_TO_DEL=$CLI_FILES_NUMBER_TO_DEL
else if [ -n "$ENV_FILES_NUMBER_TO_DEL" ]; then
	# CLI option is empty, but files number to del is explicitly specified as ENV var
	FILES_NUMBER_TO_DEL=$ENV_FILES_NUMBER_TO_DEL
else
	# neither CLI nor ENV var provided, use default value
fi

# run limit loop

# directory size in megabytes
DIR_SIZE=$(du -sm "$DIR" | cut -f1)
while [ "$DIR_SIZE" -gt "$DIR_SIZE_LIMIT" ]; do
	# find files and rm oldest ones
	find $DIR -type f -printf "%T@ %p\n" | sort -nr | tail -$FILES_NUMBER_TO_DEL | cut -d' ' -f 2- | xargs rm
	# delete empty dirs
	find $DIR -type d -empty -delete
	# directory size in megabytes
	DIR_SIZE=$(du -sm "$DIR" | cut -f1)
done

