# About this repo

The intention behind this repository is to include scripts and all the necessary tools that can
help us reduce costs and time to provision AWS resources.

Currently we have:

- **[Provisioning](https://github.com/Wolox/infrastructure-provisioning/tree/master/provisioning)**: Is a script that quickly builds a web application stack using Elastic Beanstalk and RDS

- **[Stack sleep/awake](https://github.com/Wolox/infrastructure-provisioning/tree/master/stack-sleep-awake)**: Is a set of AWS Lambda Functions that allows us to shut down Elastic Beanstalk and RDS instances and bring them back up exactly as before being shut down. The sole intention of this is to reduce costs of infrastructure that is not used outside working hours

- **[Scripts](https://github.com/Wolox/infrastructure-provisioning/tree/master/scripts)**: Is a set of scripts that aim to solve common deploy problems.
