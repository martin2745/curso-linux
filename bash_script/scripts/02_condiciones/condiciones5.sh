#!/bin/bash

[ -d /${HOME}/Desktop ] && du -ah ${HOME}/Desktop

echo -e "\n"

if [ -d /${HOME}/Desktop ]; then
	du -ah ${HOME}/Desktop
fi
