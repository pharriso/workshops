# Exercise 2.7 - Configuration Management and Drift detection

# Configuration Drift

In this exercise we will use Ansible to check the configuration of our linux servers. If we detect any drift then we will put the device back into our desired state and log an incident in ServiceNow for further investigation.

## Install Pre Requisites

In order to use the ServiceNow modules, we need to do a one time install of the dependencies, on the ansible control [Tower] node. Login to your control node and type:

```bash
sudo pip install pysnow
```

## Set up Projects

First you have to set up the Git repo as Projects like you normally would. You have done this before, try to do this on your own. Detailed instructions can be found below.

- Create the project for linux configuration management:

  - It should be named **linux config mgmt**

  - The URL to access the repo is **https://github.com/pharriso/uk_ansible_workshop_playbooks**

> **Warning**
> 
> **Solution Below**

- Create the project for linux config management. In the **Projects** view click the green plus button and fill in:
  
    - **NAME:** linux config mgmt
  
    - **ORGANIZATION:** Default
  
    - **SCM TYPE:** Git
  
    - **SCM URL:** https://github.com/pharriso/uk_ansible_workshop_playbooks.git

    - **SCM UPDATE OPTIONS:** Tick all three boxes.

- Click **SAVE**

## Set up Job Templates

Now you have to create Job Templates like you would for "normal" Jobs.

  - Go to the **Templates** view, click the green plus button and choose **Job Template**:
    
      - **NAME:** linux config mgmt
    
      - **JOB TYPE:** Run
    
      - **INVENTORY:** Workshop Inventory
    
      - **PROJECT:** linux config mgmt
    
      - **PLAYBOOK:** `config_mgmt/linux_config_mgmt.yml`
    
      - **CREDENTIAL:** Workshop Credentials
    
      - **OPTIONS:** Enable privilege escalation

      - **EXTRA VARIABLES**

```
         snow_user: <instructor to provide>
         snow_password: <instructor to provide> 
         snow_instance: <instructor to provide>
```

  - Click **SAVE**

> **Tip**
> 
> If you want to know what the Playbooks look like, check out the Github URL and switch to the appropriate branches.

## Launch the job

Click the blue **LAUNCH** button directly or go to the the **Templates** view and launch the **linux config mgmt** job template by clicking the rocket icon.

We shouldn't see any changes being made. Our servers are already in the desired state. The job summary should show zero changes.

## Let's make a manual change

We'll disable SELinux on one of our servers now. Log onto node1 and set SELinux to permissive mode - this is a classic example ...

```bash
$ sudo setenforce 0
$ getenforce
Permissive
```

Now let's re-launch or config mgmt job template. Observe this time that we have set SELinux back to enforcing mode and we have also raised a ticket in ServiceNow to report this drift so that we can investigate why this changed. The job output should print a ServiceNow ticket number.

Log into ServiceNow - https://<< instance name >>.service-now.com. Use the same credentials you passed into your job template as variables.

In the left hand pane, click on incidents and you should see your incident number. Click on your incident and you will see a comment in the ticket that says "Configuration drift detected in tower job ID XX". This job ID matches the Job ID in your Tower instance so you can easily tie the ServiceNow incident with the Ansible Tower job.

## What About Some Practice?

See if you can schedule the **linux config mgmt** job template to run every hour.

[Click here to return to the Ansible for Red Hat Enterprise Linux Workshop](../README.md#section-2---ansible-tower-exercises)
