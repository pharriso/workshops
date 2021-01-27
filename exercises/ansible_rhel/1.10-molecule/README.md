# Exercise 1.10 - Using Molecule To Test Your Roles

Molecule is designed to aid in the development and testing of Ansible roles. Molecule provides support for testing with multiple instances, operating systems and distributions, virtualization providers, test frameworks and testing scenarios.

Molecule uses Ansible playbooks to exercise the role and its associated tests. So we eat our own dog food :)

In this exercise, we'll use molecule in association with podman, a drop-in rootless replacement for docker, to spin up and test our role.

Note: molecule is an upstream open source project, very liable to change.

(This exercise was last tested against - Red Hat Enterprise Linux release 8.3 (Ootpa) - on 27 January 2021)


## Section 1: Installing Components

SSH into your node

### Step 1 - Podman

Now we can install podman and other dependencies for molecule.

```bash
sudo yum -y install podman
sudo systemctl enable podman.socket && sudo systemctl start podman
```

Podman should be running (loaded, active and running):
```bash
sudo systemctl status podman
● podman.service - Podman API Service
   Loaded: loaded (/usr/lib/systemd/system/podman.service; static; vendor preset: disabled)
   Active: active (running) since Wed 2021-01-27 12:15:17 UTC; 1s ago
     Docs: man:podman-system-service(1)
 Main PID: 167860 (podman)
    Tasks: 8 (limit: 23573)
   Memory: 31.8M
   CGroup: /system.slice/podman.service
           └─167860 /usr/bin/podman system service
```

### Step 2 - Molecule

We use pip inside a virtualenv to install molecule:

```bash
sudo yum -y install gcc python3-pip python3-devel openssl-devel libselinux-python3 libffi-devel git python3-virtualenv yamllint
virtualenv --system-site-packages ~/molecule
. ~/molecule/bin/activate
pip install --upgrade pip
pip install molecule molecule[podman] molecule[lint] 
```

```bash
$ molecule
Usage: molecule [OPTIONS] COMMAND [ARGS]...

   _____     _             _
  |     |___| |___ ___ _ _| |___
  | | | | . | | -_|  _| | | | -_|
  |_|_|_|___|_|___|___|___|_|___|

  Molecule aids in the development and testing of Ansible roles.

  Enable autocomplete issue:

    eval "$(_MOLECULE_COMPLETE=source molecule)"

Options:
  --debug / --no-debug    Enable or disable debug mode. Default is disabled.
  -c, --base-config TEXT  Path to a base config.  If provided Molecule will
                          load this config first, and deep merge each
                          scenario's molecule.yml on top.
                          (/home/student1/.config/molecule/config.yml)
  -e, --env-file TEXT     The file to read variables from when rendering
                          molecule.yml. (.env.yml)
  --version               Show the version and exit.
  --help                  Show this message and exit.

Commands:
  check        Use the provisioner to perform a Dry-Run...
  converge     Use the provisioner to configure instances...
  create       Use the provisioner to start the instances.
  dependency   Manage the role's dependencies.
  destroy      Use the provisioner to destroy the instances.
  idempotence  Use the provisioner to configure the...
  init         Initialize a new role or scenario.
  lint         Lint the role.
  list         Lists status of instances.
  login        Log in to one instance.
  matrix       List matrix of steps used to test instances.
  prepare      Use the provisioner to prepare the instances...
  side-effect  Use the provisioner to perform side-effects...
  syntax       Use the provisioner to syntax check the role.
  test         Test (lint, destroy, dependency, syntax,...
  verify       Run automated tests against instances.
  
$ molecule --version
molecule 3.2.2 using python 3.6
    ansible:2.9.16
    delegated:3.2.2 from molecule
    podman:0.3.0 from molecule_podman
```

## Section 2: Creating a New Role Framework

We'll use a simple apache role to test molecule.

### Step 1 - Initalise New Role

```bash
mkdir -p ~/ansible-files/roles
cd ~/ansible-files/roles
molecule init role apache_install --driver-name podman
INFO     Initializing new role apache_install...
Using /home/student1/.ansible.cfg as config file
- Role apache_install was created successfully
INFO     Initialized role in /home/student1/ansible-files/roles/apache_install successfully.
```

Let's have a look at what was created:

