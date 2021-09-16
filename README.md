# ansible-anthos

This project automates the deployment of Google anthos and Nokia packet core using an Nokia SRL fabric.

## Prerequisites

To support ansible install the following modules should be installed:

```
sudo apt-get install python3-pip python3-venv -y
python3 -m venv ~/venv
source ~/venv/bin/activate
pip3 install ansible
pip3 install netaddr
ansible-galaxy collection install community.kubernetes
ansible-galaxy collection install ansible.netcommon 
```

## Usage

### 1. Physically install servers, SRL switches and cables according to the HLD.
### 2. Setup the out of band conenctivity for the servers and SRL switches(+ save rescue config).
### 3. Install a jumphost VM and connect it to the out of band network.
### 4. Clone the ansible-anthos repo to the jumphost vm and install its prerequisites
### 5. Create an input.yaml file for the deployment with the relevant deployment information in the root dir

The inventory file needs to be created based on the config example shown in the [paco-parser repo](https://github.com/nokia-paco-automation/paco-parser/blob/master/conf/paco-deployment-telenet-multinet.yaml).

### 6. Parse the input.yam file

```
ansible-playbook playbooks/parse-input.yaml
```

### 7. Apply the config to the SRL leafs

```
ansible-playbook playbooks/parse-input.yaml
```

### 7. Deploy the Os on the servers and configure the bonds to the SRL leafs

### 8. Install Google Anthos
```
ansible-playbook playbooks/install-gcloud.yaml
gcloud init
ansible-playbook playbooks/install-anthosbm.yaml
```
### 9. Install Google Anthos Telco Extensions
```
ansible-playbook playbooks/prepare-telco-paco.yaml
```
### 10. Deploy the Nokia Packet Core Apps
```
helm install upf paco-harbor/upf -n upf -f ~/ansible-anthos/build/paco-parser/app-values/values_upf.yaml 
helm install smf paco-harbor/smf -n smf -f ~/ansible-anthos/build/paco-parser/app-values/values_smf.yaml
helm install amf-cluster paco-harbor/CMM-k8s --version 21.0.0-v8.6.1 -f ~/ansible-anthos/build/paco-parser/app-values/values_amf.yaml -n amf
```


