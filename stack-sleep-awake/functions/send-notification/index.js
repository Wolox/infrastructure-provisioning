console.log('starting function');

const AWS = require('aws-sdk');
const moment = require('moment');
const elasticbeanstalk = new AWS.ElasticBeanstalk();
const ec2 = new AWS.EC2();
const sns = new AWS.SNS();
const rds = new AWS.RDS();

const getInitialMessage = () => {
  const environment = process.env.ENVIRONMENT;
  const application = process.env.ENVIRONMENT;
  const rdsInstance = process.env.RDS_INSTANCE;
  const message = `This is to let you know that your beanstalk application ${application}-${environment}\
   and your RDS database ${rdsInstance} are being turned on`;
  const subject = 'Beanstalk and RDS being turned on';
  return { message, subject };
};

const getFinalMessage = () => {
  const environment = process.env.ENVIRONMENT;
  const application = process.env.ENVIRONMENT;
  const rdsInstance = process.env.RDS_INSTANCE;
  const message = `This is to let you know that your beanstalk application ${application}-${environment}\
   and your RDS database ${rdsInstance} are up and running`;
  const subject = 'Beanstalk and RDS have started';
  return { message, subject };
};

const publishToSNS = (message) => {
  return new Promise((resolve, reject) => {
    const params = {
      Message: message.message,
      TopicArn: process.env.TOPIC_ARN,
      Subject: message.subject
    };
    sns.publish(params, function (err, data) {
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
  let promise;

  if (Object.keys(e).length === 0) {
    promise = publishToSNS(getInitialMessage());
  } else {
    promise = publishToSNS(getFinalMessage());
  }
  promise
  .then(() => {
    cb(null, e);
  })
  .catch((error) => {
    cb(error);
  });
};
