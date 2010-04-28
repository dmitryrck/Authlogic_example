#!/bin/sh
./script/generate session user_session

./script/generate controller user_sessions

./script/generate scaffold user \
login:string \
name:string \
email:string \
crypted_password:string \
password_salt:string \
persistence_token:string \
login_count:integer \
last_request_at:datetime \
last_login_at:datetime \
current_login_at:datetime \
last_login_ip:string \
current_login_ip:string \
active:boolean
