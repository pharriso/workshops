#!/usr/bin/bash

#
# update InfluxDB - student progress checker
#

if [ -z $1 ]
then
  echo "Please supply lesson as an argument"
	exit 99
fi

prereq="influxdb"
export lesson="$1"
export student="$USER"
export lab="rhel"

pip show $prereq >/dev/null 2>&1
if [ $? -ne 0 ]
then
  echo "Need to install pre-reqs..."
  pip install influxdb --user >/dev/null 2>&1
fi


cat >${HOME}/influxdb-update.yml<<EOF
---
- hosts: localhost
  connection: local
  gather_facts: true
  name: Update Progress

  vars:
    lesson: "$lesson"
    value: "$value" 

  tasks:
    - name: Mark lesson as done
      influxdb_write:
        hostname: ec2-35-178-141-104.eu-west-2.compute.amazonaws.com
        database_name: ansibleworkshops
        username: student
        password: ansible
        ssl: yes
        validate_certs: no
        data_points:
          - measurement: progress
            tags:
              student: $student
              lab: $lab
            time: "{{ ansible_date_time.iso8601 }}"
            fields:
              $lesson: 1
EOF

ansible-playbook ${HOME}/influxdb-update.yml 
