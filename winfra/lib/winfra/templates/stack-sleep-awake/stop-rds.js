const AWS = require('aws-sdk');
const rds = new AWS.RDS({ region: 'us-east-1', apiVersion: '2014-10-31' });

exports.handle = (event, context, callback) => {
  console.log(`Got event ${JSON.stringify(event)}`);
  return new Promise((resolve, reject) => {
    const dbInstanceIndentifier = event.db_instance_identifier || process.env.DB_INSTANCE_IDENTIFIER;

    console.log(`Stopping ${dbInstanceIndentifier}`);

    const params = {
      DBInstanceIdentifier: dbInstanceIndentifier
    };

    rds.stopDBInstance(params, (err, data) => {
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
