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