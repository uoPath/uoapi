#!/bin/bash

# This script reads all subject codes from uoapi, then read all courses for 
# each subject code, and save the output to a file named after the subject code.
# The output is saved in the output/ directory.

# craete output directory if it does not exist
mkdir -p output

# read all subject codes
codes=$(uoapi course | grep -oP '(?<="subject_code": ")[A-Z]{3}(?=")' | sort) 

# count the number of subject codes so we can display a progress
total=$(echo "$codes" | wc -l)
count=0

# display the number of subject codes found
echo "$total subject codes found."

# read all courses for each subject code
echo "$codes" | 
while read x; do
	# increment the count and display the progress
	((count++))
	echo "Reading $x ($count/$total)"

	# read all courses for the subject code and save the output to a file
	if ! uoapi course --nosubjects --courses $x | 
		python3 -m json.tool > output/$x.json; 
	then
		# if uoapi failed, display an error message and exit
		echo "Error: uoapi failed for subject code $x. Exiting."; 
		exit 1; 
	fi
done

# display a message when done
echo "Done."