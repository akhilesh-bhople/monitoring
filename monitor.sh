#!/bin/bash

## Check URL status
## Akhilesh Bhople akhilesh.bhople@gmail.com


validate_url()
{
	url=$1
	validity=`curl -L -I -s --retry 3 --connect-timeout 5 $url`
	if [ -n "$validity" ]
	then echo "valid"
	else echo "invalid"
	fi
}

# Get response time and status from the URL
get_response()
{
        url=$1
	response_time=$(curl -o /tmp/response -i -s -L -w %{time_total} $url)
        status_code=`grep "HTTP/" /tmp/response | cut -d" " -f2`
        status_phrase=`grep -i "component status" /tmp/response | cut -d":" -f2`
	if [ -z "$status_phrase" ]
	then status_phrase="Red"
	fi
	echo "response_time: $response_time status_phrase: $status_phrase status_code: $status_code"
        rm -rf /tmp/response
}

check_response()
{
        response_time_ms=`echo $1 | sed 's/\.//g'`
        status_code=$2
        status_phrase=`echo $3 | tr '[A-Z]' '[a-z]'`
	timestamp=`date +%s`
	if [ "$response_time_ms" -gt 300 ]; then response_rate="Slow"
        else response_rate="Fast"; fi
	if [ "$status_code" = 401 ]; then url_status="Auth_error"	
	elif [ "$status_code" = 200 ] && [ "$status_phrase" = "green" ]; then url_status="Green"
	else url_status="Unknown"
	fi
	echo "timestamp: $timestamp response_rate: $response_rate url_status: $url_status response_time_ms: $response_time_ms"
}

show_result()
{
        status_check=$1
        url=$2
        response_time=$3
        response_type=$4
        timestamp=$5
        printf '%-15s %-15s %-25s %-25s %-s\n' $timestamp $status_check $response_time $response_type $url
        echo $timestamp,$status_check,$url,$response_time >>/var/log/monitoring.log
}

table_header()
{
        echo "---------------------------------------------------------------------------------------------------------------------------------------------"
        printf '%-15s %-15s %-25s %-25s %-40s\n' "Timestamp" "Status" "Response_Time" "Response_Rate" "URL"
        echo "---------------------------------------------------------------------------------------------------------------------------------------------"
}

table_rows()
{
	for url in $url_list
	do
        	validity=$(validate_url $url)
	        if [ "$validity" = "valid" ]; then
        	       	get_response_result=$(get_response $url)
	                response_time=`echo $get_response_result | cut -d" " -f2`
       	        	status_phrase=`echo $get_response_result | cut -d" " -f4`
                	status_code=`echo $get_response_result | cut -d" " -f6`
        	        check_response_result=$(check_response $response_time $status_code $status_phrase)
                	timestamp=`echo $check_response_result | cut -d" " -f2`
	                response_rate=`echo $check_response_result | cut -d" " -f4`
        	        url_status=`echo $check_response_result | cut -d" " -f6`
                	response_time_ms=`echo $check_response_result | cut -d" " -f8`
        	        show_result $url_status $url $response_time_ms $response_rate $timestamp
        	else
                	timestamp=`date +%s`
	                show_result "Invalid" $url "-----" "-----" $timestamp
        	fi
	done
}
table_footer()
{
        echo "---------------------------------------------------------------------------------------------------------------------------------------------"
}

# Get the list of arguments given to the script
url_list=`echo $@`
if [ -z "$url_list" ]
then echo "Please provide URL as argument to the script"; exit
fi

table_header
table_rows
table_footer

