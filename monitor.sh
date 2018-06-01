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
get_response()
{
	response_time=$(curl -o /tmp/response -i -s -L -w %{time_total} $1)
        status_code=`grep "HTTP/" /tmp/response | cut -d" " -f2`
        status_phrase=`grep -i "component status" /tmp/response | cut -d":" -f2`
        rm -rf /tmp/response
	check_response $response_time $status_code $status_phrase $1
}
	
# Check site status and response time
check_response()
{
	response_time=`echo $1 | sed 's/\.//g'`
	echo $response_time
	status_code=$2
	status_phrase=`echo $3 | tr '[A-Z]' '[a-z]'`
	if [ "$status_code" -eq 200 ] && [ "$status_phrase" = "green" ]
	then
		status_check="Green"
		result $status_check $4 $response_time
	else
		status_check="Red"
		result $status_check $4 $response_time
	fi

	if [ "$response_time" -gt 300 ]
	then
		echo "Slow response"
	else
		echo "Fast response"
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

check_response 3.00 200 GreeN 
#table_header
#for url in $url_list
#do
#	validate_url $url
#done
#table_footer


