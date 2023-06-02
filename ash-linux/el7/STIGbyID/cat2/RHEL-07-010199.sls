#################################################################
{%- set stig_id = 'RHEL-07-010199' %}
{%- set helperLoc = 'ash-linux/el7/STIGbyID/cat2/files' %}
{%- set skipIt = salt.pillar.get('ash-linux:lookup:skip-stigs', []) %}
{%- set targFileList = [
    '/etc/pam.d/system-auth',
    '/etc/pam.d/password-auth',
] %}

{%- if stig_id in skipIt %}
notify_{{ stig_id }}-skipSet:
  cmd.run:
    - name: 'printf "\nchanged=no comment=''Handler for {{ stig_id }} has been selected for skip.''\n"'
    - stateful: True
    - cwd: /root
{%- else %}
##############################################
## Set up "clean" files from downloaded-RPM ##
Clean out cached pam RPM(s):
  module.run:
    - name: file.find
    - path: '/var/cache/yum/packages'
    - kwargs:
        type: 'f'
        name: 'pam-*.rpm'
        delete: 'f'

Re-download pam RPM: # Just in case we need it...
  module.run:
    - name: 'pkg.download'
    - packages:
      - 'pam'

Unpack downloaded RPM:
  cmd.run:
    - name: |
        mkdir /tmp/.{{ stig_id }}.d
        rpm2cpio /var/cache/yum/packages/pam-*.rpm \
        | ( cd /tmp/.RHEL-07-010199.d/ && cpio -idv ./etc/pam.d/*-auth)

##                                          ##
##############################################

  {%- for targFile in targFileList %}
# Make sure existing file isn't a symlink to the authconfig-managed source
Delete {{ targFile }} authconfig symlink:
  file.absent:
    - name: '{{ targFile }}'
    - onlyif:
      - '[[ -e {{ targFile }}-ac ]]'
      - '[[ $( readlink -f {{ targFile }} ) ==  {{ targFile }}-ac ]]'

# Restore from RPM if we nuked the symlink to the authconfig-managed source
Restore {{ targFile }} from RPM-contents:
  file.copy:
    - name: '{{ targFile }}'
    - onchanges:
      - file: 'Delete {{ targFile }} authconfig symlink'
    - source: '/tmp/.{{ stig_id }}.d{{ targFile }}'

# If not a symlink to <FILE>-local, move it to <FILE>-local
Move {{ targFile }} to {{ targFile }}-local:
  file.rename:
    - name: '{{ targFile }}-local'
    - require:
      - file: 'Restore {{ targFile }} from RPM-contents'
    - source: '{{ targFile }}'
    - unless:
      - '[[ -L {{ targFile }} ]]'
      - '[[ -e {{ targFile }}-local ]]'

# Symlink <FILE> to <FILE>-local
Symlink {{ targFile }} to {{ targFile }}-local:
  file.symlink:
    - name: '{{ targFile }}'
    - target: '{{ targFile }}-local'
    - onchanges:
      - file: 'Move {{ targFile }} to {{ targFile }}-local'
    - require_in:
      - file: 'Clean up unpacked RPM'
  {%- endfor %}

Clean up unpacked RPM:
  file.absent:
    - name: '/tmp/.RHEL-07-010199.d'
{%- endif %}
