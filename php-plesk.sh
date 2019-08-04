#!/bin/bash
clear
####################################################################################################
###                                                                                              ###
###                           Display GNU License information                                    ###
###                           ===============================                                    ###
###                                                                                              ###
###      ./php-plesk.sh 5.5.20   (Where 5.5.20 is the php version you would like installed)      ###
###              available version numbers can be found here: http://php.net/releases/           ###
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
echo " PHP-Plesk.sh  Copyright (C) 2015  Michael Sharpe "
echo " This program comes with ABSOLUTELY NO WARRANTY; "
echo " This is free software, and you are welcome to redistribute it"
echo " under certain conditions; Please see: http://www.bashscripts.co.uk/gnu.txt"

####################################################################################################
###                                                                                              ###
###                            FILE: php-plesk.sh                                                ###
###                                                                                              ###
###                            USAGE: ./php-plesk.sh 5.5.20                                      ###
###                                                                                              ###
###       DESCRIPTION: Will install an additional  php version and add to plesk                  ###                                                         
###                                                                                              ###
###                                                                                              ###
###       OPTIONS: ---  PHP Version number (http://php.net/releases/)                            ###
###       REQUIREMENTS: ---  CentOS 6, Ubuntu 10, 12, 14                                         ###
###       BUGS: ---  Do not use on CentOS 5                                                      ###
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
export osType=$(uname) # Check to make sure server is Linux
export osVersion=$(cat /etc/issue.net | head -n1 | sed -e 's/\s.*$//'); # Check if using CentOS or Ubuntu
export osNumber=$(cat /usr/local/psa/version | cut -d' ' -f3); # Check the version number of the OS - required for CentOS 5, 6 to 7 changes.
export pleskVersion=$(cat /usr/local/psa/version | cut -d'.' -f1) # Check the Plesk version Number
DIR='/'
LIMIT='90'

