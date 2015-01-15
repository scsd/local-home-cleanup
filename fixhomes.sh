#!/bin/bash

#Admin-side version

#The point of this program is to give us a tool to be able to fix problems with local homes easily.
#The problem this program/script/whatever focuses on is that of what happens when the local homes
#become corrupted or have compied and synced the entire network account, resulting in hour long
#sync processes and confusion when it comes to files.

#The solution and flow of the program is as follows: Take in the IP address of the computer to check,
#or cycle through a series of them (example: 10.81.25.1-15 would cycle through 10.81.25.1, 10.81.25.2
#and so on.). When it recives the address, it will then 'ssh' to that address with the root account and
#check though the 'Users' directory and use 'ls' and 'grep' to find the hidden file in the root of
#the directory.


#Use 'smoothOut' instead of echo for the output. This will make the output look nice for use with Mac
#computers, removing the '-e' thing
function smoothOut {
	echoOut=`echo -e`
	if [ "$echoOut" == "-e" ]; then
		echo "$1"
	else
		echo -e "$1"
	fi
}


#This will be the help explination for when we forget

if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ -z "$1" ]; then
	smoothOut "Useage:"
	smoothOut "\tfixhomes [ip address]\n\nThe ip address can be in the standard form of 10.81.xxx.xxx or in\n"\
"the form of 10.81.xxx.xxx-xxx, meaning that it will start from the\n"\
"first ip address and loop through the last set of numbers until it\n"\
"reaches the set of numbers after the dash(-)."

	exit 0
fi

#Set the ip address and the ranges
ipBase=`echo "$1" | cut -d'-' -f 1 | cut -d'.' -f 1-3`
begin=`echo "$1" | cut -d'-' -f 1 | cut -d'.' -f 4`
ending=`echo "$1" | cut -d'-' -f 2`

#Check if there is a range given. This needs to be done because cut will grab the whole address.
rangeCheck="$ipBase.$begin"
if [ "$ending" == "$rangeCheck" ]; then
	ending="$begin"
fi

#Create a function that contains the code to fix the accounts
function removeHome {
	#Begin by checking the 'Users' directory
	users=($(ls /Users))
	#check each directory for the hidden file
	for i in "${users[@]}"
	do
		#Make sure nothing important is deleted.
		if [[ "$i" != "student" ]] && [[ "$i" != "teacher" ]] && [[ "$i" != "admin" ]] && [[ "$i" != "radmind" ]] && [[ "$i" != "Shared" ]] && [[ "i" != ".localized" ]]; then
			smoothOut "$i"
			#Create a variable to be used as the test if the files are there
			found=`ls -a /Users/"$i" | grep "$hidden"`
			if [ "$found" == "$hidden" ]; then
				#Stuff when
				answer="xyz"
				smoothOut "\tThe hidden file has been found!\n"\
"This means that the home is corrupt and should be deleted.\n"\
"Delete the user $i on $ipBase.$x? ('yes' or 'no')"
				read answer
				while [ "$answer" != "yes" ] && [ "$answer" != "no" ]; do
					smoothOut "Please choose only 'yes' or 'no' as the answer."
					read answer
				done
				if [ "$answer" == "yes" ]; then
					#Remove the user from the system
					dscl . -delete /Users/"$i"
					#Ask what to do about their files
					smoothOut "Would you like to backup their files? If not, they will be deleted."
					read answer
					while [ "$answer" != "yes" ] && [ "$answer" != "no" ]; do
        					smoothOut "Please choose only 'yes' or 'no' as the answer."
        					read answer
					done
					#Decide whether or not to delete the home folder
					if [ "$answer" == "yes" ]; then
						smoothOut "Backing up files..."
						curdate=`date "+%Y-%m-%d"`
						checkbackup=`ls /Users | grep "$i".bak."$curdate"`
						if [ -z "$checkbackup" ]; then
							mv /Users/"$i" /Users/"$i".bak."$curdate"
						else
							smoothOut "Backup from today already found, adding a zero to the name..."
							checkbackup=`ls /Users | grep "$i".bak."$curdate".0`
							if [ -z "$checkbackup" ]; then
								smoothOut "Backup with 0 at the end already found, deleting..."
								rm -rf /Users/"$i".bak."$curdate".0
							fi
							mv /Users/"$i".bak."$curdate" /Users/"$i".bak."$curdate".0
							mv /Users/"$i" /Users/"$i".bak."$curdate"
						fi
						smoothOut "Backup complete. Moved to /Users/$i.bak.$curdate"
					else
						smoothOut "Deleting the home folder..."
						rm -rf /Users/"$i"
						smoothOut "Delete complete. The user's folder has been deleted."
					fi
				else
					smoothOut "Ingnoring this user's folder...\n"
				fi
			else
				smoothOut "The hidden file '$hidden' has not been found in user folder '$i'.\n\tChecking different folder..."
			fi
		fi
	done

	answer="xyz"
	smoothOut "\tNo other instance of the hidden file has been found.\n"\
"Would you like to manually delete a user from the computer? ('yes' or 'no')"
	read answer
	while [ "$answer" != "yes" ] && [ "$answer" != "no" ]; do
		smoothOut "Please choose only 'yes' or 'no' as the answer."
		read answer
        done
	if [ "$answer" == "yes" ]; then
		usr=""
		smoothOut "Please enter the user name:"
		read usr
		#Remove the user from the system
		dscl . -delete /Users/"$i"
		#Ask what to do about their files
		smoothOut "Would you like to backup their files? If not, they will be deleted."
		read answer
		while [ "$answer" != "yes" ] && [ "$answer" != "no" ]; do
			smoothOut "Please choose only 'yes' or 'no' as the answer."
			read answer
		done
		#Decide whether or not to delete the home folder
		if [ "$answer" == "yes" ]; then
			smoothOut "Backing up files..."
				curdate=`date "+%Y-%m-%d"`
				checkbackup=`ls /Users | grep "$i".bak."$curdate"`
				if [ -z "$checkbackup" ]; then
					mv /Users/"$i" /Users/"$i".bak."$curdate"
				else
					smoothOut "Backup from today already found, adding a zero to the name..."
					checkbackup=`ls /Users | grep "$i".bak."$curdate".0`
					if [ -z "$checkbackup" ]; then
						smoothOut "Backup with 0 at the end already found, deleting..."
						rm -rf /Users/"$i".bak."$curdate".0
					fi
					mv /Users/"$i".bak."$curdate" /Users/"$i".bak."$curdate".0
					mv /Users/"$i" /Users/"$i".bak."$curdate"
				fi
				smoothOut "Backup complete. Moved to /Users/$i.bak.$curdate"
			else
				smoothOut "Deleting the home folder..."
				rm -rf /Users/"$i"
				smoothOut "Delete complete. The user's folder has been deleted."
		fi
	else
		smoothOut "Everything is finished, now exiting the machine..."
	fi
}

#Create a while loop to go through each ip that was specified. Use 'x' as the looping variable!
for x in `seq $begin $ending`;
do
	smoothOut "Now connecting to $ipBase.$x, please wait..."
	ssh -t root@$ipBase.$x "$(typeset -f); hidden='.badhome'; removeHome"
	smoothOut "\n"
done

exit 0
