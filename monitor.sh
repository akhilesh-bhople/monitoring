#!/bin/bash

## Check URL status
## Akhilesh Bhople akhilesh.bhople@gmail.com

## Usage :
##
##

# Get the list of arguments given to the script
url_list=`echo $@`

# Check and process if URL is valid
validate_url()
{
	validity=`curl -L -I -s --retry 3 --connect-timeout 5 $1`
	if [ -n "$validity" ]
	then
		check_response $1
	else
		status_check="Invalid"
		result $status_check $1 NA
	fi
}

# Get response time and status from the URL
check_response()
{
	response_time=$(curl -o /tmp/response -i -s -L -w %{time_total} $1)
        status_code=`grep "HTTP/" /tmp/response | cut -d" " -f2`
        status_phrase=`grep -i "component status" /tmp/response | cut -d":" -f2`
        #echo $response_time $status_code $status_phrase
        rm -rf /tmp/response
	if [ "$status_code" -eq 200 ]
	then
		status_check="  Green  "
		result $status_check $1 $response_time
	else
		status_check="Red    "
		result $status_check $1 $response_time
	fi
}

# Process results
result()
{
	timestamp=`date +%s`
	printf '%10s %10s %15s %45s\n' $timestamp $1 $3 $2
	echo $timestamp,$1,$2,$3 >>/var/log/monitoring.log
}

table_header()
{
	echo "---------------------------------------------------------------------------------------------------------------------------------------------"
        echo "Timestamp \tStatus \t\tResponse_Time \t\t\t\tURL"
        echo "---------------------------------------------------------------------------------------------------------------------------------------------"
}

table_footer()
{
	echo "---------------------------------------------------------------------------------------------------------------------------------------------"
}

table_header
for url in $url_list
do
	validate_url $url
done
table_footer


