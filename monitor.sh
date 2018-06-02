#!/bin/bash

## Check URL status
## Akhilesh Bhople akhilesh.bhople@gmail.com

## Usage :
##
##

# Check and process if URL is valid
validate_url()
{
	url=$1
	validity=`curl -L -I -s --retry 3 --connect-timeout 5 $url`
	if [ -n "$validity" ]
	then
		get_response $url
	else
		status_check="Invalid"
		result $status_check $url "-----" "-----"
	fi
}

# Get response time and status from the URL
get_response()
{
	url=$1
	response_time=$(curl -o /tmp/response -i -s -L -w %{time_total} $url)
        status_code=`grep "HTTP/" /tmp/response | cut -d" " -f2`
        status_phrase=`grep -i "component status" /tmp/response | cut -d":" -f2`
	rm -rf /tmp/response
	check_response $response_time $status_code $url $status_phrase
}
	
# Check site status and response time
check_response()
{
	response_time=`echo $1 | sed 's/\.//g'`
	status_code=$2
	status_phrase=`echo $4 | tr '[A-Z]' '[a-z]'`
	url=$3

	if [ "$response_time" -gt 300 ]
        then
                response_type="Slow response"
        else
                response_type="Fast response"
        fi

	if [ "$status_code" -eq 200 ] && [ "$status_phrase" = "green" ]
	then
		status_check="Green"
		result $status_check $url $response_time $response_type
	else
		status_check="Red"
		result $status_check $url $response_time $response_type
	fi
}

# Process results
result()
{
	status_check=$1
	url=$2
	response_time=$3
	response_type=$4
	timestamp=`date +%s`
	printf '%-15s %-15s %-25s %-25s %-40s\n' $timestamp $status_check $response_time $response_type $url
	echo $timestamp,$status_check,$url,$response_time >>/var/log/monitoring.log
}

# Create Table body
table_header()
{
	echo "---------------------------------------------------------------------------------------------------------------------------------------------"
	printf '%-15s %-15s %-25s %-25s %-40s\n' "Timestamp" "Status" "Response_Time" "Response_Rate" "URL"
        echo "---------------------------------------------------------------------------------------------------------------------------------------------"
}

table_footer()
{
	echo "---------------------------------------------------------------------------------------------------------------------------------------------"
}

# Get the list of arguments given to the script
url_list=`echo $@`

table_header
for url in $url_list
do
	validate_url $url
done
table_footer
