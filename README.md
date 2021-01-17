# ansible anthos

This project automates the deployment of Google anthos and Nokia packet core.

## prerequisites

To support ansible install the following modules should be installed

```
sudo apt-get install python3-pip python3-venv -y
python3 -m venv ~/venv
source ~/venv/bin/activate
pip3 install ansible
pip3 install netaddr
ansible-galaxy collection install community.kubernetes
ansible-galaxy collection install ansible.netcommon 
```

## create an inventory file for the deployment

An example inventory file is shown below:

```yaml
all:
  vars:
    proxy:
      http_proxy: <url>
      https_proxy: <url>
      # ensure the kube-api ip address is in the no proxy 
      # otherwise some scripts will fail -> to be automated
      no_proxy: localhost,127.0.0.1,10.4.2.130,10.4.2.2
    anthos_dir: baremetal
    project_id: <project_id>
    cluster_name: <cluster name>
    ansible_user: <username>
    ansible_ssh_private_key_file: ~/.ssh/ansible
    ansible_ssh_extra_args: "-o IdentitiesOnly=yes"
    need_update_dist: false
    install_rt_sched: false
    install_net_driver: true
    storage:
      nfs_server: 172.16.1.200
      nfs_mount: /media/NFS
      csi: nfs-csi
    underlay_networks:
      itfce_cidr: 10.4.2.0/24
      vlan: 132
    cni_networks:
      pod_cidr: 192.168.0.0/16
      svc_cidr: 10.96.0.0/12
    multus_networks:
      ipvlan_name: bond1
      multus_mgmt:
        vlan: [133, 134, 135]
        itfce_cidr: [10.4.3.0/24, 10.4.4.0/24, 10.4.5.0/24]
      multus_3gpp_internal:
        vlan: [136, 137, 138]
        itfce_cidr: [10.4.6.0/24, 10.4.7.0/24, 10.4.8.0/24]
      multus_3gpp_external:
        vlan: [139, 140, 141]
        itfce_cidr: [10.4.9.0/24, 10.4.10.0/24, 10.4.11.0/24]
      multus_3gpp_sba:
        vlan: [142, 143, 144]
        itfce_cidr: [10.4.12.0/24, 10.4.13.0/24, 10.4.14.0/24]
      multus_gi_n6:
        vlan: [145, 146, 147]
        itfce_cidr: [10.4.15.0/24, 10.4.16.0/24, 10.1.17.0/24]
        pool_cidr: 10.0.128.0/17
    paco_sw:
      harbor:
        name: paco-harbor
        url: https://<harbor charts url>
        server: <harbor url>
        image_dir: paco
        email: robot@harbor.nokia.cloudpj.be
        username: xyz
        secret: eyJ...
      elements: [smf, amf, upf]
      upf:
        multus: 3
        loam:
          cpu: 4
          memory: 4Gi
          nodeSelector:
        lmg:
          tag: I3889B
          cpu: 6
          memory: 16Gi
          nodeSelector:
        llb:
          enable: 0
          cpu: 6
          memory: 16Gi
          nodeSelector:
        nasc:
          enable: 0
          tag: test1
          cpu: 100m
          memory: 100Mi
        logging:
          enable: 1
          tag: I3889B
          cpu: 100m
          memory: 100Mi
        awsSideCar:
          enable: 0
          tag: B0-3852
          cpu: 100m
          memory: 100Mi
        network:
          type: sriov
        nat:
          enable: true
      smf:
        multus: 2
        loam:
          cpu: 4
          memory: 4Gi
          nodeSelector:
        lmg:
          tag: I3889B
          cpu: 6
          memory: 16Gi
        llb:
          enable: 0
          cpu: 6
          memory: 16Gi
        nasc:
          enable: 0
          tag: test1
          cpu: 100m
          memory: 100Mi
        logging:
          enable: 1
          tag: I3889B
          cpu: 100m
          memory: 100Mi
        awsSideCar:
          enable: 0
          tag: B0-3852
          cpu: 100m
          memory: 100Mi
        network:
          type: sriov
      amf:
        dbs:
          tag: CMM21.0.0
          cpu: 4
          memory: 8Gi
          nodeSelector:
        emms_amms:
          tag: CMM21.0.0
          cpu: 4
          memory: 16Gi
          nodeSelector:
        ipds:
          tag: CMM21.0.0
          cpu: 6
          memory: 12Gi
          nodeSelector:
        ipps:
          tag: CMM21.0.0
          cpu: 8
          memory: 12Gi
          nodeSelector:
        necc:
          tag: CMM21.0.0
          cpu: 4
          memory: 12Gi
          nodeSelector:
        paps:
          tag: CMM21.0.0
          cpu: 4
          memory: 12Gi
          nodeSelector:
  children:
    workers:
      hosts:
        worker0:
          ansible_host: 10.4.2.4
          eth_name: [ens2f1, ens3f1]
        worker1:
          ansible_host: 10.4.2.3
          eth_name: [ens2f1, ens3f1]
    masters:
      hosts:
        master1:
          ansible_host: 10.4.2.2
          eth_name: [ens2f1, ens3f1]

```

