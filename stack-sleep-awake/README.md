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
3. The `step-functions.json` is a template you can use to build your state machine. Visit
[AWS Step Functions](https://console.aws.amazon.com/states/home) and create a new State Machine. Paste
the JSON in this file and add the corresponding AWS Lambda Functions in the `resource` fields.

4. Copy the State Machine ARN and paste it in the `project.json` file in the corresponding entry.

## Deploy

`apex --profile my-profile deploy`

## Usage

### Manual execution
To **manually** put your infrastructure to sleep just execute `stack-sleep` function.

To **manually** bring everything back, execute `execute-step-functions`. This will start the state machine.

### Automatic execution

The best thing to do is to schedule the execution of both functions. You can achieve this by adding a new **Cloudwatch Schedule** trigger to the previously mentioned functions. 
