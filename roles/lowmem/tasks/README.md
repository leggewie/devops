Usage
=====

This role can be useful as a prepper for low-memory VPS. It stops
"RAM-hungry" services at the very beginning of a playbook and
restarts them at the end.

```
- hosts: vps
  name: pre_task equivalent
  tasks:
  # pre_task equivalent
  - name: Stop some services (pre_task)
    include_role:
      name: lowmem
    vars:
      state: stopped
```

With an equivalent started-call at the end of a run.

Variables
=========

state: {stopped|started}
