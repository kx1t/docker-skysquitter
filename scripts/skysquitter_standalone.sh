#!/bin/bash
#
# SkySquitter Interface
# Takes data from any Beast service (readsb, dump1090, etc.) and forwards it using UDP to skysquitter
#
# Usage:
# skysquitter.sh <target_host>:<target_port>
#
# Please configure this with care and use the exact port that is assigned to you by SkySquitter
#
#
# Copyright 2022 kx1t - licensed under the terms and conditions
# of GPLv3. The terms and conditions of this license are included with the Github
# distribution of this package, and are also available here:
#
# Summary of License Terms
# This program is free software: you can redistribute it and/or modify it under the terms of
# the GNU General Public License as published by the Free Software Foundation, either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program.
# If not, see https://www.gnu.org/licenses/.
# -----------------------------------------------------------------------------------

LOOPTIME=10s
#
#
# Check if there's an argument:
if [[ "${1:0:1}" == "-" ]] || [[ "$1" == "" ]]
then
	echo "Usage:"
	echo "$0 <target_host>:<target_port> [<source_host>:<source_port>]"
	echo
	echo "Please use the target_host and target_port values provided to you by SkySquitter"
	echo "If <source_host>:<target_host> is omitted, it will assume localhost:30005 by default."
	exit 1
fi

[[ "$2" == "" ]] && SOURCE="localhost:30005" || SOURCE="$2"

# Check if socat is installed. Install it if it isnt:
if [[ "$(which socat)" == "" ]]
then
	echo "socat not installed. Attempting to install it..."
	sudo apt-get update 2>&1 >>/dev/null
	sudo apt-get install -y socat 2>&1 >>/dev/null
	if [[ "$(which socat)" == "" ]]
	then
		# installation didn't work -- complain and exit
		echo "Cannot find SOCAT and the attempt to install it failed."
		echo "Please install SOCAT (for example: sudo apt-get install socat) and then run this script again."
		exit 1
	else
		echo "socat installed successfully."
	fi
fi

# Now start the socat and loop if it fails:
echo "SkySquitter starting..."
echo "Input obtained from tcp:$SOURCE"
echo "Output written to udp:$1"

while :
do
	socat -d -u tcp:$SOURCE udp:$1
	echo "$(date): Socat exited - restarting in $LOOPTIME seconds"
	sleep $LOOPTIME
done