```bash
$ tree
.
└── apache_install
    ├── defaults
    │   └── main.yml
    ├── files
    ├── handlers
    │   └── main.yml
    ├── meta
    │   └── main.yml
    ├── molecule
    │   └── default
    │       ├── converge.yml
    │       ├── molecule.yml
    │       └── verify.yml
    ├── README.md
    ├── tasks
    │   └── main.yml
    ├── templates
    ├── tests
    │   ├── inventory
    │   └── test.yml
    └── vars
        └── main.yml
```

This command uses ansible-galaxy behind the scenes to generate a new Ansible role. It then injects a molecule directory in the role, and sets it up to run builds and test runs in a containerised environment.


## Section 3: Testing

### Step 1 - First Tests

Straight out the box, we should be able to do things:

```bash
cd apache_install
molecule create
INFO     default scenario test matrix: dependency, create, prepare
INFO     Running default > dependency
WARNING  Skipping, missing the requirements file.
WARNING  Skipping, missing the requirements file.
INFO     Running default > create
INFO     Sanity checks: 'podman'

PLAY [Create] ***********************************************************************************************************************

TASK [Log into a container registry] ************************************************************************************************
skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'instance', 'pre_build_image': True})

TASK [Check presence of custom Dockerfiles] *****************************************************************************************
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'instance', 'pre_build_image': True})

TASK [Create Dockerfiles from image names] ******************************************************************************************
skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'instance', 'pre_build_image': True})

TASK [Discover local Podman images] *************************************************************************************************
ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'instance', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})

TASK [Build an Ansible compatible image] ********************************************************************************************
skipping: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'instance', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})

TASK [Determine the CMD directives] *************************************************************************************************
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'instance', 'pre_build_image': True})

TASK [Create molecule instance(s)] **************************************************************************************************
changed: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'instance', 'pre_build_image': True})

TASK [Wait for instance(s) creation to complete] ************************************************************************************
FAILED - RETRYING: Wait for instance(s) creation to complete (300 retries left).
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '298323079824.101297', 'results_file': '/home/student2/.ansible_async/298323079824.101297', 'changed': True, 'failed': False, 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'instance', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

PLAY RECAP **************************************************************************************************************************
localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

INFO     Running default > prepare
WARNING  Skipping, prepare playbook not configured.
```

Hopefully that works, so you now have a test framework to work with.

So what did this do and why is it useful?

The 'create' directive effectively spins up some infra we can use to test our role without doing such else.

If we take a look at:

```bash
cat molecule/default/molecule.yml
---
dependency:
  name: galaxy
driver:
  name: podman
platforms:
  - name: instance
    image: docker.io/pycontribs/centos:8
    pre_build_image: true
provisioner:
  name: ansible
verifier:
  name: ansible
```

This helps us to see what's being used. 

The default in the path referes to a 'scenario', and there is always default out-the-box. There is no need to change that for our basic testing example.

We can see that molecule is going to use the podman driver and for a target platform spin up a container instance using a centos8 image.

We can see this in action, using:

```bash
podman images
REPOSITORY                   TAG     IMAGE ID      CREATED        SIZE
docker.io/pycontribs/centos  8       0e8bfa1c168c  10 months ago  752 MB

podman ps
CONTAINER ID  IMAGE                          COMMAND               CREATED         STATUS             PORTS   NAMES
f07640ca9996  docker.io/pycontribs/centos:8  bash -c while tru...  14 minutes ago  Up 14 minutes ago          instance
```

So we have a local centos container image and it's running from the 'molecule create'

### Step 2 - Further Testing

A typical dev cycle is : write some plays/roles -> molecule converge -> rinse and repeat...
Once you're happy you can commit your code to SCM.

```bash
molecule converge
--> Validating schema /home/student1/ansible-files/roles/apache_install/molecule/default/molecule.yml.
Validation completed successfully.
--> Test matrix

└── default
    ├── dependency
    ├── create
    ├── prepare
    └── converge

--> Scenario: 'default'
--> Action: 'dependency'
Skipping, missing the requirements file.
--> Scenario: 'default'
--> Action: 'create'

    PLAY [Create] ******************************************************************

    TASK [Log into a Docker registry] **********************************************
    skipping: [localhost] => (item=None)

    TASK [Create Dockerfiles from image names] *************************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Discover local Docker images] ********************************************
    ok: [localhost] => (item=None)
    ok: [localhost]

    TASK [Build an Ansible compatible image] ***************************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Create docker network(s)] ************************************************

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Wait for instance(s) creation to complete] *******************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    PLAY RECAP *********************************************************************
    localhost                  : ok=5    changed=4    unreachable=0    failed=0


--> Scenario: 'default'
--> Action: 'prepare'
Skipping, prepare playbook not configured.
--> Scenario: 'default'
--> Action: 'converge'

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [instance]

    PLAY RECAP *********************************************************************
    instance                   : ok=1    changed=0    unreachable=0    failed=0
```

