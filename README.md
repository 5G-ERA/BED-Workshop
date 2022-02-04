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

## Stage 5 - Middleware considerations