####################################################################################################
###                                                                                              ###
###                           If OS is CentOS 6 or 7 run this function                           ###
###                                                                                              ###
####################################################################################################
function CentOS_install_php () 
{
phpVersionNumber=$1
# Check if Safe mode is enabled in php.ini file
sed -i 's/safe_mode = On/safe_mode = Off/' /etc/php.ini
cd $DIR #To check real used size, we need to navigate to folder
USED=`df . | awk '{print $5}' | sed -ne 2p | cut -d"%" -f1` #This line will get used space of partition where we currently are, this will use df command, and get used space in %, and after cut % from value.
if [[ $USED -gt $LIMIT ]] ; then #If used space is bigger than LIMIT
  du --exclude=/mnt -x / --block-size=GiB --max-depth=1 #This will print space usage by each directory inside directory $DIR, and after MAILX will send email with SUBJECT to MAILTO
  echo "Sorry you do not have enough free space to install this, please free up some space and try again."
else
  rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  yum -y install gcc make gcc-c++ cpp kernel-headers.x86_64 libxml2-devel openssl-devel bzip2-devel libjpeg-devel libpng-devel freetype-devel openldap-devel postgresql-devel aspell-devel net-snmp-devel libxslt-devel libc-client-devel libicu-devel gmp-devel curl-devel libmcrypt-devel unixODBC-devel pcre-devel sqlite-devel db4-devel enchant-devel libXpm-devel mysql-devel readline-devel libedit-devel recode-devel libtidy-devel
  phpconfigureflagscentos="--with-libdir=lib64 --cache-file=./config.cache --prefix=/usr/local/php-\$phpVersionNumber-cgi --with-config-file-path=/usr/local/php-\$phpVersionNumber-cgi/etc --disable-debug --with-pic --disable-rpath  --with-bz2 --with-curl --without-sqlite3 --enable-intl --with-freetype-dir=/usr/local/php-\$phpVersionNumber-cgi --with-png-dir=/usr/local/php-\$phpVersionNumber-cgi --enable-gd-native-ttf --without-gdbm --with-gettext --with-gmp --with-iconv --with-jpeg-dir=/usr/local/php-\$phpVersionNumber-cgi --with-openssl --with-pspell --with-pcre-regex --with-zlib --enable-exif --enable-ftp --enable-sockets --enable-sysvsem --enable-sysvshm --enable-sysvmsg --enable-wddx --with-kerberos --with-unixODBC=/usr --enable-shmop --enable-calendar --with-libxml-dir=/usr/local/php-\$phpVersionNumber-cgi --enable-pcntl --with-imap --with-imap-ssl --enable-mbstring --enable-mbregex --with-gd --enable-bcmath --with-xmlrpc --with-ldap --with-ldap-sasl --with-mysql=/usr --with-mysqli --with-snmp --enable-soap --with-xsl --enable-xmlreader --enable-xmlwriter --enable-pdo --with-pdo-mysql --with-pdo-pgsql --with-pear=/usr/local/php-\$phpVersionNumber-cgi/pear --with-mcrypt --without-pdo-sqlite --with-config-file-scan-dir=/usr/local/php-\$phpVersionNumber-cgi/php.d"
 
  declare -A phpdownloadurlprimary
    phpdownloadurlprimary[$phpVersionNumber-cgi]="http://uk1.php.net/get/php-$phpVersionNumber.tar.gz/from/this/mirror"
  declare -A phpdownloadurlsecondary
    phpdownloadurlsecondary[$phpVersionNumber-cgi]="http://museum.php.net/php5/php-$phpVersionNumber.tar.gz"
fi

cd /usr/local/src/

wget ${phpdownloadurlprimary[$phpVersionNumber-cgi]} -O /usr/local/src/php-$phpVersionNumber-cgi.tar.gz
mkdir -p /usr/local/src/php-$phpVersionNumber-cgi/
tar xzvf /usr/local/src/php-$phpVersionNumber-cgi.tar.gz -C /usr/local/src/php-$phpVersionNumber-cgi/ --strip 1

if [[ $? -eq 0 ]] ; then
  cd /usr/local/src/php-$phpVersionNumber-cgi/
  eval ./configure $phpconfigureflagscentos
  
  if [[ $? -eq 0 ]] ; then
    make -j $(grep processor /proc/cpuinfo | wc -l)
    [[ ! -d "/usr/local/php-$phpVersionNumber-cgi/" ]] && make install

    cp -a /etc/php.ini /usr/local/php-$phpVersionNumber-cgi/etc/php.ini

    mkdir -p /usr/local/php-$phpVersionNumber-cgi/bin/
    /usr/local/psa/bin/php_handler --add -displayname "$phpVersionNumber" -path "/usr/local/php-$phpVersionNumber-cgi/bin/php-cgi" -phpini "/usr/local/php-$phpVersionNumber-cgi/etc/php.ini" -type fastcgi -id "fastcgi-$phpVersionNumber"
  else
    rm -rf /usr/local/src/php-$phpVersionNumber-cgi/
	rm -f /usr/local/src/php-$phpVersionNumber-cgi.tar.gz
    echo
	echo "There is an error with the configure command, please correct the error and rerun the script."
	echo	
  fi  
else
  wget ${phpdownloadurlsecondary[$phpVersionNumber-cgi]} -O /usr/local/src/php-$phpVersionNumber-cgi.tar.gz
  mkdir -p /usr/local/src/php-$phpVersionNumber-cgi/
  tar xzvf /usr/local/src/php-$phpVersionNumber-cgi.tar.gz -C /usr/local/src/php-$phpVersionNumber-cgi/ --strip 1
  cd /usr/local/src/php-$phpVersionNumber-cgi/
  eval ./configure $phpconfigureflagscentos
  
  if [[ $? -eq 0 ]] ; then
    make -j $(grep processor /proc/cpuinfo | wc -l)
    [[ ! -d "/usr/local/php-$phpVersionNumber-cgi/" ]] && make install
 
    cp -a /etc/php.ini /usr/local/php-$phpVersionNumber-cgi/etc/php.ini

    mkdir -p /usr/local/php-$phpVersionNumber-cgi/bin/
    /usr/local/psa/bin/php_handler --add -displayname "$phpVersionNumber" -path "/usr/local/php-$phpVersionNumber-cgi/bin/php-cgi" -phpini "/usr/local/php-$phpVersionNumber-cgi/etc/php.ini" -type fastcgi -id "fastcgi-$phpVersionNumber"
  else
    rm -rf /usr/local/src/php-$phpVersionNumber-cgi/
	rm -f /usr/local/src/php-$phpVersionNumber-cgi.tar.gz
    echo
	echo "There is an error with the configure command, please correct the error and rerun the script."
	echo	
  fi		
fi
}

