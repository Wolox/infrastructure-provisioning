'use strict';
console.log('starting function');

const AWS = require('aws-sdk');
const moment = require('moment');
const elasticbeanstalk = new AWS.ElasticBeanstalk();
const ec2 = new AWS.EC2();
const rds = new AWS.RDS();

const getBeanstalkVersion = (data) => {
  return new Promise((resolve, reject) => {
    const params = {
      ApplicationName: data.application
    };
    elasticbeanstalk.describeApplicationVersions(params, function (err, result) {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        data.applicationVersion = result.ApplicationVersions[0];
        console.log(data.applicationVersion);
        resolve(data);
      }
    });
  });
};

const deployVersion = (data) => {
  return new Promise((resolve, reject) => {
    console.log(data);
    const params = {
      ApplicationName: data.application,
      EnvironmentName: data.environment,
      VersionLabel: data.applicationVersion.VersionLabel
    };
    elasticbeanstalk.updateEnvironment(params, function (err, result) {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(result);
        resolve(params);
      }
    });
  });
};

exports.handle = function (e, ctx, cb) {
  console.log('processing event: %j', e);
  const data = { application: e.application || process.env.APPLICATION, environment: e.environment || process.env.ENVIRONMENT };
  getBeanstalkVersion(data)
  .then(deployVersion)
  .then((status) => {
    e.beanstalkVersion = status.VersionLabel;
    cb(null, e);
  }).catch((error) => {
    cb(error);
  });
};
