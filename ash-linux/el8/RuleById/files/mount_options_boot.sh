#!/bin/sh
#
# Finding ID:	
# Version: mount_option_boot_noexec
# SRG ID:	
# Finding Level:	low
#
# Rule Summary:
#       The noexec mount option can be used to prevent binaries
#       from being executed out of /boot.
#
# CCE-82139-7
#
#################################################################
# Standard outputter function
diag_out() {
   echo "${1}"
}

diag_out "--------------------------------------"
diag_out "STIG Finding ID: mount_options_boot"
diag_out "   Set nosuid mount-options on /boot"
diag_out "   to prevent abuses."
diag_out "--------------------------------------"