### Step 3 - Configuring Molecule

You can see from above that a few things have been skipped. You can tune a lot of the molecule config and what you want it to do by changing the molecule.yml file.

Let's define the test sequence we want. We'll add the test_sequence block under the default scenario.

Change molecule.yml to reflect this:

```bash
cat molecule/default/molecule.yml
---
dependency:
  name: galaxy
driver:
  name: docker
lint:
  name: yamllint
platforms:
  - name: instance
    image: centos:7
provisioner:
  name: ansible
  lint:
    name: ansible-lint
scenario:
  name: default
  test_sequence:
    - lint
    - destroy
    - syntax
    - create
    - converge
    - verify
    - destroy
verifier:
  name: testinfra
  lint:
    name: flake8
```

Now do a test run. You should see some lint errors, something like this:

```bash
molecule test
--> Validating schema /home/student1/ansible-files/roles/apache_install/molecule/default/molecule.yml.
Validation completed successfully.
--> Test matrix

└── default
    ├── lint
    ├── destroy
    ├── syntax
    ├── create
    ├── converge
    ├── verify
    └── destroy

--> Scenario: 'default'
--> Action: 'lint'
--> Executing Yamllint on files found in /home/student1/ansible-files/roles/apache_install/...
Lint completed successfully.
--> Executing Flake8 on files found in /home/student1/ansible-files/roles/apache_install/molecule/default/tests/...
Lint completed successfully.
--> Executing Ansible Lint on /home/student1/ansible-files/roles/apache_install/molecule/default/playbook.yml...
    [701] Role info should contain platforms
    /home/student1/ansible-files/roles/apache_install/meta/main.yml:2
    {'meta/main.yml': {'__file__': u'/home/student1/ansible-files/roles/apache_install/meta/main.yml', u'dependencies': [], u'galaxy_info': {u'description': u'your description', u'license': u'license (GPLv2, CC-BY, etc)', u'author': u'your name', u'company': u'your company (optional)', u'galaxy_tags': [], '__line__': 3, '__file__': u'/home/student1/ansible-files/roles/apache_install/meta/main.yml', u'min_ansible_version': 1.2}, '__line__': 2}}

    [703] Should change default metadata: author
    /home/student1/ansible-files/roles/apache_install/meta/main.yml:2
    {'meta/main.yml': {'__file__': u'/home/student1/ansible-files/roles/apache_install/meta/main.yml', u'dependencies': [], u'galaxy_info': {u'description': u'your description', u'license': u'license (GPLv2, CC-BY, etc)', u'author': u'your name', u'company': u'your company (optional)', u'galaxy_tags': [], '__line__': 3, '__file__': u'/home/student1/apache_basic2/roles/apache_install/meta/main.yml', u'min_ansible_version': 1.2}, '__line__': 2}}

    [703] Should change default metadata: description
    /home/student1/ansible-files/roles/apache_install/meta/main.yml:2
    {'meta/main.yml': {'__file__': u'/home/student1/ansible-files/roles/apache_install/meta/main.yml', u'dependencies': [], u'galaxy_info': {u'description': u'your description', u'license': u'license (GPLv2, CC-BY, etc)', u'author': u'your name', u'company': u'your company (optional)', u'galaxy_tags': [], '__line__': 3, '__file__': u'/home/student1/apache_basic2/roles/apache_install/meta/main.yml', u'min_ansible_version': 1.2}, '__line__': 2}}

    [703] Should change default metadata: company
    /home/student1/ansible-files/roles/apache_install/meta/main.yml:2
    {'meta/main.yml': {'__file__': u'/home/student1/ansible-files/roles/apache_install/meta/main.yml', u'dependencies': [], u'galaxy_info': {u'description': u'your description', u'license': u'license (GPLv2, CC-BY, etc)', u'author': u'your name', u'company': u'your company (optional)', u'galaxy_tags': [], '__line__': 3, '__file__': u'/home/student1/apache_basic2/roles/apache_install/meta/main.yml', u'min_ansible_version': 1.2}, '__line__': 2}}

    [703] Should change default metadata: license
    /home/student1/ansible-files/roles/apache_install/meta/main.yml:2
    {'meta/main.yml': {'__file__': u'/home/student1/ansible-files/roles/apache_install/meta/main.yml', u'dependencies': [], u'galaxy_info': {u'description': u'your description', u'license': u'license (GPLv2, CC-BY, etc)', u'author': u'your name', u'company': u'your company (optional)', u'galaxy_tags': [], '__line__': 3, '__file__': u'/home/student1/apache_basic2/roles/apache_install/meta/main.yml', u'min_ansible_version': 1.2}, '__line__': 2}}

An error occurred during the test sequence action: 'lint'. Cleaning up.
--> Scenario: 'default'
--> Action: 'destroy'

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Wait for instance(s) deletion to complete] *******************************
    ok: [localhost] => (item=None)
    ok: [localhost]

    TASK [Delete docker network(s)] ************************************************

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=1    unreachable=0    failed=0
```

