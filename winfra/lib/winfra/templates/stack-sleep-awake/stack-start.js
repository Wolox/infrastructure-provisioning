const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({ region: 'us-east-1' });

const executeLambaFunction = (config) => {
  console.log(`Executing lambda function with args: ${JSON.stringify(config)}`);
  return new Promise((resolve, reject) => {
    const params = {
      FunctionName: config.function_name,
      InvocationType: 'Event',
      Payload: JSON.stringify(config)
    };

    lambda.invoke(params, (err, data) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(data);
        resolve(config);
      }
    });
  });
};

const startBeastalk = (config) => {
  config.function_name = 'stack-awake-sleep_start-beanstalk';
  return executeLambaFunction(config);
};

const startRds = (config) => {
  config.function_name = 'stack-awake-sleep_start-rds';
  return executeLambaFunction(config);
};

exports.handle = (event, context, callback) => {
  console.log(`Got event: ${JSON.stringify(event)}`);
  const environment_name = event.environment_name || process.env.ENVIRONMENT_NAME;
  const db_instance_identifier = event.db_instance_identifier || process.env.DB_INSTANCE_IDENTIFIER;
  const params = { environment_name, db_instance_identifier };

  return startBeastalk(params).then(startRds);
};
