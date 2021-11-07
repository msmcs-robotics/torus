# Torus

> An automated, scalable NN training system.
> - Run setups scripts on each node
> - Automated Node Control enhanced by [Ansible](https://www.ansible.com/)
> - NN Deployment using on [Docker](https://www.docker.com/), [Kubernetes](https://kubernetes.io/), [Kubeflow](https://www.kubeflow.org/)
> - Notifications based on [Matrix](https://matrix.org/)  --> **Full Credit for Notifications: [@lberrymage](https://github.com/lberrymage)**
----------------------------------------------------
> - Raspberry Pis (ARM64) using specific variants of [Kubernetes](https://microk8s.io/), [Kubeflow](https://www.kubeflow.org/docs/distributions/microk8s/kubeflow-on-microk8s/)


### Starting Point

1. On a machine used for administeringthe cluster, run the cssh script.

2. Run the generated cssh command
  
  2.1. This will help to accept all node ssh keys

3. With cssh, clone the torus repo
  
4. Run the setup-1 script corresponding to each node's OS and architecture, and pass desired arguments.
  
  4.1. This will setup each node's hostname, allowing better network organization
  
  4.2. This will also install required packages for torus.
  
  4.3. Rebooting will take plave and you can CSSH into the nodes to delete the torus repo
  
  *You should not need it in the future thanks to ansible*
  
**Support for the following OS distributions in progres:**
- Raspbian
- Ubuntu
- Arch
