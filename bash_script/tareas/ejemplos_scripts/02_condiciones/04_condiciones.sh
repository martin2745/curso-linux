#!/bin/bash

[ -f /etc/passwd ] && egrep "^root" /etc/passwd

echo -e "\n"

if [ -f /etc/passwd ]; then
	egrep "^root" /etc/passwd
fi
