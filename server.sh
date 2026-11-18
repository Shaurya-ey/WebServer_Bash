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
    while read line; do
        echo $line
        tline=`echo $line | tr -d '[\r\n]'`

        if [ -z "$tline" ]; then
            break
        fi
        headline_regex='(.*?)\s(.*?)\sHTTP.*?'
        [["$tline" =~ $headline_regex ]] &&
            Request=$(echo $trline | sed "s/$headline_regx/\1 \2/")
    done
    echo -e 'HTTP/1.1 200\r\n\r\n\r\n</h1>PONG</h1>' > response     #response to FIFO
    
    #checking the request...
    case "$REQUEST" in
    esac
    echo -e $Response > response
}

echo 'Listening on port 2000...'

cat response | nc -lN 2000 | handle_req



