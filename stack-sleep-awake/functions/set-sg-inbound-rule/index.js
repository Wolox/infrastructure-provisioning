console.log('starting function');

const AWS = require('aws-sdk');
const moment = require('moment');
const elasticbeanstalk = new AWS.ElasticBeanstalk();
const ec2 = new AWS.EC2();
const rds = new AWS.RDS();

const fetchDbInstanceSG = (data) => {
  console.log('fetchDbInstanceSG');
  console.log(data);
  return new Promise((resolve, reject) => {
    const params = {
      DBInstanceIdentifier: data.rdsInstance
    };
    rds.describeDBInstances(params, (err, response) => {
      if (err) {
        console.log(err, err.stack);
      } else {
        console.log(response);
        data.rdsSgId = response.DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId;
        resolve(data);
      }
    });
  });
};

const fetchInstanceSG = (instanceId) => {
  console.log('fetchInstanceSG');
  console.log(instanceId);
  return new Promise((resolve, reject) => {
    const params = {
      InstanceIds: [instanceId]
    };
    ec2.describeInstances(params, function (err, data) {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        resolve(data.Reservations[0].Instances[0].SecurityGroups[0]);
      }
    });
  });
};

const fetchEnvironmentSG = (data) => {
  console.log('fetchEnvironmentSG');
  console.log(data);
  return new Promise((resolve, reject) => {
    const params = {
      EnvironmentName: data.environment
    };
    elasticbeanstalk.describeEnvironmentResources(params, (err, response) => {
      if (err) {
        console.log(err, err.stack);
      } else {
        fetchInstanceSG(response.EnvironmentResources.Instances[0].Id).then((sg) => {
          data.envSg = sg;
          resolve(data);
        });

        console.log(data);
      }
    });
  });
};

const authorizeSecurityGroupIngress = (data) => {
  console.log('authorizeSecurityGroupIngress');
  console.log(data);
  return fetchDbInstanceSG(data)
  .then(fetchEnvironmentSG).then((info) => {
    return new Promise((resolve, reject) => {
      const params = {
        GroupId: info.rdsSgId,
        IpPermissions: [
          {
            FromPort: 5432,
            IpProtocol: 'tcp',
            ToPort: 5432,
            UserIdGroupPairs: [
              {
                GroupName: info.envSg.GroupName
              }
            ]
          }
        ]
      };
      ec2.authorizeSecurityGroupIngress(params, (err, result) => {
        if (err) {
          console.log(err, err.stack);
          reject(err);
        } else {
          console.log(result);
          resolve(info);
        }
      });
    });
  });

};

exports.handle = function (e, ctx, cb) {
  console.log('processing event: %j', e);
  const data = { rdsInstance: process.env.RDS_INSTANCE, application: process.env.APPLICATION,
    environment: process.env.ENVIRONMENT };
  authorizeSecurityGroupIngress(data).then(() => {
    cb(null, { rdsSnapshot: e[0].rdsSnapshot, beanstalkTemplate: e[0].beanstalkTemplate });
  }).catch((error) => {
    cb(error);
  });
};
