# BED-Workshop
Contents for the BED Workshop.

## Repository structure

The Workshop is divided into the 5 stages. Each stage has a following branch that contains the contents of of all the workshop until the currently selected stage. In example: stage 3 consists of information from stages 1 and 2, and the information of stage 3. 

This allows to easily transition from first step to another, with the main branch having the end look of the repository. 

The workshop consists of following stages:

1. Performance test Docker image preparation
2. ROS2 Deployment with Kubernetes
3. Performance tests using the built image
4. OSM deployment
5. Middleware introduction
## Backstory 

The scenario behind the workshop supports the idea behind the middleware. It allows having a clear idea of what process is needed to effectively communicate between the middleware and a robot. 

The middleware is the system that handles the communication between the robots and the 5G-ERA system. It is responsible for receiving the information from the robots and translating requests from robots. The communication between the robot and the system allows for coordinating the resources needed for a robot to execute the desired tasks. 

The middleware starts with the signal from the robot to execute a task. When the robot notifies the middleware about the task it wants to execute, middleware translates it into the action plan and deploys the necessary services to be used by the robot during the execution of the steps that the robot has to make. 
The robot is notified to execute specified steps with the support of the deployed services. It executes them in the sequential order defined in the Semantic DB knowledge base for the specified task. The order of the tasks guides it to the end goal which is the execution of the desired task.

The story presented in the workshop focuses on the deployment of the required services in the middleware. It will guide through the reasoning process behind a middleware and how the steps in the workshop correlate to the work that has to be done by the middleware.

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

The middleware is the system placed in between the Robot and the services required by the robot.
### Middleware functionality

The middleware as software is responsible for communication with robots to allow them to have all the resources needed to execute the necessary tasks. It handles the process of receiving the request from the robot, translating the predefined task definition into the action plan. The middleware plans the necessary steps to be executed and the services needed. With the ready plan, it deploys the necessary services. 

When the services are deployed the Robot is informed about the first step that has to be executed and receives the address for the services to be utilized. 

When the robot finishes the current step, is informed about the next one. 

### Middleware assumptions

To make the functionality reliable some assumptions have to be met.

Before the system can handle the communication with the Robot it has to be deployed in the environment that is supposed to work in. While the OSM as the deployment manager is assumed to be deployed only once, the rest of the middleware will be deployed in each location. This means all the Edges and potentially in the cloud.

When the Robot is started it has to inform the system about the task it wants to execute. 
Such information reaches the Middleware and it prepares the Action Plan for the Robot and the Resource plan with the services needed for the robot to execute the desired steps. With the plan prepared and services deployed, the Robot receives the information with the next step to execute, with the services to be utilized, to complete the whole task. 
The robot is supposed to continuously inform the middleware about its status. To make the task easier, the robot will have a service installed on-board that will handle the communication with the system. The software of the robot will have to communicate with the program installed on the robot.
The Robot will also have to respond to the middleware requests to execute the steps given by the middleware. The whole paradigm is similar to the ROS2 Action Server.

The tasks will have to be defied in the Redis Knowledge Base with the necessary steps to execute the task. 

The Middleware will monitor the state of the services used and will inform the Robot if any of them has encountered the error or has been terminated. In the case of prolonged issues with the service, the Middleware should schedule the re-plan and notify the robot about the change of the plan or the availability of the resources. 

During the whole work of the Middleware, the system should keep the up to date services and Robots topology using represented in form of a graph.

After the service is no longer in use by any of the Robots, the Middleware will terminate it.

### Software reliability

Reliability is one of the key principles of good software. So should the 5G-ERA Middleware try to achieve.
But the reliability has to come from the whole system. Even if some components fail, the system should remain functional. 

To ensure reliability the tasks should have implemented the backup plans in case some services will fail. 
The backup plans will be executed when the middleware will fail in restoring the service. During the unavailability of the service, the robot will be notified about the change in the service status. If the service is not available and the re-plan has not solved the issue, the Robot can be informed that the system cannot provide the necessary resources and the calculations should temporarily be conducted by the Robot itself. 
The process of recovering from the service errors should be planned for each service, as different services can have other procedures for the recovery.
When the system recovers from the error caused by one of the systems it should inform the Robot about the availability of the recovered services. 


