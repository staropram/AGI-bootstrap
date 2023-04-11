#!/bin/bash

# created with assistance from chatgpt4
out=all_tests.json

# delete the old all_tests_file by overwrite
echo -e -n '{ "commands":[\n' > $out

output=""
last_json_file=`ls -1 | tail -n 1`
# for each json file
for f in `ls *.json`; do
	if [ "$f" = "$out" ]; then
		continue
	fi
	echo $f
	# get the num of commands in the current file
	count=`jq '.commands | length' $f`
	upper=$(($count - 1))
	# iterate over the commands
	for i in $(seq 0 $upper); do
		# get the ith command in current file
	  cmd=$(jq ".commands [$i]" $f)
	  # do not output the exit command unless it
	  # is the last file
	  cmdName=`echo $cmd | jq .action`
	  if [ "$cmdName" = "\"exit\"" ]; then
	  	  if ! cmp -s "$last_json_file" "$f"; then
			  continue
		  fi
	  fi

	  # write the command to the output
	  echo -n "   $cmd" >> $out

	  # if it isn't the last command in the last file
	  # then write a comma
	  if cmp -s "$last_json_file" "$f"; then
		  if [ $i -lt $(($count - 1)) ]; then
			 echo -n "," >> $out
		  fi
	  else
		  echo -n "," >> $out
	  fi
	  # write a newline
	  echo -e -n "\n" >> $out
	done
done

# write the closing braces
echo -e "\n]}" >> $out
