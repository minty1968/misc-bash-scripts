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
tr -d '\r' < "$1" > t
mv -f t "$1"
exit 0