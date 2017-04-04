'use strict';
const AWS = require('aws-sdk');
const moment = require('moment');
const elasticbeanstalk = new AWS.ElasticBeanstalk();
const ec2 = new AWS.EC2();
const rds = new AWS.RDS();
// const sleep = require('sleep');

const saveBeanstalkEnvironmentConfiguration = (environmentData) => {
  return new Promise((resolve, reject) => {
    const params = {
      ApplicationName: environmentData.application,
      EnvironmentId: environmentData.environmentId,
      TemplateName: `${environmentData.application}-${environmentData.environment}-${moment().format('YYYYMMDD')}`
    };
    console.log('Saving beanstalk configuration...');
    elasticbeanstalk.createConfigurationTemplate(params, (err, data) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(`Template created: ${JSON.stringify(data)}`);
        resolve(environmentData);
      }
    });
  });
};

const terminateBeanstalkEnvironment = (environmentData) => {
  return new Promise((resolve, reject) => {
    const params = {
      EnvironmentId: environmentData.environmentId
    };
    console.log('Terminating beanstalk environment...');
    elasticbeanstalk.terminateEnvironment(params, (err, data) => {
      if (err) {
        console.log(err, err.stack);
        reject();
      } else {
        console.log(`Terminated environment: ${JSON.stringify(data)}`);
        resolve();
      }
    });
  });
};

const getBeanstalkEnvironmentId = (application, environment) => {
  console.log('Fetching beanstalk environment id...');
  return new Promise((resolve, reject) => {
    const params = {
      ApplicationName: application,
      EnvironmentNames: [environment],
      IncludeDeleted: false
    };
    elasticbeanstalk.describeEnvironments(params, (err, data) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(data);
        resolve({ application, environmentId: data.Environments[0].EnvironmentId, environment });
      }
    });
  });
};

const saveAndTerminateBeanstalkEnvironment = (application, environment) => {
  getBeanstalkEnvironmentId(application, environment)
  .then(saveBeanstalkEnvironmentConfiguration)
  .then(terminateBeanstalkEnvironment);
};

const deleteInstance = (data) => {
  const instance = data.instance;
  console.log(`Deleting db instance ${JSON.stringify(instance)} ...`);
  return new Promise((resolve, reject) => {
    const params = {
      DBInstanceIdentifier: instance.DBInstanceIdentifier,
      FinalDBSnapshotIdentifier: `${instance.DBInstanceIdentifier}-${moment().format('YYYYMMDD')}`,
      SkipFinalSnapshot: false
    };
    console.log('Terminating RDS instance...');
    rds.deleteDBInstance(params, (err, result) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(result);
        return resolve(result);
      }
    });
  });
};

const getInstance = (instance) => {
  console.log('Fetching db instance details...');
  return new Promise((resolve, reject) => {
    const params = {
      DBInstanceIdentifier: instance
    };
    rds.describeDBInstances(params, (err, data) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(JSON.stringify(data));
        resolve(data.DBInstances[0]);
      }
    });
  });
};

const getExistingRules = (instance) => {
  console.log('Geting existing rules...');
  const securityGroup = instance.VpcSecurityGroups[0].VpcSecurityGroupId;
  return new Promise((resolve, reject) => {
    const params = {
      DryRun: false,
      GroupIds: [securityGroup]
    };
    ec2.describeSecurityGroups(params, (err, data) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(JSON.stringify(data));
        resolve({ instance, securityGroup, ipPermissions: data.SecurityGroups[0].IpPermissions[0] });
      }
    });
  });
};

const getSecurityGroupInformation = (data) => {
  console.log('Fetching further info on security group');
  const ipPermissions = data.ipPermissions;
  return new Promise((resolve, reject) => {
    const params = {
      GroupIds: [ipPermissions.UserIdGroupPairs[0].GroupId]
    };
    ec2.describeSecurityGroups(params, (err, result) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(result);
        data.sourceSecurityGroup = result.SecurityGroups[0];
        resolve(data);
      }
    });
  });
};

const doRemoveRule = (data) => {
  const securityGroup = data.securityGroup;
  const sourceSecurityGroup = data.sourceSecurityGroup;
  const ipPermissions = data.ipPermissions;

  console.log('Removing existing rules...');
  return new Promise((resolve, reject) => {
    const params = {
      GroupId: securityGroup,
      IpPermissions: [
        {
          IpProtocol: ipPermissions.IpProtocol,
          FromPort: ipPermissions.FromPort,
          ToPort: ipPermissions.ToPort,
          UserIdGroupPairs: [
            {
              UserId: sourceSecurityGroup.OwnerId,
              GroupName: sourceSecurityGroup.GroupName
            }
          ]
        }
      ]
    };
    console.log(JSON.stringify(params));
    ec2.revokeSecurityGroupIngress(params, (err, result) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(JSON.stringify(result));
        resolve(data);
      }
    });
  });
};

const removeExistingRules = (data) => {
  return getSecurityGroupInformation(data).then(doRemoveRule);
};

const doDeleteSecurityGroup = (data) => {
  // sleep.sleep(20);
  const securityGroup = data.securityGroup;
  console.log(`Deleting security group ${securityGroup} ...`);
  return new Promise((resolve, reject) => {
    const params = {
      DryRun: false,
      GroupId: securityGroup
    };
    ec2.deleteSecurityGroup(params, (err, result) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(result);
        resolve(data.instance);
      }
    });
  });
};

const deleteSecurityGroup = (instance) => {
  return getExistingRules(instance)
  .then(removeExistingRules);
  // .then(doDeleteSecurityGroup);
};

const terminateRdsInstance = (instance) => {
  return getInstance(instance)
  .then(deleteSecurityGroup)
  .then(deleteInstance);
};

exports.handle = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));
  terminateRdsInstance(event.rds_instance || process.env.RDS_INSTANCE)
  .then(() => saveAndTerminateBeanstalkEnvironment(event.application || process.env.APPLICATION, event.environment || process.env.ENVIRONMENT))
  .catch((err) => {
    console.log(err);
  });
};
