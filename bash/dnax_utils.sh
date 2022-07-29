#!/bin/bash


raise_error() {
  >&2 echo -e "Error: $1. Exiting." && exit 1
}

upload_file() {
	local _script_local=$1
	local _script_dnax=$2

	file_ct=$( dx ls -l --obj "${_script_dnax}" 2> /dev/null | wc -l )
	if [ ${file_ct} -ge 1 ]; then
		dx mv "${_script_dnax}" "${_script_dnax}-tmp" \
		&& dx upload "${_script_local}" --path "${_script_dnax}" --brief  \
		&& dx rm --force "${_script_dnax}-tmp" \
		|| raise_error "Uploading ${_script_local} failed!"
	else
		dx upload "${_script_local}" --path "${_script_dnax}" --brief \
		|| raise_error "Uploading ${_script_local} failed!"
	fi
}

# 2> /dev/null

