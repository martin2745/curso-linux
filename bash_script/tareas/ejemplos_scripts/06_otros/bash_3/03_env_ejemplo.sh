#!/bin/bash

env | sort | grep -v '^_' | tee env1.txt
cd /tmp
declare -r LECTURA='read-only'
