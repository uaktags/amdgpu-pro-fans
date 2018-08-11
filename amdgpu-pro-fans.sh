#!/usr/bin/env bash
#####################################
#  AMDGPU-PRO LINUX UTILITIES SUITE  #
######################################
# Utility Name: AMDGPU-PRO-FANS
# Version: 0.2.0
# Version Name: MahiMahi
# https://github.com/DominiLux/amdgpu-pro-fans

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#####################################################################
#                          *** IMPORTANT ***                        #
# DO NOT MODIFY PAST THIS POINT IF YOU DONT KNOW WHAT YOUR DOING!!! # 
#####################################################################

############################
# COMMAND PARSED VARIABLES #
############################
adapter="all"
targettemp=""
fanpercent=""
arguments="$@"
verbosity="1"
##################
# USAGE FUNCTION #
##################
usage ()
{
    echo "* AMDGPU-PRO-FANS *"
    echo "error: invalid arguments"
    echo "usage: $0 [-s <0-100>] to set fan speed percentage"
    echo "usage: $0 [-r] to read current fan speed percentage"
    echo "usage: $0 [-t] to read current temperature"
    echo "usage: $0 [-v <0-1>] to change verbosity. 0 = none. 1 = verbose."
    echo "usage: $0 [-h] for help..."
    exit
}

###########################
# SET FAN SPEED FUNCTIONS #
###########################

set_all_fan_speeds ()
{
    cardcount="0";
    for CurrentCard in  /sys/class/drm/card?/ ; do
         for CurrentMonitor in "$CurrentCard"device/hwmon/hwmon?/ ; do
              cd $CurrentMonitor # &>/dev/null
              workingdir="`pwd`"
              fanmax=$(head -1 "$workingdir"/pwm1_max)
              if [ $fanmax -gt 0 ] ; then    
                  speed=$(( fanmax * fanpercent ))
                  speed=$(( speed / 100 ))
                  sudo chown $USER "$workingdir"/pwm1_enable
                  sudo chown $USER "$workingdir"/pwm1
                  sudo echo -n "1" >> $workingdir/pwm1_enable # &>/dev/null
                  sudo echo -n "$speed" >> $workingdir/pwm1 # &>/dev/null
                  speedresults=$(head -1 "$workingdir"/pwm1)
                  if [ $(( speedresults - speed )) -gt 6 ] ; then
                  	if [ "$verbosity" -eq 0 ] ; then echo "-2" ; fi
                  	if [ "$verbosity" -eq 1 ] ; then echo "Error Setting Speed For Card$cardcount!" ; fi
                       
                  else
                       if [ "$verbosity" -eq 0 ] ; then echo "$fanpercent" ; fi
                       if [ "$verbosity" -eq 1 ] ; then echo "Card$cardcount Speed Set To $fanpercent %" ; fi
                       
                  fi
              else
                  if [ "$verbosity" -eq 0 ] ; then echo "-1" ; fi
                  if [ "$verbosity" -eq 1 ] ; then echo "Error: Unable To Determine Maximum Fan Speed For Card$cardcount!" ; fi
                  
              fi
         done
         cardcount="$(($cardcount + 1))"
    done
}

read_all_fan_speeds ()
{
    cardcount="0";
    for CurrentCard in  /sys/class/drm/card?/ ; do
         for CurrentMonitor in "$CurrentCard"device/hwmon/hwmon?/ ; do
              cd $CurrentMonitor # &>/dev/null
              workingdir="`pwd`"
              fanspeed=$(head -1 "$workingdir"/pwm1)
              fanmax=$(head -1 "$workingdir"/pwm1_max)
              if [ $fanspeed -gt 0 ] ; then
              		speedf=$( echo "scale=2; $fanspeed / $fanmax * 100" | bc)
                  speed=${speedf%.*}
                  if [ "$verbosity" -eq 0 ] ; then echo "$speed" ; fi
                  if [ "$verbosity" -eq 1 ] ; then echo "Fan speed on Card$cardcount is $speed%" ; fi          
              else
                  if [ "$verbosity" -eq 0 ] ; then echo "-1" ; fi  
                  if [ "$verbosity" -eq 1 ] ; then echo "Error: Unable To Determine Fan Speed For Card$cardcount!" ; fi
              fi
         done
         cardcount="$(($cardcount + 1))"
    done
}

read_current_temperature ()
{
    cardcount="0";
    for CurrentCard in  /sys/class/drm/card?/ ; do
         for CurrentMonitor in "$CurrentCard"device/hwmon/hwmon?/ ; do
              cd $CurrentMonitor # &>/dev/null
              workingdir="`pwd`"
              temp=$(head -1 "$workingdir"/temp1_input)
              temp=$(( $temp/1000 ))
              if [ $temp -gt 0 ] ; then
                  if [ "$verbosity" -eq 0 ] ; then echo "$temp" ; fi
                  if [ "$verbosity" -eq 1 ] ; then echo "Temperature on Card$cardcount is $temp%" ; fi     
              else
                  if [ "$verbosity" -eq 0 ] ; then echo "-1" ; fi   
                  if [ "$verbosity" -eq 1 ] ; then echo "Error: Unable To Determine Card Temperature For Card$cardcount!" ; fi
              fi
         done
         cardcount="$(($cardcount + 1))"
    done
}

set_fans_requested ()
{
    if [ "$adapter"="all" ] ; then
        set_all_fan_speeds
    fi
}


#################################
# PARSE COMMAND LINE PARAMETERS #
#################################
command_line_parser ()
{
     parseline=`getopt -s bash -u -o a:s:rhtv: -n '$0' -- "$arguments"` 
     eval set -- "$parseline"
     while true ; do
        case "$1" in
            -a ) adapter="$2" ; shift 2 ;;
            -v ) verbosity="$2" ; shift 2 ;;
            -s ) fanpercent="$2" ; set_fans_requested ; shift 2 ; break;;
            -r ) read_all_fan_speeds ; shift 2 ; break;;
            -t ) read_current_temperature ; shift 2 ; break;;
            --)  break ;;
            -h) usage ; exit 1 ;;
            *) usage ; exit 1 ;;
        esac    
    done    
}

#################
# Home Function #
#################

command_line_parser
exit;
