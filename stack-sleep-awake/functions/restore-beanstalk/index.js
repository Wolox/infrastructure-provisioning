'use strict';
console.log('starting function');

const AWS = require('aws-sdk');
const moment = require('moment');
const elasticbeanstalk = new AWS.ElasticBeanstalk();
const ec2 = new AWS.EC2();
const rds = new AWS.RDS();

const compare = (a, b) => {
  let aTime = a.split('-');
  aTime = aTime[aTime.length - 1];
  let bTime = b.split('-');
  bTime = bTime[bTime.length - 1];
  // we want latest first
  return aTime < bTime ? 1 : aTime > bTime ? -1 : 0;
};

const getLastestTemplate = (data) => {
  return new Promise((resolve, reject) => {
    const params = {
      ApplicationNames: [data.application]
    };
    elasticbeanstalk.describeApplications(params, (err, applications) => {
      const templates = applications.Applications[0].ConfigurationTemplates;
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        const sorted = templates.sort(compare);
        data.template = sorted[0];
        console.log(data.template);
        resolve(data);
      }
    });
  });
};

const restoreBeanstalkEnvironment = (data) => {
  console.log('restoreBeanstalkEnvironment');
  return new Promise((resolve, reject) => {
    const templateName = data.template;
    const params = {
      ApplicationName: data.application,
      CNAMEPrefix: `${data.application}-${data.environment}`,
      EnvironmentName: data.environment,
      TemplateName: templateName
    };
    elasticbeanstalk.createEnvironment(params, (err, result) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(result);
        resolve(data);
      }
    });
  });
};

exports.handle = function (e, ctx, cb) {
  console.log('processing event: %j', e);
  const data = { application: process.env.APPLICATION, environment: process.env.ENVIRONMENT };
  getLastestTemplate(data)
  .then(restoreBeanstalkEnvironment)
  .then((result) => {
    cb(null, data.template);
  }).catch((error) => {
    cb(error);
  });
};
