# BED-Workshop
Contents for the BED Workshop

## Stage 1 - Docker image preparation
This stage describes the process of building the performance_test image for 5G-ERA that is originally created by ApexAI. 

There are 2 ways of building the image. The first one is to execute the command that will automate the steps required.

```shell
$ ./performance_image/build.sh
```
The script in the `performance_image` folder clones the ApexAI performance test repository, checks out to the correct branch and builds the specified `dockerfile` with the image.

After executing the `build.sh` command see the available images in the docker.

```shell
$ docker image ls
```

## Stage 2 
This stage will guide through the deployment of the ROS2 talker and a listener demo. 

The scenario assumes that part of the work being done by the middleware will be a deployment of the services to the kubernetes cluster. 

As on of the perquisites for ROS2 applications to be able to communicate with each other is to enable the multicast support. The multicast is not enabled by default in Kubernetes and the additional network card is needed. For this task, the local instance of Microk8s, a minimal K8s client, has `multus` addon installed.

Multus, when configured, enables the additional network card inside of the specified pods in the Kubernetes cluster.

To configure the additional network interface card in the pods use the `multus_config.yaml` file located in the `ros2_deployment` folder. Enter this folder.

```shell
$ cd ros2_deployment
```

In the `multus_config.yaml` for the correct work, the name of the `master` node has to be set to name of the network card that has an access to the internet on your machine. 

Use `ifconfig` command to retrieve all the names of the NICs in your system.

```shell
$ ifconfig
```
After the `master` property is set, update the IP address ranges to reflect the configuration in your NIC.

When done, apply the changes to the kubernetes cluster.

```shell
$ kubectl apply -f multus_config.yaml
```
### Listener deployment

With the config installed, create the listener deployment as in the `listener.yaml` file. Note the following part of the file:

```yaml
kind: Deployment
metadata:
  name: ros-listener-deployment
  labels:
    app: ros-listener
  annotations:
    k8s.v1.cni.cncf.io/networks: ros-network
```
The `annotations` part defines that the deployment needs to specify the name of the network created in the previous step. 

```shell
$ kubectl apply -f listener.yaml
```

With the listener deployed the logs can be followed by the using the following command:

```shell
$ kubectl logs --follow -l app=ros-listener
```

### Talker deployment

The process of deployment of the talker image is almost the same as for the listener. The file differs in name, labels used to locate the service and in the command used to start the container. 

Also note that the configuration of the additional network interface is still necessary. Remember to check if the additional NIC is assigned to the deployment.


Deploy the talker deployment with the following command.

```shell
$ kubectl apply -f talker.yaml
```



## Stage 3 - Performance image functionality


## Stage 4 - OSM deployment

To clone the example packages to be deployed in the OSM use the following commands.

```shell
$ git clone https://osm.etsi.org/gitlab/vnf-onboarding/osm-packages.git
```
The example packages will be used to deploy the KNF.

To deploy the KNF first some preparations will have to be made.

### Change the Openstack network name

The essential part to making work the deployment is the adjustment of the default network created by the Openstack. 

Retrieve the Openstack password using the command

```shell
$ sudo snap get microstack config.credentials.keystone-password

# unzip the package 

$ tar xvvf osm-packages-master.tar.gz

$ cd osm-packages-master
```

Copy the password and login to the OpenStack panel available at `192.168.56.4`. The username is admin.

After the successful login, navigate to the `Network > Network Topology > Topology` tab and edit the virtual network located on the right-hand side.

Click the network on the topology diagram and then click the `Edit Network` button. Change the name to `mgmt-net`.

### Add K8s cluster

Next switch to the Edge machine and export the Kubernetes configuration.

```shell
$ microk8s.config > kubeconfig.yaml
```

Copy it to the OSM machine and add the new cluster using configuration.

```shell
$ osm k8scluster-add --creds kubeconfig.yaml \
                     --version "1.23" --vim openstack-site\
                     --k8s-nets '{"k8s_net1": "mgmt-net"}' \
                     --description "K8s cluster" my-k8s-cluster
```
When the Kubernetes cluster is added, proceed to add example Virtual network Functions and Network services. OpenLDAP will be used as an example. 
Navigate to the downloaded git repository. Locate the `openldap_knf` and `openldap_ns` folders.

Starting with the first one, edit the `openldap_vnfd.yaml` file to the following contents:

```yaml
vnfd:
  description: KNF with single KDU using a helm-chart for openldap version 1.2.3
  df:
  - id: default-df
  ext-cpd:
  - id: mgmt-ext
    k8s-cluster-net: mgmt-net
  id: openldap_knf
  k8s-cluster:
    nets:
    - id: mgmt-net
  kdu:
  - name: ldap
    helm-chart: stable/openldap
  mgmt-cp: mgmt-ext
  product-name: openldap_knf
  provider: Telefonica
  version: '1.0'
```
Keep in mind to maintain the `k8s-cluster-net` property in pair with the name of the network specified while creating the cluster.

Exit the folder and enter the `openldap_ns` folder.

Edit the `openldap_nsd.yaml` file to the following contents.

```yaml
nsd:
  nsd:
  - description: NS consisting of a single KNF openldap_knf connected to mgmt network
    designer: OSM
    df:
    - id: default-df
      vnf-profile:
      - id: openldap
        virtual-link-connectivity:
        - constituent-cpd-id:
          - constituent-base-element-id: openldap
            constituent-cpd-id: mgmt-ext
          virtual-link-profile-id: mgmt-net
        vnfd-id: openldap_knf
    id: openldap_ns
    name: openldap_ns
    version: '1.0'
    virtual-link-desc:
    - id: mgmt-net
      mgmt-network: 'true'
    vnfd-id:
    - openldap_knf
```
When specifying the `vnfd-id` set is the same as the id of KNF.

Exit the folder. To instantiate the KNF and NS use the following commands

```shell
$ osm nfpkg-create openldap_knf

$ osm nspkg-create openldap_ns
```
Create a new Network Service instance with the following command 

```shell
$ osm ns-create --ns_name ldap --nsd_name openldap_ns \
                --vim_account openstack-site 
```
After logging into the OSM account, and navigating to the `Instances > NS Instances` the new Network Service should be visible during the deployment process or already deployed.


## Stage 5 - Middleware considerations