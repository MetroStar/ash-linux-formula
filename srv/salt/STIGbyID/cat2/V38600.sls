# STIG URL: http://www.stigviewer.com/stig/red_hat_enterprise_linux_6/2014-06-11/finding/V-38600
# Finding ID:	V-38600
# Version:	RHEL-06-000080
# Finding Level:	Medium
#
#     The system must not send ICMPv4 redirects by default. Sending ICMP 
#     redirects permits the system to instruct other systems to update 
#     their routing information. The ability to send ICMP redirects is only 
#     appropriate for routers.
#
############################################################

script_V38600-describe:
  cmd.script:
  - source: salt://STIGbyID/cat2/files/V38600.sh

{% if salt['file.search']('/etc/sysctl.conf', 'net.ipv4.conf.default.send_redirects')
 %}
file_V38600-repl:
  file.replace:
  - name: '/etc/sysctl.conf'
  - pattern: '^net.ipv4.conf.default.send_redirects.*$'
  - repl: 'net.ipv4.conf.default.send_redirects = 0'
{% else %}
file_V38600-append:
  file.append:
  - name: '/etc/sysctl.conf'
  - text:
    - ' '
    - '# Enable TCP SYN-cookies'
    - 'net.ipv4.conf.default.send_redirects = 0'
{% endif %}

