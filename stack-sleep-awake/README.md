# Stack sleep/awake		

This repository contains Lambda functions that will allow you to put your Beanstalk and RDS services to		
sleep and bring them back up. The aim is to reduce costs.		

## Installing		

1. Create an SNS topic that will be used to send notifications when your stack awakes or goes to sleep		

2. Execute the following. You can leave the *state machine ARN* input empty in this execution		

  ```		
  chmod +x script/bootstrap		
  script/bootstrap		
  ```		

## Deploy		

`apex --profile my-profile deploy`		

## Usage		

### Manual execution		
To **manually** put your infrastructure to sleep just execute `stack-sleep` function.			

### Automatic execution		

The best thing to do is to schedule the execution of both functions. You can achieve this by adding a new **Cloudwatch Schedule** trigger to the previously mentioned functions. 
