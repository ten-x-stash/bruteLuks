#!/bin/bash

# bruteluks.sh

#----------------------------------------------------------------#
#* Name: bruteluks.sh         ***********************************#
#* Author: Nick Neal (Ten-X)  ***********************************#
#* Email: nwneal@kisoki.com   ***********************************#
#****************************************************************#
#* Description: bruteluks.sh is for use in bruteforcing LUKS    *#
#*              Partition encryption passwords. I created this  *#
#*              tool, because I had forgotten my LUKS password, *#
#*		and had a list of possible combinations for the *#
#*		password.                                       *#
#----------------------------------------------------------------#
# -p => password file
# -d => device path (/dev/sdb1, etc...)

check=0
errPrint=""
pw=""
dv=""

if [ $# -eq 4 ]; then


	if [ "$1" == "-p" ]; then
		pw=$2
	elif [ "$3" == "-p" ]; then
		pw=$4
	else
		check=1
		errPrint="$errPrint  Missing password file (-p <password file>)\n"
	fi

	if [ "$1" == "-d" ]; then
		dv=$2
	elif [ "$3" == "-d" ]; then
		dv=$4
	else
		check=1
		errPrint="$errPrint  Missing device (-d <device path>)\n"
	fi

	if [ $check -eq 1 ]; then
		echo "ERROR:"
		printf "$errPrint"
		exit 0
	fi

elif [ $# -lt 4 ]; then
	echo "ERROR: missing parameters..."
	exit 0
elif [ $# -gt 4 ]; then
	echo "ERROR: too many parameters..."
	exit 0
fi


if [ ! -e "$pw" ]; then 
	check=1
	errPrint="$errPrint  '$pw' does not exist.\n"	
fi

if [ ! -e "$dv" ]; then
	check=1
	errPrint="$errPrint  '$dv' does not exist.\n"
elif [ ! -b "$dv" ]; then
	check=1
	errPrint="$errPrint  '$dv' is not a storage device.\n"
fi

if [ $check -eq 1 ]; then
	echo "ERROR:"
	printf "$errPrint"
	exit 0
fi

cryptsetup isLuks $dv 2> /dev/null

if [ $? -ne 0 ]; then
	echo "ERROR: '$dv' is not a valid LUKS device."
	exit 0
fi

clear
### run brute force
for p in $(cat $pw); do
	echo -ne "\033[2K"; echo -n "Trying: '$p'"; printf "\r"
	sleep 1
	echo $p | cryptsetup luksOpen $dv device -T1 2>/dev/null
	if [ $? -eq 0 ]; then
		cryptsetup luksClose device
		printf "\n!!!SUCCESS!!!\n\n"
		echo "  Password: $p"
		printf "\n\n"
		break
	fi
done
