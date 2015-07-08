#!/bin/bash

ESX_SSH() {
cmd="$1"
echo $cmd
ssh root@10.24.0.101 "$cmd ; exit "
[ "$?" = "0" ] && echo "OK - $cmd" || echo "FAILED - $cmd"
}

ESX_SSH "esxcli storage vmfs unmap -l iscsi_lable01"
ESX_SSH "esxcli storage vmfs unmap -l iscsi_lable02"

exit