####################################################################################################
###                                                                                              ###
###                           If the OS is Ubuntu run this Function                              ###
###                                                                                              ###
####################################################################################################
function Ubuntu_install_php () {
phpVersionNumber=$1
sed -i 's/safe_mode = On/safe_mode = Off/' /etc/php5/apache2/php.ini
sed -i 's/safe_mode = On/safe_mode = Off/' /etc/php5/cgi/php.ini
sed -i 's/safe_mode = On/safe_mode = Off/' /etc/php5/cli/php.ini
cd $DIR #To check real used size, we need to navigate to folder
USED=`df . | tail -1 | awk '{print $4}' | cut -d"%" -f1` #This line will get used space of partition where we currently are, this will use df command, and get used space in %, and after cut % from value.
if [[ $USED -gt $LIMIT ]] ; then #If used space is bigger than LIMIT
  du --exclude=/mnt -x / --block-size=GiB --max-depth=1 #This will print space usage by each directory inside directory $DIR, and after MAILX will send email with SUBJECT to MAILTO
  echo "Sorry you do not have enough free space to install this, please free up some space and try again."
else
  aptitude -y build-dep php5
  apt-get update
  apt-get -y install build-essential libxml2 libxml2-dev libssl-dev pkg-config curl libcurl4-gnutls-dev enchant libenchant-dev libjpeg8 libjpeg8-dev libpng12-0 libpng12-dev libvpx1 libvpx-dev libfreetype6 libfreetype6-dev libt1-5 libt1-dev libgmp10 libgmp-dev libicu48 libicu-dev mcrypt libmcrypt4 libmcrypt-dev libpspell-dev libedit2 libedit-dev libsnmp15 libsnmp-dev libxslt1.1 libxslt1-dev libbz2-dev libc-client2007e-dev libc-client-dev libmcrypt-dev php5-sqlite
  ln -s /usr/lib /usr/lib64  

  phpconfigureflagsubuntu="--disable-debug --disable-rpath --enable-bcmath --enable-calendar --enable-exif --enable-ftp --enable-fpm --enable-gd-native-ttf --enable-intl --enable-mbregex --enable-mbstring --enable-opcache --enable-pcntl --enable-pdo --with-sqlite3 --enable-intl --enable-shmop --enable-soap --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-wddx --enable-xmlreader --enable-xmlwriter --enable-zip --prefix=/usr/local//php-\$phpVersionNumber-cgi --with-bz2 --with-config-file-path=/usr/local//php-\$phpVersionNumber-cgi/etc --with-config-file-scan-dir=/usr/local//php-\$phpVersionNumber-cgi/php.d --with-curl --with-freetype-dir=/usr/local//php-\$phpVersionNumber-cgi --with-gd --with-gettext --with-gmp --with-iconv --with-imap --with-imap-ssl --with-jpeg-dir=/usr/local//php-\$phpVersionNumber-cgi --with-kerberos --with-libdir=lib64 --with-libxml-dir=/usr/local//php-\$phpVersionNumber-cgi --with-mcrypt --with-mysql --with-mysqli --with-openssl --with-pcre-regex --with-pdo-mysql --with-pic --with-png-dir=/usr/local//php-\$phpVersionNumber-cgi --with-snmp --with-xmlrpc --with-xsl --with-zlib --without-gdbm --with-sqlite3=/usr/bin/sqlite3"

  declare -A phpdownloadurlprimary
    phpdownloadurlprimary[$phpVersionNumber-cgi]="http://uk1.php.net/get/php-$phpVersionNumber.tar.bz2/from/this/mirror"
  declare -A phpdownloadurlsecondary
    phpdownloadurlsecondary[$phpVersionNumber-cgi]="http://museum.php.net/php5/php-$phpVersionNumber.tar.bz2"
fi

cd /usr/local/src/
wget ${phpdownloadurlprimary[$phpVersionNumber-cgi]} -O /usr/local/src/php-$phpVersionNumber-cgi.tar.bz2
mkdir -p /usr/local/src/php-$phpVersionNumber-cgi/
tar xjvf /usr/local/src/php-$phpVersionNumber-cgi.tar.bz2 -C /usr/local/src/php-$phpVersionNumber-cgi/ --strip 1
  
if [[ $? -eq 0 ]] ; then
  cd /usr/local/src/php-$phpVersionNumber-cgi/
  eval ./configure $phpconfigureflagsubuntu
	
  if [[ $? -eq 0 ]] ; then
	make && make install
	mkdir -p /usr/local/php-$phpVersionNumber-cgi/etc/
	cp /usr/local/src/php-$phpVersionNumber-cgi/php.ini-production /usr/local/php-$phpVersionNumber-cgi/etc/php.ini
    sed -i 's/safe_mode = On/safe_mode = Off/' /usr/local/php-$phpVersionNumber-cgi/etc/php.ini
	
	mkdir -p /usr/local/php-$phpVersionNumber-cgi/bin/
	/usr/local/psa/bin/php_handler --add -displayname "$phpVersionNumber" -path "/usr/local/php-$phpVersionNumber-cgi/bin/php-cgi" -phpini "/usr/local/php-$phpVersionNumber-cgi/etc/php.ini" -type fastcgi -id "fastcgi-$phpVersionNumber"
  else
    rm -rf /usr/local/src/php-$phpVersionNumber-cgi/
	rm -f /usr/local/src/php-$phpVersionNumber-cgi.tar.bz2
    echo
	echo "There is an error with the configure command, please correct the error and rerun the script."
	echo	
  fi
else
  wget ${phpdownloadurlsecondary[$phpVersionNumber-cgi]} -O /usr/local/src/php-$phpVersionNumber-cgi.tar.bz2
  mkdir -p /usr/local/src/php-$phpVersionNumber-cgi/
  tar xjvf /usr/local/src/php-$phpVersionNumber-cgi.tar.bz2 -C /usr/local/src/php-$phpVersionNumber-cgi/ --strip 1
  cd /usr/local/src/php-$phpVersionNumber-cgi/
  eval ./configure $phpconfigureflagsubuntu

  if [[ $? -eq 0 ]] ; then
	make && make install

	mkdir -p /usr/local/php-$phpVersionNumber-cgi/etc/
	cp /usr/local/src/php-$phpVersionNumber-cgi/php.ini-production /usr/local/php-$phpVersionNumber-cgi/etc/php.ini
    sed -i 's/safe_mode = On/safe_mode = Off/' /usr/local/php-$phpVersionNumber-cgi/etc/php.ini
	
	mkdir -p /usr/local/php-$phpVersionNumber-cgi/bin/
	/usr/local/psa/bin/php_handler --add -displayname "$phpVersionNumber" -path "/usr/local/php-$phpVersionNumber-cgi/bin/php-cgi" -phpini "/usr/local/php-$phpVersionNumber-cgi/etc/php.ini" -type fastcgi -id "fastcgi-$phpVersionNumber"
  else
    rm -rf /usr/local/src/php-$phpVersionNumber-cgi/
	rm -f /usr/local/src/php-$phpVersionNumber-cgi.tar.bz2
    echo
	echo "There is an error with the configure command, please correct the error and rerun the script."
	echo
  fi
fi
}

