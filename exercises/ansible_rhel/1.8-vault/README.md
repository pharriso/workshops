# Exercise 1.8 - Working with Ansible Vault

In our previous exercises we have stored variables in plaintext. These variables did not contain sensitive information so that was fine. But what if we want to store things like passwords? We can use Ansible Vault for this use case.

Ansible Vault is a feature of ansible that allows you to keep sensitive data such as passwords or keys in encrypted files, rather than as plaintext in playbooks or roles.

Let's create a vault file. Let's go back to our playbook directory.


## Step 1 - Create vault file

Let's create a directory for our vault exercise.

```bash
mkdir ~/ansible-files/vault
cd ~/ansible-files/vault
```

Now we can create our vault file.

```bash
ansible-vault create vault.yml
```

You will be prompted to enter a password. Feel free to just enter "ansible" as the password.

Once you have entered your password you will be taken into a vi session. Add the following variable:

```bash
secret_password: secret123
```

Save and quit from your vi session. Now try to view the content of your vault file.

```bash
cat vault.yml
$ANSIBLE_VAULT;1.1;AES256
66303562333462633731636337666537393135653034313134323762376536626538646238326339
3739373037346461333939376631303734326536336633370a373165303965366466616433656230
37653861616433393132643338613362383264343836393666623338393436326535303063653264
3636666666633266650a613435386162323165363362653034353437633863313264323330316336
6532306538353739666564323734613461383631646466653836623663376538386
```

If we want to view the contents of the file we need to use the ansible-vault command and enter our password to decrypt the file:

```bash
ansible-vault view vault.yml
Vault password:
secret_password: secret123
```

## Step 2 - Create a playbook that will use vault

Now let's use ansible-vault in a playbook. Create the following playbook. Create a file called `secret_play.yml` with the below contents.

---
**NOTE**

A couple of things to note here. First we are including a variables file using vars_file. This is another way we can manage variables with Ansible. The copy module is often used to copy files to servers. In the below example we are using it to populate a file with trivial content.

<!-- {% raw %} -->
```yaml
---

- name: Testing ansible-vault
  hosts: web
  become: yes
  vars_files:
    - ~/ansible-files/vault/vault.yml
  tasks:
    - name: Create a text file containing our secret password
      copy:
        dest: /root/super_secret.txt
        content: "This is my super secret password - {{ secret_password }}."
        mode: 0600
        owner: root
        group: root
```
<!-- {% endraw %} -->


## Step 3 - Run our playbook

Now try to run the playbook as normal.

```bash
ansible-playbook secret_play.yml
ERROR! Attempting to decrypt but no vault secrets found
```

We couldn't decrypt our vault file. We need to add an additional option to prompt for our vault password.

```bash
ansible-playbook secret_play.yml --ask-vault-pass
Vault password:
```

Let's see if we managed to create our file.

```bash
ansible web -a "cat /root/super_secret.txt" -o -b
```
---

[Click Here to return to the Ansible Linklight - Ansible Engine Workshop](../README.md)
