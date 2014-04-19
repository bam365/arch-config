#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '

PS1="┌─\[\e[36m\][\u@\h] \[\e[01;36m\]( \w ) \`if [ \$? = 0 ]; then echo -e '\[\e[01;32m\]:)'; else echo -e '\[\e[01;31m\]:(';fi\`\[\e[01;34m\]\[\e[00m\]\n└───> "
#PS1='\[\e[1;37m\][\u@\h][\W]\n\[\e[1;37m\][\$]\[\e[0m\] '
 
export EDITOR=vim
export GOPATH=/home/blake/go
export PATH=$PATH:/home/blake/bin:/opt/java/jre/bin:$GOPATH/bin:/opt/android-sdk/tools:/opt/android-sdk/platform-tools

eval `opam config env`



export PATH=/home/blake/bin/Sencha/Cmd/4.0.2.67:$PATH

export SENCHA_CMD_3_0_0="/home/blake/bin/Sencha/Cmd/4.0.2.67"
