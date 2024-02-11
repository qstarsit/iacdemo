# Infrastructure-as-Code demo

This repository is originally created for the IaC meetup given by Ernest on 29-Feb-2024. It includes multiple ways to deploy the same infrastructure in AWS. This infrastructure consists of a EC2 instance running a docker container that runs a webserver. The code not only creates the EC2 instance, but also all required dependencies (vpc, subnet, etc).

The following technologies are demonstrated:

* [Terraform](terraform/); creates the website http://tfdemo.awscloudqstars.nl showing tulips
* [Crossplane](crossplane/); creates the website http://cpdemo.awscloudqstars.nl showing wind mills
* [Pulumi](pulumi/); creates the website http://pudemo.awscloudqstars.nl showing clogs

The source code and documentation for the docker container is [here](https://github.com/pa3hcm/godutch), image is on [Docker Hub](https://hub.docker.com/r/pa3hcm/godutch).