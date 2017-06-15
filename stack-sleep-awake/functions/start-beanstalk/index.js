const AWS = require('aws-sdk');
const elasticbeanstalk = new AWS.ElasticBeanstalk({ region: 'us-east-1' });
const autoscaling = new AWS.AutoScaling({ region: 'us-east-1' });

const getAutoscalingGroupName = (environmentName) => {
  console.log('Getting autoscaling group name');
  return new Promise((resolve, reject) => {
    const params = {
      EnvironmentName: environmentName
    };

    elasticbeanstalk.describeEnvironmentResources(params, (err, data) => {
      if (err) {
        return reject(err);
      }

      const autoScalingGroup = data.EnvironmentResources.AutoScalingGroups[0];

      console.log(JSON.stringify(data.EnvironmentResources));

      console.log(`Autoscaling group name: ${autoScalingGroup.Name}`);

      resolve(autoScalingGroup.Name);

    });
  });
};

const setAutoScalingSize = (autoScalingGroupName) => {
  console.log('Modifying autoscaling group size');
  return new Promise((resolve, reject) => {
    const params = {
      AutoScalingGroupName: autoScalingGroupName,
      MaxSize: 1,
      MinSize: 1
    };

    autoscaling.updateAutoScalingGroup(params, (err, data) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(JSON.stringify(data));
        resolve(data);
      }
    });
  });
};

exports.handle = (event, context, callback) => {
  const envName = event.environment_name || process.env.ENVIRONMENT_NAME;

  return getAutoscalingGroupName(envName).then(setAutoScalingSize);
};
