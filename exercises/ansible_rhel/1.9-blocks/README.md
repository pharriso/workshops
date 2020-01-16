# Exercise 1.9 - Using blocks and rescue

There may be scenarios where you want to perform error handling if there are problems during a playbook run. Blocks can help us with this common scenario. More details on blocks can be found [here](https://docs.ansible.com/ansible/latest/user_guide/playbooks_blocks.html).

## Step 1: Let's add a block

Blocks allow us to logically group our tasks. We will also use blocks to perform error handling later in this exercise. Let's update our `apache_vhost` role.

```bash
cd ~/ansible-files/
```

Let's move our role to use blocks first. We will also update our role to perform a smoke test by checking if we get a valid response code from our webservers.

Using vi edit the `roles/apache_vhost/tasks/main.yml`. Delete the existing contents of the file and update it as follows.

<!-- {% raw %} -->
```yaml
---
- block:
  - name: install httpd
    yum:
      name: httpd
      state: latest

  - name: start and enable httpd service
    service:
      name: httpd
      state: started
      enabled: true

  - name: ensure vhost directory is present
    file:
      path: "/var/www/vhosts/{{ ansible_hostname }}"
      state: directory

  - name: deliver html content
    copy:
      src: index.html
      dest: "/var/www/vhosts/{{ ansible_hostname }}"

  - name: template vhost file
    template:
      src: vhost.conf.j2
      dest: /etc/httpd/conf.d/vhost.conf
      owner: root
      group: root
      mode: 0644
    notify:
      - restart_httpd

  - name: force handler to run
    meta: flush_handlers

  - name: test our website 
    uri:
      url: http://{{ ansible_host }}:8080
      status_code: 200
      return_content: yes
    register: web_status
    failed_when: "'simple vhost index' not in web_status.content"

```
<!-- {% endraw %} -->

---
**NOTE**

* Firstly, note that we are forcing our handlers to run early. This is because we will want to restart httpd before we try to test our website. 
* Note the uri module we are using here. This can be used to interact with http & https services to perform operations such as GET, POST, PUT, HEAD, DELETE and more.
* Finally, see how we have used register to capture the results of our uri module. We are then failing the task if we don't see "simple vhost index" in our output.


---

## Step 2: Run our playbook

Now re-run our playbook. 

```bash
cd ~/ansible-files
ansible-playbook test_apache_role.yml
```

You shouldn't see any changes being made. Our smoke test should confirm that our webservers are returning a valid HTTP OK status code.

## Step 3: Change our http listen port

We are now going to update the port that our webserver is listening on. This is going to simulate a configuration error being made.

```bash
cd ~/ansible-files
sed -i.bak 's/^<VirtualHost.*/<VirtualHost *:8081>/' roles/apache_vhost/templates/vhost.conf.j2
```
Now let's re-run our playbook.

```bash
ansible-playbook test_apache_role.yml
```

Our playbook has failed now. We tried to smoke test our website on port 8080 but our webserver is now mis-configured and is listening on port 8081.

## Step 3: rescue to the rescue

Let's update our `roles/apache-vhost/tasks/main.yml` file and add a rescue section at the end. The rescue section of the block will run if any errors are encountered. Here we are going to copy our original httpd.conf file back in place if we encounter any errors, force any handlers to run and then smoke test our website again.

<!-- {% raw %} -->
```yaml
  rescue:
  - name: Copy our original vhost config back in place
    template:
      src: vhost.conf.j2.bak
      dest: /etc/httpd/conf.d/vhost.conf
    notify: restart_httpd

  - name: force handler to run
    meta: flush_handlers

  - name: test our website
    uri:
      url: http://{{ ansible_host }}:8080
      status_code: 200
      return_content: yes
    register: web_status
    failed_when: "'simple vhost index' not in web_status.content"
```
<!-- {% endraw %} -->

## Step 4: The Finished role

Your finished role should now look like this.

<!-- {% raw %} -->
```yaml
---
- block:
  - name: install httpd
    yum:
      name: httpd
      state: latest

  - name: start and enable httpd service
    service:
      name: httpd
      state: started
      enabled: true

  - name: ensure vhost directory is present
    file:
      path: "/var/www/vhosts/{{ ansible_hostname }}"
      state: directory

  - name: deliver html content
    copy:
      src: index.html
      dest: "/var/www/vhosts/{{ ansible_hostname }}"

  - name: template vhost file
    template:
      src: vhost.conf.j2
      dest: /etc/httpd/conf.d/vhost.conf
      owner: root
      group: root
      mode: 0644
    notify:
      - restart_httpd

  - name: force handler to run
    meta: flush_handlers

  - name: test our website 
    uri:
      url: http://{{ ansible_host }}:8080
      status_code: 200
      return_content: yes
    register: web_status
    failed_when: "'simple vhost index' not in web_status.content"

  rescue:
  - name: Copy our original vhost config back in place
    template:
      src: vhost.conf.j2.bak
      dest: /etc/httpd/conf.d/vhost.conf
    notify: restart_httpd

  - name: force handler to run
    meta: flush_handlers

  - name: test our website
    uri:
      url: http://{{ ansible_host }}:8080
      status_code: 200
      return_content: yes
    register: web_status
    failed_when: "'simple vhost index' not in web_status.content"
```
<!-- {% endraw %} -->

Now let's run our playbook one more time. 

```bash
ansible-playbook test_apache_role.yml
```

Once a failure is detected with our website, we now run our rescue block which re-instates our known working apache configuration and our webservers are left in a working state.


---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../README.md)