####################################################################################################
###                                                                                              ###
###                           This script must be run as root.                                   ###
###                                                                                              ###
####################################################################################################
if [[ $UID != 0 ]] # check for root user
then
  echo "You must be$(tput setaf 2) root$(tput sgr0) to run this script."
  exit
fi

####################################################################################################
###                                                                                              ###
###            Checking to see if OS is Linux Based and if it is CentOS or Ubuntu.               ###
###                                                                                              ###
####################################################################################################
if [[ $osType == Linux ]] ; then
  echo
  echo "Found $osType Operating System which is good, now going to check if it is CentOS or Ubuntu."
  #Checking to see if Linux OS is CentOS or Ubuntu.
  if [[ $osVersion == CentOS ]] || [[ $osVersion == Ubuntu ]] ; then    
    echo
    echo "   Found$(tput setaf 1) $osType$(tput sgr0) Operating System running$(tput setaf 1) $osVersion $osNumber$(tput sgr0) and Plesk Version$(tput setaf 1) $pleskVersion$(tput sgr0)."  # Display which version of Linux was found
    echo
  else
    # Display reason for exiting script to user
    echo "I can only use his script within a Linux Operating System,"
    echo "$(tput setaf 2)CentOS$(tput sgr0) Greater than version 5 (Red Hat Distro) "
	echo "or$(tput setaf 2) Ubuntu$(tput sgr0) (Debian Distro) required,"
	echo
	echo " also Plesk version needs to be$(tput setaf 2) 12$(tput sgr0) or above"
    echo 
    echo "I now need to close this script --- Sorry."
	echo
    exit 
  fi
