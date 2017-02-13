console.log('starting function');

const AWS = require('aws-sdk');
const moment = require('moment');
const elasticbeanstalk = new AWS.ElasticBeanstalk();
const ec2 = new AWS.EC2();
const rds = new AWS.RDS();

const getBeanstalkStatus = (data) => {
  return new Promise((resolve, reject) => {
    const params = {
      ApplicationName: data.application,
      EnvironmentNames: [data.environment]
    };
    elasticbeanstalk.describeEnvironments(params, function (err, result) {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(result.Environments[0].Status);
        resolve(result.Environments[0].Status);
      }
    });
  });
};

exports.handle = function (e, ctx, cb) {
  console.log('processing event: %j', e);
  const data = { application: process.env.APPLICATION, environment: process.env.ENVIRONMENT };
  getBeanstalkStatus(data).then((status) => {
    cb(null, status);
  }).catch((error) => {
    cb(error);
  });
};
