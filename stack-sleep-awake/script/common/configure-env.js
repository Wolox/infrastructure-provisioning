"use strict";

const fs = require('fs');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const ask = (obj, message, key) => {
  return new Promise((resolve) => {
    rl.question(message, (value) => {
      const pair = { [key] : value };
      resolve(Object.assign(obj, pair));
    });
  });
};

const config = {};
ask(config, 'What is your rds instance name? ', 'RDS_INSTANCE')
.then((obj) => {
  return ask(obj, 'What is your beanstalk application name? ', 'APPLICATION');
})
.then((obj) => {
  return ask(obj, 'What is your beanstalk environment name? ', 'ENVIRONMENT');
})
.then((obj) => {
  return ask(obj, 'What is your state machine arn? ', 'STATE_MACHINE_ARN');
})
.then((obj) => {
  return ask(obj, 'What is your topic? ', 'TOPIC_ARN');
})
.then((obj) => {
  let projectConfig = {};
  try {
    fs.accessSync('project.json', fs.R_OK | fs.W_OK);
    console.log('Updating project.json ...');
    projectConfig = JSON.parse(fs.readFileSync('project.json'));
  } catch (e) {
    console.log('Creating project.json ...');
    projectConfig = JSON.parse(fs.readFileSync('project-config.json'));
  } finally {
    projectConfig.environment = Object.assign(projectConfig.environment || {}, obj);
    fs.writeFileSync('project.json', JSON.stringify(projectConfig, null, 2));
    process.exit(0);
  }
})
