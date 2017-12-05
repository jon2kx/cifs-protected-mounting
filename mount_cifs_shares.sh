#!/bin/bash
#Debugging (remove hash to turn on debugging)#
set -x
#Static Configuration file:#
CIFSC="/etc/user.cifs/cifs.cfg"
#Functionization#
CheckUid() {
CURID=`/usr/bin/id -u`
if [[ $CURID -ne 0 ]]
then
	logger "mount_cifs_shares cannot be run as non-root users, multiple embedded self-pervasion checks are implemented to avoid pervasion." 
	exit 1
else
	SELFPC=0
fi
}

ConfCheck() {

if [[ -e $CIFSC && -O $CIFSC && -G $CIFSC && -r $CIFSC && $SELFPC -eq 0 ]] 
    then
        source $CIFSC  
       	if [[ $? -gt 0 ]]
	   then
	       logger "Unable to read $CIFSC is it accessible? Are you root?"
	       exit 1
	   else
	       selfpc2=0
	fi
else
    logger "Config Check Failure, check the configuration file at $CIFSC "
    exit 1
fi
}

CheckDecodeVariables() {
if [[ -n $CIFSPASS && -n $ADUID && -n $DOMID && -n $CIFSP && -n $LFSPATH ]]
    then
       TABLESET=0
else
     logger "Unable to rectify variables, is $CIFSC accessible? Are you root? Is the configuration file within specifications?"
     exit 1
fi
}

DecodeVariables() {
if [[ $selfpc2 -eq 0 ]]
    then
        CIFSPASS=$(eval echo ${USERPASS} | base64 --decode)
        ADUID=$(eval echo ${USERNAME} | base64 --decode)
        DOMID=$(eval echo ${DOMAIN} | base64 --decode)
        CIFSP=${CPATH}
        LFSPATH=${LPATH}
else
  logger "The second self check detected a non-zero exit status after sourcing the $CIFSC file!"
  exit 1
fi
}

CheckMountandCreate() {
for mountpoint in $LFSPATH
    do 
        if [[ -d $mountpoint ]]
           then
           logger "Path already prepared for $mountpoint, continuing to mount operation."
        else
            mkdir $mountpoint
            logger "Path created and prepared for $mountpoint, continuing to mount operation."
        fi
    done
 }

MountCIFS_Shares() {
##### The below process a nested for loop, to accomplish mounting. #####	 
if [[ $TABLESET -eq 0 && $SELFPC -eq 0 && $selfpc2 -eq 0 ]]
    then
        for LOPATH in $LFSPATH 
  	    do 
	        CURPATH=$LOPATH
                for CIFSPATH in $CIFSP
	            do  sudo mount -t cifs -o username=$ADUID,dom=$DOMID,password=$CIFSPASS $CIFSPATH $CURPATH && if [[ $? -ne 0 ]]; then logger "Failure occured while attempting to mount shares, check credentials in $CIFSC file." ;fi  
		done
	done
     else
         logger "/etc/user.cifs/cifs.cfg is unreadable,unavailable or the variables are not properly set in the file. Please check your permissions level:Are you root? Is the file readable by root? Are the Permissions set to 700?"
         exit 1
 fi
 }

#MAIN#
if [[ $LIVE -eq 0 ]]
    then
        CheckUid
	ConfCheck
        DecodeVariables
        CheckDecodeVariables
        CheckMountandCreate
        MountCIFS_Shares
fi
