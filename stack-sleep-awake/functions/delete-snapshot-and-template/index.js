'use strict';
console.log('starting function');

const AWS = require('aws-sdk');
const moment = require('moment');
const elasticbeanstalk = new AWS.ElasticBeanstalk();
const ec2 = new AWS.EC2();
const rds = new AWS.RDS();

const dbSnapshotExists = (data) => {
  console.log('dbSnapshotExists');
  console.log(data);
  return new Promise((resolve, reject) => {
    const params = {
      DBSnapshotIdentifier: data.rdsSnapshot,
      SnapshotType: 'manual'
    };
    rds.describeDBSnapshots(params, function (err, result) {
      if (err) {
        if (err.code === 'DBSnapshotNotFound') {
          data.snapshotExists = false;
          return resolve(data);
        }
        reject(err);
      } else {
        const exists = result && result.DBSnapshots.length > 0;
        data.snapshotExists = exists;
        return resolve(data);
      }
    });
  });
};

const deleteDBSnapshot = (data) => {
  console.log('deleteDBSnapshot');
  console.log(data);
  return dbSnapshotExists(data)
  .then((enhancedData) => {
    return new Promise((resolve, reject) => {
      if (!enhancedData.snapshotExists) {
        console.log('RDS Snapshot does not exists...');
        return resolve(enhancedData);
      }
      const params = {
        DBSnapshotIdentifier: enhancedData.rdsSnapshot
      };
      rds.deleteDBSnapshot(params, function (err, response) {
        if (err) {
          console.log(err, err.stack);
          return reject(err);
        } else {
          console.log(response);
          return resolve(enhancedData);
        }
      });
    });
  });
};

const beanstalkTemplateExists = (data) => {
  console.log('beanstalkTemplateExists');
  console.log(data);
  return new Promise((resolve, reject) => {
    const params = {
      ApplicationNames: [data.application || process.env.APPLICATION]
    };
    elasticbeanstalk.describeApplications(params, (err, applications) => {
      const templates = applications.Applications[0].ConfigurationTemplates;
      data.templateExists = false;
      templates.forEach((template) => {
        if (template === data.beanstalkTemplate) {
          data.templateExists = true;
        }
      });
      resolve(data);
    });
  });
};

const deleteBeanstalkTemplate = (data) => {
  console.log('deleteBeanstalkTemplate');
  console.log(data);
  return beanstalkTemplateExists(data)
  .then((enhancedData) => {
    if (!enhancedData.templateExists) {
      return Promise.resolve(enhancedData);
    }
    const params = {
      ApplicationName: data.application || process.env.APPLICATION,
      TemplateName: data.beanstalkTemplate
    };
    elasticbeanstalk.deleteConfigurationTemplate(params, function (err, result) {
      if (err) {
        console.log(err, err.stack);
        return Promise.reject(err);
      } else {
        console.log(result);
        return Promise.resolve(enhancedData);
      }
    });
  });
};

exports.handle = function (e, ctx, cb) {
  console.log('processing event: %j', e);
  deleteDBSnapshot(e)
  .then(deleteBeanstalkTemplate)
  .then((result) => {
    cb(null, e);
  }).catch((error) => {
    cb(error);
  });
};