fi

####################################################################################################
###                                                                                              ###
###                                   Main Program starts here                                   ###
###                                                                                              ###
####################################################################################################
if [[ -z "$1" ]] ; then # check to make sure there is something after the script name
  echo # Display an error message if no input follows script name
  echo "Usage: ./php-plesk php-version-number  (i.e:$(tput setaf 2) ./php-plesk.sh 5.4.0$(tput sgr0) " 
  echo
  exit 20  # exit code to indicate no input variable specified
else
  if [[ $osVersion == CentOS ]] && [[ $osNumber -lt 6 ]] ; then
    echo 
	echo "  Sorry you are running CentOS 5 or lower. "
	echo "  you need to have CentOS 6 or above -  now exiting."
    echo 
    exit 20
  elif  [[ $pleskVersion -lt 12 ]]	; then
    echo 
	echo "  Sorry you are running Plesk lower than version 12. "
	echo "  Please upgrade your version of Plesk -  now exiting."
    echo 
    exit 20
  elif [[ ! -d "/usr/local/php-$1-cgi/" ]] &&  [[ $osVersion == CentOS ]] ; then
    CentOS_install_php $1
	# Tidy up after script has completed
    rm -f /usr/local/src/php-$phpVersionNumber-cgi.tar.gz
	rm -rf /usr/local/src/php-$phpVersionNumber-cgi
	rm -f temp-wget
  elif [[ ! -d "/usr/local/php-$1-cgi/" ]] &&  [[ $osVersion == Ubuntu ]] ; then
    Ubuntu_install_php $1
	# Tidy up after script has completed
    rm -f /usr/local/src/php-$phpVersionNumber-cgi.tar.bz2
	rm -rf /usr/local/src/php-$phpVersionNumber-cgi
  else
    echo "      Sorry I have struck an error, you may already have this version "
	echo "     of PHP installed, please try another version number  -  now exiting."
    echo
  fi
fi

####################################################################################################
###                                                                                              ###
###                     Clean up unwanted files/folders after install                            ###
###                                                                                              ###
####################################################################################################
echo
echo " php-plesk.sh  Copyright (C) 2015  Michael Sharpe "
echo " This program comes with ABSOLUTELY NO WARRANTY; "
echo " This is free software, and you are welcome to redistribute it"
echo " under certain conditions; Please see: http://www.bashscripts.co.uk/gnu.txt"
echo
exit

