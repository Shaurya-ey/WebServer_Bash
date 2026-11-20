#!/bin/bash

#So this is my first project on Bash Scripting.
#I'm going to create a simple WebServer using Bash Script, netcat and FIFO.

#Creating the reponse FIFO from client -> server
rm -f response
mkfifo response


get_home(){
    Response=$(cat Frontend/home.html | sed "s/{{$C_name}}/$C_value/")
}
get_login(){
    Response=$(cat Frontend/login.html)
}
send_login(){
    Response=$(cat Frontend/send-login.lhttp | sed "s/{{$C_name}}/$C_value/") 
}
send_logout(){
    Response=$(cat Frontend/send-logout.http | sed "s/{{$C_name}}/$C_value/")
}
send_404(){
    Response=$(cat Frontend/404.html)
}
handle_req(){
    #Read request
    while read line; do
        echo $line
        tline=`echo $line | tr -d '[\r\n]'`

        if [ -z "$tline" ]; then
            break
        fi
        headline_regex='(.*?)\s(.*?)\sHTTP.*?'
        [["$tline" =~ $headline_regex ]] &&
        
        # Extract HTTP request method and path
        if [[ -z "$Request" ]]; then
            read -r Method Path Protocol <<< "$tline"
            Path=${Path%%\?*}
            Request="$Method $Path"
        fi

        # Extract Content-Length
        if [[ "$tline" =~ ^[Cc]ontent-[Ll]ength:[[:space:]]*([0-9]+) ]]; then
            Content_length="${BASH_REMATCH[1]}"
        fi
    done

    #read body
    if [ ! -z "$Content_length" ]; then
        Body_regex='(.*?)=(.*?)'

        while read -n$Content_length -t1 line; do
            echo $line
            tline=`echo $line | tr -d '[\r\n]'`
            [ -z "$tline" ] && break
            read Input_name Input_value <<< $(echo $tline | sed -E "s/$Body_regex/\1 \2/")
        done
    fi


    
    #checking the request...
    case "$Request" in
        "GET /") get_home ;;
        "GET /login") get_login ;;
        "POST /login") send_login ;;
        "POST /logout") send_logout ;;
        *) send_404 ;;
    esac
    {
        printf 'HTTP/1.1 200 OK\r\n'
        printf 'Content-Type: text/html; charset=UTF-8\r\n'
        printf 'Content-Length: %s\r\n' "${#Response}"
        printf 'Connection: close\r\n'
        printf '\r\n'
        printf '%s' "$Response"
    } > response
}

echo 'Listening on port 2000...'
while true; do
    cat response | nc -lN 2000 | handle_req
done


