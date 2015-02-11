# STIG URL: http://www.stigviewer.com/stig/red_hat_enterprise_linux_6/2014-06-11/finding/V-38623
# Finding ID:	V-38623
# Version:	RHEL-06-000135
# Finding Level:	Medium
#
#     All rsyslog-generated log files must have mode 0600 or less 
#     permissive. Log files can contain valuable information regarding 
#     system configuration. If the system log files are not protected, 
#     unauthorized users could change the logged data, eliminating their 
#     forensic value.
#
#  CCI: CCI-001314
#  NIST SP 800-53 :: SI-11 c
#  NIST SP 800-53A :: SI-11.1 (iv)
#  NIST SP 800-53 Revision 4 :: SI-11 b
#
############################################################

script_V38623-describe:
  cmd.script:
    - source: salt://ash-linux/STIGbyID/cat2/files/V38623.sh

{% set cfgFile = '/etc/rsyslog.conf' %}

# Define list of syslog "facilities":
#    These will be used to look for matching logging-targets
#    within the /etc/rsyslog.conf file
{% set facilityList = [
	'auth', 
	'authpriv', 
	'cron', 
	'daemon', 
	'kern', 
	'lpr', 
	'mail', 
	'mark', 
	'news', 
	'security', 
	'syslog', 
	'user', 
	'uucp', 
	'local0', 
	'local1', 
	'local2', 
	'local3', 
	'local4', 
	'local5', 
	'local6', 
	'local7',
  ]
%}

# Iterate the facility-list to see if there's any active
# logging-targets defined
{% for logFacility in facilityList %}
  {% set srchPat = '^' + logFacility + '\.' %}
  {% if salt['file.search'](cfgFile, srchPat) %}
    {% set cfgStruct = salt['file.grep'](cfgFile, srchPat) %}
    {% set cfgLine = cfgStruct['stdout'] %}
    {% set logTarg = cfgLine.split() %}
    {% set logFile = logTarg.pop() %}

# Ensure that logging-target's filename starts with "/"
    {% if logFile[0] == '/' %}
notify_V38623-{{ logFacility }}:
  cmd.run:
    - name: 'echo "Setting owner of {{ logFile }} to root."'

owner_V38623-{{ logFacility }}:
  file.managed:
    - name: '{{ logFile }}'
    - mode: '0600'
    - replace: false

    {% else %}
{% set logFile = logFile[1:] %}
notify_V38623-{{ logFacility }}:
  cmd.run:
    - name: 'echo "Setting owner of {{ logFile }} to root."'

owner_V38623-{{ logFacility }}:
  file.managed:
    - name: '{{ logFile }}'
    - user: root
    - replace: false

    {% endif %}
  {% endif %}
{% endfor %}
