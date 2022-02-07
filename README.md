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

TODO: backstory of the workshop
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