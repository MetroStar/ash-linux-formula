# STIG URL: http://www.stigviewer.com/stig/red_hat_enterprise_linux_6/2014-06-11/finding/V-38567
# Finding ID:	V-38567
# Version:	RHEL-06-000198
# Finding Level:	Low
#
#     The audit system must be configured to audit all use of setuid 
#     programs. Privileged programs are subject to escalation-of-privilege 
#     attacks, which attempt to subvert their normal role of providing some 
#     necessary but limited capability. As such, motivation exists to 
#     monitor these programs for unusual activity.
#
############################################################

script_V38567-describe:
  cmd.script:
    - source: salt://ash-linux/STIGbyID/cat3/files/V38567.sh

########################################################################
# Will need to rewrite this as a set of modules/functions
# - one module to produce an iterable list of files and associated keys
# - one to iterate the list (using the keys for Salt ID) and remediate 
#   as appropriate
#
# NOTE: Current 'helper' script will blow up if there are spaces in the 
# suid/sgid filenames
########################################################################
script_V38567-helper:
  cmd.script:
    - source: salt://ash-linux/STIGbyID/cat3/files/V38567-helper.sh