These relate to missing meta data that is expected. 

You can fix this by either removing the meta file:

```bash
mv meta/main.yml meta/main.old
```

Or, fixing the errors suggested in the meta/main.yml file. (This is left up to you :)

Run this to re-run your changes:

```bash
molecule lint
```

### Step 4 - Testing Your Roles

testinfra is included as the default verifier step of molecule. Testinfra uses pytest and makes it easy to test the system after the role is run to ensure our created role has the results that we expected.

We'll not be doing much with it here, but will perform a simple "is package httpd installed" test for validation

Change the test_default.py file to reflect the following. Note: spacing must be consistent (this is Python after all). Don't mix tabs and spaces else molecule will throw errors later on!

```bash
cat molecule/default/tests/test_default.py
import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_httpd_installed(host):
    httpd = host.package('httpd')
    assert httpd.is_installed
```

### Step 5 - Dummy Full Test

Let's run molecule test to see the full cycle in action:

```bash
molecule test
--> Validating schema /home/student1/ansible-files/roles/apache_install/molecule/default/molecule.yml.
Validation completed successfully.
--> Test matrix

└── default
    ├── lint
    ├── destroy
    ├── syntax
    ├── create
    ├── converge
    ├── verify
    └── destroy

--> Scenario: 'default'
[output truncated...]
```

This should FAIL when doing the testinfra as we haven't written the playbook yet for our automation steps.
You should see something like:

```
--> Scenario: 'default'
--> Action: 'verify'
--> Executing Testinfra tests found in /home/student1/ansible-files/roles/apache_install/molecule/default/tests/...
    ============================= test session starts ==============================
    platform linux2 -- Python 2.7.5, pytest-4.4.0, py-1.8.0, pluggy-0.9.0
    rootdir: /home/student1/ansible-files/roles/apache_install/molecule/default
    plugins: testinfra-1.19.0
collected 1 item

    tests/test_default.py F                                                  [100%]

    =================================== FAILURES ===================================
    ___________________ test_httpd_installed[ansible://instance] ___________________

    host = <testinfra.host.Host object at 0x7f2ca393cf10>

        def test_httpd_installed(host):
            httpd = host.package('httpd')
    >       assert httpd.is_installed
    E       assert False
    E        +  where False = <package httpd>.is_installed

    tests/test_default.py:11: AssertionError
    =========================== 1 failed in 6.25 seconds ===========================
An error occurred during the test sequence action: 'verify'. Cleaning up.
```

This is fine as just proves that your testinfra code is working as expected.

## Section 4: Write The Role Tasks

So your testinfra will work, let's write the role contents!

```bash
vi ~/ansible-files/molecule_play.yml

---
- name: Main Playbook
  hosts: web
  become: "yes"

  roles:
    - apache_install
```

Not strictly necessary here, but I'm using the include_tasks directive to show that as well.

```bash
vi ~/ansible-files/roles/apache_install/tasks/main.yml

---
# tasks file for apache_install
- name: Include other playbooks
  include_tasks: install_apache.yml
```

```bash
vi ~/ansible-files/roles/apache_install/tasks/install_apache.yml

---
# tasks file for install_apache

- name: Install Apache
  yum:
    name: httpd
    state: present
  become: "yes"
```


