const AWS = require('aws-sdk');
const rds = new AWS.RDS({ region: 'us-east-1', apiVersion: '2014-10-31' });

exports.handle = (event, context, callback) => {
  return new Promise((resolve, reject) => {
    const dbInstanceIndentifier = event.db_instance_identifier || process.env.DB_INSTANCE_IDENTIFIER;

    console.log(`Starting ${dbInstanceIndentifier}`);

    const params = {
      DBInstanceIdentifier: dbInstanceIndentifier
    };

    rds.startDBInstance(params, (err, data) => {
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
