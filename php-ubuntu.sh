#!/bin/bash
clear
####################################################################################################
###                                                                                              ###
###                           Display GNU License information                                    ###
###                           ===============================                                    ###
###                                                                                              ###
###      ./php-ubuntu.sh    This will update PHP in Ubuntu to the latest version                 ###
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
echo " php-ubuntu.sh  Copyright (C) 2015  Michael Sharpe "
echo " This program comes with ABSOLUTELY NO WARRANTY; "
echo " This is free software, and you are welcome to redistribute it"
echo " under certain conditions; Please see: http://www.bashscripts.co.uk/gnu.txt"

####################################################################################################
###                                                                                              ###
###                            FILE: php-ubuntu.sh                                               ###
###                                                                                              ###
###                            USAGE: ./php-ubuntu.sh                                            ###
###                                                                                              ###
###       DESCRIPTION: This will update PHP in Ubuntu to the latest version                      ###                                                         
###                                                                                              ###
###                                                                                              ###
###       OPTIONS: ---  none                                                                     ###
###       REQUIREMENTS: ---  Ubuntu 10, 12, 14                                                   ###
###       BUGS: ---                                                                              ###
###       NOTES: ---  published under GNU License (http://www.bashscripts.co.uk/gnu.txt)         ###
###       AUTHOR: --- Mike Sharpe                                                                ###
###       COMPANY: --- Sharpe Digital Solutions                                                  ###
###       VERSION: --- 1                                                                         ###
###       REVISION: --- 0                                                                        ###
###       CREATED: --- 2014                                                                      ###
###                                                                                              ###
####################################################################################################

####################################################################################################
###                                                                                              ###
###                                       Set Variables Here                                     ###
###                                                                                              ###
####################################################################################################
osType=$(uname) # Check to make sure server is Linux
osVersion=$(cat /etc/issue.net | head -n1 | sed -e 's/\s.*$//'); # Check if using CentOS or Ubuntu

####################################################################################################
###                                                                                              ###
###                                   OS Type Check                                              ###
###                                                                                              ###
####################################################################################################
function OSCheck () {
# Checking to see if OS is Linux Based and if it is Ubuntu.
clear
if [[ $osVersion == Linux ]] ; then
  echo
  echo "Found $osVersion Operating System which is good."
 else
    # Display reason for exiting script to user
    echo "I can only use his script within a Linux Operating System,"
    echo "I now need to close this script --- Sorry."
    exit
fi
}

####################################################################################################
###                                                                                              ###
###                                   OS Version Check                                           ###
###                                                                                              ###
####################################################################################################
function OSVersion ()
{
# Checking to see if OS is Linux Based and if it is CentOS.
clear
if [[ $osVersion == Ubuntu ]] ; then
  echo
  echo "Found $osVersion Operating System which is good."
 else
    # Display reason for exiting script to user
    echo "I can only use his script within an Ubuntu Version of Linux,"
    echo "I now need to close this script --- Sorry."
    exit
fi
}

####################################################################################################
###                                                                                              ###
###                                   Update OS                                                  ###
###                                                                                              ###
####################################################################################################
UpdateOS () {
# This will update the OS and Repositories to enable a safe update of PHP
apt-get update
apt-get -y install python-software-properties
add-apt-repository ppa:ondrej/php5-oldstable
}

####################################################################################################
###                                                                                              ###
###                                   Update PHP Function                                        ###
###                                                                                              ###
####################################################################################################
UpdatePHP () {
apt-get update
apt-get -y install php5  # From each menu item coming up, choose the top line and press enter

# Update Ioncube Loader
wget http://downloads2.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xzf ioncube_loaders_lin_x86-64.tar.gz

# Set Ioncube Loader Version and Folder
ioncubeLocation=$(find / -type f -name 'ioncube_loader_lin_5.4.so'| head -n1)

# Locate php.ini file location
phpLocation=$(php -r 'echo php_ini_loaded_file ();')

cp ioncube/ioncube_loader_lin_5.4.so $ioncubeLocation  ## the digit folder name might be slightly different, check first.
echo "zend_extension=$ioncubeLocation" | sudo tee $phpLocation

# Remove old files from server, otherwise you will get an ioncube error
rm -f /etc/php5/cli/conf.d/ioncube.ini
rm -f /etc/php5/cli/conf.d/ioncube-loader-5.3.ini
rm -f ioncube_loaders_lin_x86-64.tar.gz
rm -f ioncube

# Restart Apache
/etc/init.d/apache2 restart
}

####################################################################################################
###                                                                                              ###
###                                   Main Program starts here                                   ###
###                                                                                              ###
####################################################################################################
OSType
OSVersion
UpdateOS
UpdatePHP

####################################################################################################
###                                                                                              ###
###                     Clean up unwanted files/folders after install                            ###
###                                                                                              ###
####################################################################################################
echo
echo " lottery.sh  Copyright (C) 2015  Michael Sharpe "
echo " This program comes with ABSOLUTELY NO WARRANTY; "
echo " This is free software, and you are welcome to redistribute it"
echo " under certain conditions; Please see: http://www.bashscripts.co.uk/gnu.txt"
echo
exit
