#!/usr/bin/python

DOCUMENTATION = r'''
---
module: enum_ad_user_groups.ps1
short_description: Gather associated groups for specified user(s)
description:
    - Gather all groups associated with a specified username. You can specify multiple or a single username
options:
    username:
    description:
    - The username you want to find groups for. You can specify multiple usernames, separating each with a comma (,), or a single username.
    type: str
author:
    Issac (@1d8)
'''

EXAMPLES = r'''
- name: Enumerate specified user(s) groups
  hosts: all
  vars:
    ansible_shell_type: powershell
    ansible_shell_executable: powershell.exe
  tasks:
    - name: Run custom module
      enum_ad_user_perms:
        username: issac, guest, sql_admin, Administrator
      register: result
    
    - name: Print result
      debug:
        var: result.groups
'''

RETURN = r'''
groups:
    group name (result.groups)
'''
