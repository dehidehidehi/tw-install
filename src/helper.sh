#!/bin/bash
write_to_log() {

  # read incoming arguments
  local dest_dir="$1"
  local dest_file="$2"
  local dest_path="$dest_dir$dest_file"

  shift # eat first argument
  shift # eat second argument

  # create empty file (overwrite previous content if it exists)
  : >"$dest_path"

  # append remaining args to file
  for i in '$*'; do
    cat echo "$i" >>"$dest_path"
  done
}

remove_logs() {
	{ # try
		$rm -r src/logs/*
		#save your output
		true
	} || { # catch
		# save log for exception 
		true
	}
}

read_user_key_from_log() {
  local value="$(<src/logs/D_26_add_user_to_taskserver.txt)"
  local result=${value:14:36}
  echo "$result"
}

swap_line_containing_string() {
  local old_line_pattern=$1; shift
  local new_line=$1; shift
  local file=$1
  local new;
  new=$(echo "${new_line}" | sed 's/\//\\\//g')
  touch "${file}"
  sed -i '/'"${old_line_pattern}"'/{s/.*/'"${new}"'/;h};${x;/./{x;q100};x}' "${file}"
  
  # Check if the exit status of the previous command is not equal to 100
  # and if the variable ${new_line} is not an empty string
  if [[ $? -ne 100 ]] && [[ ${new_line} != '' ]]; then
    # If both conditions are met, append the value of ${new_line} to the
    # file specified by ${file}
    echo "${new_line}" >> "${file}"
  fi
}
