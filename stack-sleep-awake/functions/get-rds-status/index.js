'use strict';
console.log('starting function');

const AWS = require('aws-sdk');
const moment = require('moment');
const elasticbeanstalk = new AWS.ElasticBeanstalk();
const ec2 = new AWS.EC2();
const rds = new AWS.RDS();

const restoreDbFromSnapshot = (data) => {
  return new Promise((resolve, reject) => {
    const params = {
      DBInstanceIdentifier: data.rdsInstance
    };
    rds.describeDBInstances(params, (err, result) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(result.DBInstances[0].DBInstanceStatus);
        resolve(result.DBInstances[0].DBInstanceStatus);
      }
    });
  });
};

exports.handle = function (e, ctx, cb) {
  console.log('processing event: %j', e);
  const data = { rdsInstance: e.rds_instance || process.env.RDS_INSTANCE };
  restoreDbFromSnapshot(data).then((status) => {
    cb(null, status);
  }).catch((error) => {
    cb(error);
  });
};
