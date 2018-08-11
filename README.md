# amdgpu-pro-fans

Author: DominiLux
License: Apache Version 2.0

This is an alpha release written in unix style bash script.  It is a simple utility that allows you to set the fan speeds for AMD cards that support use the AMD GPU PRO driver.  There are many features I will be adding to this over the coming days and weeks.

## Stable Branch
The current master branch is considered the stable release.  The code in the development branch may not have been fully tested.

## Installation Instructions:
* sudo apt-get install git
* git clone https://github.com/darkjarris/amdgpu-pro-fans
* cd amdgpu-pro-fans
* chmod +x amdgpu-pro-fans.sh

## Usage:
sudo ./amdgpu-pro-fans.sh -s [speed 0 - 100]
./amdgpu-pro-fans.sh -t
./amdgpu-pro-fans.sh -r
./amdgpu-pro-fans.sh -h

## Usage Example:
sudo ./amdgpu-pro-fans.sh -s 80
This would set all of your fan speeds to 80 percent of their maximum speed.  The argument works perfectly as of the current stable release.

./amdgpu-pro-fans.sh -t
This will show the current temperature in Centigrade.

./amdgpu-pro-fans.sh -r
This will show current fan speed percentage.

./amdgpu-pro-fans.sh -h
This shows the help feature (was missing)

## Notes:
Fully tested on Ubuntu 16.04 with AMDGPU-PRO proprietary linux drivers.  It is now compatible with all Radeon R8 Series, R9 Series, and RX Series graphics cards.  I will be adding the option to specify a specific adapter soon.  It will be in the works in the development branch and I will merge it here once it's coded, tested, and debugged.

This version defaults to all adapters.