## Section 5: Full Test Run

Let's first test the playbook to prove we've written something useful and workable:

```bash
ansible-playbook ~/ansible-files/molecule_play.yml

PLAY [Main Playbook (molecule_play.yml)] ***********************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************
ok: [node1]
ok: [node2]
ok: [node3]

TASK [apache_install : Include other playbooks] *******************************************************************************************************
included: /home/student1/ansible-files/roles/apache_install/tasks/install_apache.yml for node1, node2, node3

TASK [apache_install : Install Apache] ****************************************************************************************************************
ok: [node3]
ok: [node2]
ok: [node1]

PLAY RECAP ********************************************************************************************************************************************
node1                      : ok=3    changed=0    unreachable=0    failed=0
node2                      : ok=3    changed=0    unreachable=0    failed=0
node3                      : ok=3    changed=0    unreachable=0    failed=0

```

So that worked :)

Now let's do a full on test using molecule:

```bash

cd ~/ansible-files/roles/apache_install
molecule test
--> Validating schema /home/student1/ansible_files/roles/apache_install/molecule/default/molecule.yml.
Validation completed successfully.
--> Test matrix

└── default
    ├── lint
    ├── destroy
    ├── syntax
    ├── create
    ├── converge
    ├── verify
    └── destroy

--> Scenario: 'default'
--> Action: 'lint'
--> Executing Yamllint on files found in /home/student1/ansible-files/roles/apache_install/...
Lint completed successfully.
--> Executing Flake8 on files found in /home/student1/ansible-files/roles/apache_install/molecule/default/tests/...
Lint completed successfully.
--> Executing Ansible Lint on /home/student1/ansible-files/roles/apache_install/molecule/default/playbook.yml...
Lint completed successfully.
--> Scenario: 'default'
--> Action: 'destroy'

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Wait for instance(s) deletion to complete] *******************************
    ok: [localhost] => (item=None)
    ok: [localhost]

    TASK [Delete docker network(s)] ************************************************

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=1    unreachable=0    failed=0


--> Scenario: 'default'
--> Action: 'syntax'

    playbook: /home/student1/ansible-files/roles/apache_install/molecule/default/playbook.yml

--> Scenario: 'default'
--> Action: 'create'

    PLAY [Create] ******************************************************************

    TASK [Log into a Docker registry] **********************************************
    skipping: [localhost] => (item=None)

    TASK [Create Dockerfiles from image names] *************************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Discover local Docker images] ********************************************
    ok: [localhost] => (item=None)
    ok: [localhost]

    TASK [Build an Ansible compatible image] ***************************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Create docker network(s)] ************************************************

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Wait for instance(s) creation to complete] *******************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    PLAY RECAP *********************************************************************
    localhost                  : ok=5    changed=4    unreachable=0    failed=0


--> Scenario: 'default'
--> Action: 'converge'

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [instance]

    TASK [apache_install : Include other playbooks] ********************************
    included: /home/student1/ansible-files/roles/apache_install/tasks/install_apache.yml for instance

    TASK [apache_install : Install Apache] *****************************************
    changed: [instance]

    PLAY RECAP *********************************************************************
    instance                   : ok=3    changed=1    unreachable=0    failed=0


--> Scenario: 'default'
--> Action: 'verify'
--> Executing Testinfra tests found in /home/student1/ansible-files/roles/apache_install/molecule/default/tests/...
    ============================= test session starts ==============================
    platform linux2 -- Python 2.7.5, pytest-4.3.0, py-1.8.0, pluggy-0.9.0
    rootdir: /home/student1/ansible-files/roles/apache_install/molecule/default, inifile:
    plugins: testinfra-1.16.0
collected 1 item

    tests/test_default.py .                                                  [100%]

    =========================== 1 passed in 6.29 seconds ===========================
Verifier completed successfully.
--> Scenario: 'default'
--> Action: 'destroy'

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Wait for instance(s) deletion to complete] *******************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Delete docker network(s)] ************************************************

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=2    unreachable=0    failed=0

```

## Summary: The Finished Playbook

You've explored the basics around using molecule for tesing Ansible.

Much of this content was based around Jeff Geerling's most excellent blog:
https://www.jeffgeerling.com/blog/2018/testing-your-ansible-roles-molecule

---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../README.md)
