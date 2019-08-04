#!/bin/bash
clear
####################################################################################################
###                                                                                              ###
###                           Display GNU License information                                    ###
###                           ===============================                                    ###
###                                                                                              ###
###      ./mcrypt.sh                                                                             ###
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
###                            FILE: mcrypt.sh                                                   ###
###                                                                                              ###
###                            USAGE: ./mcrypt.sh                                                ###
###                                                                                              ###
###       DESCRIPTION:  This will install all files needed to run Mcrypt                         ###                                                         
###                                                                                              ###
###                                                                                              ###
###       OPTIONS: ---                                                                           ###
###       REQUIREMENTS: ---  CentOS 6 or above, any version of Ubuntu                            ###
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
###                             Download and run OS Check function                               ###
###                                                                                              ###
####################################################################################################
function osCheck () {
  mkdir -P /tmp/bash/
  cd /tmp/bash/
  wget http://bashscripts.co.uk\downloads\os-check.share/doc/openvpn*
  bash ./os-check.sh
}

####################################################################################################
###                                                                                              ###
###                             Main program starts here                                         ###
###                                                                                              ###
####################################################################################################
if [[ $OSTYPE == "centos" ]] ; then
  rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  yum -y update
  yum install -y php-mcrypt
  if [[ $OSVERSION == 7 ]] ; then
    systemctl restart httpd
  else
    service httpd restart
  fi
# If not CentOS check to see if OS is Ubuntu
elif [[ $OSTYPE == "debian" ]] ; then 
  apt-get -y update
  apt-get install -y php-mcrypt
  systemctl restart apcahe2
else
  # Display reason for exiting script to user
  echo "I can only use his script within a Linux Operating System,"
  echo "$(tput setaf 2)CentOS$(tput sgr0) Greater than version 5 (Red Hat Distro) "
  echo "or$(tput setaf 2) Ubuntu$(tput sgr0) (Debian Distro) required,"
  echo
  echo "I now need to close this script --- Sorry."
  echo
  exit 10
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


