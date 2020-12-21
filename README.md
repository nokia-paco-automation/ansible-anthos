# ansible anthos

This project automates the deployment of google anthos and nokia packet core.

## create a configuration file for the deployment

to be detailed

## automation steps

0. Install server + switches + cable according to the design principles
1. Install the servers + os + basic packages -> to be automated
2. Configure the switches -> to be automated
3. Create a google project n gcp and create a service account
4. Install gcloud + login to gcloud

```
ansible-playbook playbook/install-gcloud.yaml
login to gcloud with gcloud init
```

5. Install Anthos baremetal

```
ansible-playbook playbook/install-anthosbm.yaml
```

6. prepare telco paco deployment

```
ansible-playbook playbook/prepare-telco-paco.yaml
```

Once all of this is successfull you can install the packet core applications.

```
helm install upf paco-harbor/upf -n upf -f ~/ansible-anthos/build/values_upf.yaml 
helm install smf paco-harbor/smf -n smf -f ~/ansible-anthos/build/values_smf.yaml
helm install amf-cluster paco-harbor/CMM-k8s --version 21.0.0-v8.6.1 -f ~/ansible-anthos/build/values_amf.yaml -n amf

```