The inventory file consists of 2 main sections, one section for the variables for the deployment and the other section for the hosts involved in the deployment.

- vars section: lists the environment, storage, network, application parameters that are relevant for the deployment
    - proxy: defines the proxy parameters used in your environment, no proxy excludes the proxy for certain ip addresses, domain names. If proxies are used ensure you excludes the kube-api ip address
    - anthos_dir: defines the directory that is used for the anthos cluster deployment
    - project_id: defines the google project id that is used for the deployment
    - cluster_name: defines the cluster name that is used for the google cluster
    - ansible_user: defines the user that is used to execute the playbook
    - ansible_ssh_private_key_file: defines the keyfile that is used by ansible
    - ansible_ssh_extra_args: defines the extra ssh parameters
    - need_update_dist: boolean, defines if the linux os need to be updates
    - install_rt_sched: boolean, defines if a realtime scheduler is needed for the app
    - install_net_driver: boolean, defines if the net drivers, like sriov, dpdk need to be installed.
    - storage: defines the storage parameters
        - nfs_server: defines the ip address of nfs server
        - nfs_mount: defines the drive that nfs server exports
        - csi: right now we support nfs-csi, could be updattes in the future
    - underlay_networks: defines the parameters for the underlay
        - itfce_cidr: defines the cidr used for the underlay
        - vlan: defines vlan that is used for the underlay
    - cni_networks: defines the parameters for the cni network
        - pod_cidr: defines the cidr used for the pod network
        - svc_cidr: defines the cidr used for the svc network
    - multus_networks: defines the parameters for the multus networks
        - ipvlan_name: defines the name of the ipvlan interface
        - multus network names with:
            - vlan: [a1,b1,c1] -> first paramater (a1) is used for ipvlan, 2nd/3rd parameter (b1,c1) is used for sriov interfaces
            - itfce_cidr: [a2,b2,c2] -> first paramater (a2) is used for ipvlan cidr, 2nd/3rd parameter (b2,c2) is used for sriov cidr
    - paco_sw: defines the parameters for packet core sw, like harbor, and paco applications.
        - harbor:
            - name: defines the name of the harbor
            - url: defines the url of the harbor charts
            - server: defines the server domain or ip address
            - image_dir: defines the directory where images are stored on the harbor
            - email: defines the harbor email address
            - username: defines the username to access the harbor
            - secret: defines the secret to access the harbor
        - elements: list that defines which application that the playbook will install
        - per application parameters
            - multus: defines how many multus networks will be used for the application
            - pod information:
                - cpu: defines the required vcpus
                - tag: defines the version of the sw 
                - memory: defines the required memory for the pod 
                - nodeSelector: defines affinity rules for the pod
                - enable: defines if the pod is needed for the installation (0: disabled, 1: enabled)
            - network: defines the type of network the application uses, like sriov, ipvlan, etc
            - nat: defines if nat is enabled for the dataplane, used for gi, n6 interface

- inventory section: lists the host that are involed in the deployment
    - the inventory consists of workers and master host, which are used in the ansible playbook to configure the relevant host parameters (sriov, dpdk, drivers, vlans, etc) to support the paco deployment.
        - Update the master and worker host name that wre relevant for your deployment (worker0, worker1 and master1 in this example)
        - Update the ansible_host ip address per host
        - Update the eth_name interface names that are used for SRIOV on the hosts.


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