console.log('starting function');

const AWS = require('aws-sdk');
const moment = require('moment');
const elasticbeanstalk = new AWS.ElasticBeanstalk();
const stepfunctions = new AWS.StepFunctions();
const ec2 = new AWS.EC2();
const rds = new AWS.RDS();

const executeStateMachine = () => {
  return new Promise((resolve, reject) => {
    const params = {
      stateMachineArn: process.env.STATE_MACHINE_ARN
    };
    stepfunctions.startExecution(params, function (err, data) {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(data);
        resolve(data);
      }
    });
  });
};

exports.handle = function (e, ctx, cb) {
  console.log('processing event: %j', e);
  executeStateMachine().then((status) => {
    cb(null, status);
  }).catch((error) => {
    cb(error);
  });
};
