#!/bin/bash

#So this is my first project on Bash Scripting.
#I'm going to create a simple WebServer using Bash Script, netcat and FIFO.

#Creating the reponse FIFO from client -> server
rm -f response
mkfifo response

#Starting off with helping intructions for the users...
welp(){
    echo "Welcome to Shaurya's Bash Scripted Web Server!"
    cat << "EOF"
    -----
    Shhhhhhh it's a login page...
    -----
EOF 
}

get_home(){
    Response=$(cat home.html | sed "s/{{$C_name}}/$C_value/")
}
get_login(){
    Response=$(cat login.html)
}
send_login(){
    Response=$(cat send-login.lhttp | sed "s/{{$C_name}}/$C_value/") 
}
send_logout(){
    Response=$(cat send-logout.http | sed "s/{{$C_name}}/$C_value/")
}
send_404(){
    Response=$(cat 404.html)
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
            Request=$(echo $trline | sed "s/$headline_regx/\1 \2/")
        
        Content_length_regex='Content-Length:\s(.*?)'
        [[ "$tline" =~ $Headline_regex ]] &&
            Content_length=$(echo $tline | sed -E "s/$Content_length_regex/\1/")
        
        Cookie_regex='Coockie:\s(.*?)\=(.*?).*?'
        [[ "$tline" =~ &Cookie_regex ]] &&
            read Cookie_name Cookie_value <<< $(echo $tline | sed -E "s/$Cookie_regex/\1 \2/")
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
        "GET / ") get_home ;;
        "GET /login") get_login ;;
        "POST /login") send_login ;;
        "POST /logout") send_logout ;;
        *) send_404 ;;
    esac
    echo -e $Response > response
}

echo 'Listening on port 2000...'
while true; do
    cat response | nc -lN 2000 | handle_req
done


