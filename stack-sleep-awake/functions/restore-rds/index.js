console.log('starting function');

const AWS = require('aws-sdk');
const moment = require('moment');
const elasticbeanstalk = new AWS.ElasticBeanstalk();
const ec2 = new AWS.EC2();
const rds = new AWS.RDS();

const compare = (a, b) => {
  const aTime = moment(a.SnapshotCreateTime);
  const bTime = moment(b.SnapshotCreateTime);
  console.log(aTime);
  console.log(bTime);
  // we want latest first
  return aTime.isBefore(bTime) ? 1 : aTime.isAfter(bTime) ? -1 : 0;
};

const getLastestSnapshot = (data) => {
  return new Promise((resolve, reject) => {
    const params = {
      DBInstanceIdentifier: data.rdsInstance,
      SnapshotType: 'manual'
    };
    rds.describeDBSnapshots(params, (err, snapshots) => {
      const snapshotList = snapshots.DBSnapshots;
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        const sorted = snapshotList.sort(compare);
        console.log(sorted[0]);
        data.latestSnapshot = sorted[0].DBSnapshotIdentifier;
        resolve(data);
      }
    });
  });
};

const restoreDbFromSnapshot = (data) => {
  console.log('restoreDbFromSnapshot');
  const snapshotIdentifier = data.latestSnapshot;
  return new Promise((resolve, reject) => {
    const params = {
      DBInstanceIdentifier: data.rdsInstance,
      DBSnapshotIdentifier: snapshotIdentifier

    };
    rds.restoreDBInstanceFromDBSnapshot(params, (err, result) => {
      if (err) {
        console.log(err, err.stack);
        reject(err);
      } else {
        console.log(result);
        resolve(data);
      }
    });
  });
};

exports.handle = function (e, ctx, cb) {
  console.log('processing event: %j', e);
  const data = { rdsInstance: process.env.RDS_INSTANCE };
  getLastestSnapshot(data)
  .then(restoreDbFromSnapshot)
  .then((result) => {
    cb(null, data.latestSnapshot);
  }).catch((error) => {
    cb(error);
  });
};
