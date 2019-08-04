#!/bin/bash
clear
####################################################################################################
###                                                                                              ###
###                           Display GNU License information                                    ###
###                           ===============================                                    ###
###                                                                                              ###
###      ./<script name here>                                                                    ###
###                                                                                              ###
###                          Copyright (C) 2015  Michael Sharpe                                  ###
###                                                                                              ###
###            This program is free software: you can redistribute it and/or modify              ###
###            it under the terms of the GNU General Public License as published by              ###
###             the Free Software Foundation, either version 3 of the License, or                ###
###                          (at your option) any later version.                                 ###
###                                                                                              ###
###               This program is distributed in the hope that it will be useful,                ###
###                but WITHOUT ANY WARRANTY; without even the implied warranty of                ###
###                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                 ###
###                        GNU General Public License for more details.                          ###
###                                                                                              ###
###              You should have received a copy of the GNU General Public License               ###
###         along with this program.  If not, see http://www.bashscripts.co.uk/gnu.txt>.         ###
###                                                                                              ###
####################################################################################################
echo " Copyright (C) 2015  Michael Sharpe "
echo " This program comes with ABSOLUTELY NO WARRANTY; "
echo " This is free software, and you are welcome to redistribute it"
echo " under certain conditions; Please see: http://www.bashscripts.co.uk/gnu.txt"

####################################################################################################
###                                                                                              ###
###                            FILE: <script NAme here>                                          ###
###                                                                                              ###
###                            USAGE: ./<usage of script here>                                   ###
###                                                                                              ###
###       DESCRIPTION:                                                                           ###                                                         
###                                                                                              ###
###                                                                                              ###
###       OPTIONS: ---                                                                           ###
###       REQUIREMENTS: ---  CentOS 6, Ubuntu 10, 12, 14                                         ###
###       BUGS: ---                                                                              ###
###       NOTES: ---  published under GNU License (http://www.bashscripts.co.uk/gnu.txt)         ###
###       AUTHOR: --- Mike Sharpe                                                                ###
###       COMPANY: --- Sharpe Digital Solutions                                                  ###
###       VERSION: --- 1                                                                         ###
###       REVISION: --- 0                                                                        ###
###       CREATED: --- 2015                                                                      ###
###                                                                                              ###
####################################################################################################

####################################################################################################
###                                                                                              ###
###                                       Set Variables Here                                     ###
###                                                                                              ###
####################################################################################################
export osType=$(uname) # Check to make sure server is Linux
export osVersion=$(cat /etc/issue.net | head -n1 | sed -e 's/\s.*$//'); # Check if using CentOS
export osNumber=$(cut -d' ' -f2 /etc/issue.net | cut -d'.' -f1); # Check the version number of the OS - required for CentOS 5, 6 to 7 changes.

####################################################################################################
###                                                                                              ###
###                Check for root user, or other user ID if required                             ###
###                                                                                              ###
####################################################################################################
function CheckUser () {
if [[ $UID != 0 ]] ;  then
  echo "You must be root to run this script."
  exit 5
fi
}

####################################################################################################
###                                                                                              ###
###                            Check OS type and Version                                         ###
###                                                                                              ###
####################################################################################################
if [[ $osType == Linux ]] ; then
  echo
  echo "Found $osType Operating System which is good, now going to check if it is CentOS."
  #Checking to see if Linux OS is CentOS.
  if [[ $osVersion == CentOS ]] ; then    
    echo
    echo "          Found$(tput setaf 1) $osType$(tput sgr0) Operating System running$(tput setaf 1) $osVersion$(tput sgr0)."  # Display which version of Linux was found
    echo
  else
    # Display reason for exiting script to user
    echo "I can only use his script within a Linux Operating System,"
    echo "$(tput setaf 2)CentOS$(tput sgr0) Greater than version 5 (Red Hat Distro) "
	echo "or$(tput setaf 2) Ubuntu$(tput sgr0) (Debian Distro) required,"
	echo
    echo "I now need to close this script --- Sorry."
	echo
    exit 5
  fi
fi
}

####################################################################################################
###                                                                                              ###
###                                   Main Program starts here                                   ###
###                                                                                              ###
####################################################################################################
if [[ -z "$1" ]] ; then # check to make sure there is something after the script name
  echo # Display an error message if no input follows script name
  echo "Usage:  " 
  echo
  exit 20  # exit code to indicate no input variable specified
else
  if [[ ! -d "/usr/local/php-$1-cgi/" ]] &&  [[ $osVersion == CentOS ]] ; then
    
  elif [[ ! -d "/usr/local/php-$1-cgi/" ]] &&  [[ $osVersion == Ubuntu ]] ; then
    
  else
    
  fi
fi

####################################################################################################
###                                                                                              ###
###                     Clean up unwanted files/folders after install                            ###
###                                                                                              ###
####################################################################################################
echo
echo " Copyright (C) 2015  Michael Sharpe "
echo " This program comes with ABSOLUTELY NO WARRANTY; "
echo " This is free software, and you are welcome to redistribute it"
echo " under certain conditions; Please see: http://www.bashscripts.co.uk/gnu.txt"
echo
exit