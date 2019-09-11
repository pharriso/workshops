# Exercise 1.9 - Using blocks and rescue

There may be scenarios where you want to perform error handling if there are problems during a playbook run. Blocks can help us with this common scenario. More details on blocks can be found [here](https://docs.ansible.com/ansible/latest/user_guide/playbooks_blocks.html).

## Step 1: Let's add a block

Blocks allow us to logically group our tasks. We will also use blocks to perform error handling later in this exercise. Let's update our `apache-simple` role.

```bash
cd ~/apache-basic-playbook
```

Let's move our role to use blocks first. We will also update our role to perform a smoke test by checking if we get a valid response code from our webservers.

Using vi edit the `roles/apache-simple/tasks/main.yml`. Delete the existing contents of the file and update it as follows.

```yml
{% raw %}
---
# tasks file for apache-simple
- block:
  - name: install httpd packages
    yum:
      name: "{{ item }}"
      state: present
    with_items: "{{ httpd_packages }}"
    notify: restart apache service

  - name: create site-enabled directory
    file:
      name: /etc/httpd/conf/sites-enabled
      state: directory

  - name: copy httpd.conf
    template:
      src: templates/httpd.conf.j2
      dest: /etc/httpd/conf/httpd.conf
    notify: restart apache service

  - name: copy index.html
    template:
      src: templates/index.html.j2
      dest: /var/www/html/index.html

  - name: start httpd
    service:
      name: httpd
      state: started
      enabled: yes

  - name: force handler to run
    meta: flush_handlers

  - name: test our website for status code 200
    uri:
      url: http://{{ ansible_host }}
      status_code: 200
{% endraw %}
```
---
**NOTE**

Firstly, note that we are forcing our handlers to run early. This is because we will want to restart httpd before we try to test our website. Also note the uri module we are using here. This can be used to interact with http & https services to perform operations such as GET, POST, PUT, HEAD, DELETE and more.

---

## Step 2: Run our playbook

Now re-run our playbook. 

```bash
ansible-playbook site.yml
```

You shouldn't see any changes being made. Our smoke test should confirm that our webservers are returning a valid HTTP OK status code.

## Step 3: Change our http listen port

We are now going to update the port that our webserver is listening on. This is going to simulate a configuration error being made.

```bash
cd ~/apache-basic-playbook
sed -i.bak 's/^Listen 80/Listen 81/' roles/apache-simple/templates/httpd.conf.j2
```
Now let's re-run our playbook.

```bash
ansible-playbook site.yml
```

Our playbook has failed now. We tried to smoke test our website on port 80 but our webserver is now mis-configured and is listening on port 81.

## Step 3: rescue to the rescue

Let's update our `roles/apache-simple/tasks/main.yml` file and add a rescue section at the end. The rescue section of the block will run if any errors are encountered. Here we are going to copy our original httpd.conf file back in place if we encounter any errors, force any handlers to run and then smoke test our website again.

```yml
{% raw %}
  rescue:
  - name: Copy our original httpd.conf back in place
    template:
      src: templates/httpd.conf.j2.bak
      dest: /etc/httpd/conf/httpd.conf
    notify: restart apache service

  - name: force handler to run
    meta: flush_handlers

  - name: test our website for status code 200
    uri:
      url: http://{{ ansible_host }}
      status_code: 200
{% endraw %}
```

## Step 4: The Finished role

Your finished role should now look like this.

```yml
{% raw %}
---
# tasks file for apache-simple
- block:
  - name: install httpd packages
    yum:
      name: "{{ item }}"
      state: present
    with_items: "{{ httpd_packages }}"
    notify: restart apache service

  - name: create site-enabled directory
    file:
      name: /etc/httpd/conf/sites-enabled
      state: directory

  - name: copy httpd.conf
    template:
      src: templates/httpd.conf.j2
      dest: /etc/httpd/conf/httpd.conf
    notify: restart apache service

  - name: copy index.html
    template:
      src: templates/index.html.j2
      dest: /var/www/html/index.html

  - name: start httpd
    service:
      name: httpd
      state: started
      enabled: yes

  - name: force handler to run
    meta: flush_handlers

  - name: test our website for status code 200
    uri:
      url: http://{{ ansible_host }}
      status_code: 200

  rescue:
  - name: Copy our original httpd.conf back in place
    template:
      src: templates/httpd.conf.j2.bak
      dest: /etc/httpd/conf/httpd.conf
    notify: restart apache service

  - name: force handler to run
    meta: flush_handlers

  - name: test our website for status code 200
    uri:
      url: http://{{ ansible_host }}
      status_code: 200
{% endraw %}
```

Now let's run our playbook one more time. 

```bash
ansible-playbook site.yml
```

Once a failure is detected with our website, we now run our rescue block which re-instates our known working apache configuration and our webservers are left in a working state.


## Mark Exercise As Completed

Please now run this command:

```bash
cd ~/linklight/exercises/ansible_engine/9-blocks-extra-vars/ && ./completed.sh
```


---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../README.md)
