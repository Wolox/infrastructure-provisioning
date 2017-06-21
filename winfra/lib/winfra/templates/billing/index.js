const ElasticsearchCSV = require('./elasticsearch_csv');
const elasticsearch = require('elasticsearch');
const zlib = require('zlib');
const fs = require('fs');
const AWS = require('aws-sdk');
const s3 = new AWS.S3({ region: 'us-east-1' });
const stream = require('stream');
const request = require('request-promise-native');

const deletePreviousData = (data) => {
  console.log('Deleting previous data');
  const options = {
    method: 'POST',
    uri: `${process.env.ELASTICSEARCH_URL}/aws-billing/_delete_by_query`,
    json: true,
    body: {
      query: {
        bool: {
          must: [
            {
              match: {
                _type: data.bucket.split('-')[0]
              }
            }
          ]
        }
      }
    }
  };

  return request.post(options).then((response) => {
    return data;
  });
};

const getFileFroms3 = (bucket, key) => {
  return new Promise((resolve, reject) => {
    const params = {
      Bucket: bucket,
      Key: key
    };
    console.log(`Getting ${JSON.stringify(params)}`);
    s3.getObject(params, (err, data) => {
      if (err) {
        console.log(JSON.stringify(err));
        reject(err);
      } else {
        resolve({ bucket, key, data });
      }
    });
  });
};

const processAndUpload = (data) => {
  const unzip = zlib.createGunzip();
  const readableStream = new stream.PassThrough();
  readableStream.end(data.data.Body);

  const options = {
    hosts: [process.env.ELASTICSEARCH_URL],
    index: 'aws-billing',
    type: data.bucket.split('-')[0],
    requestTimeout: 300000
  };

  // create an instance of the importer with options
  const esCSV = new ElasticsearchCSV({
    inputStream: readableStream.pipe(unzip),
    es: options,
    csv: { headers: true }
  });

  return esCSV.import()
  .then(function (response) {
    // Elasticsearch response for the bulk insert
    console.log('Inserted!');
  }, function (err) {
      // throw error
    throw err;
  });
};

exports.handler = (event, context, callback) => {
  console.log(JSON.stringify(event));

  const key = event.Records[0].s3.object.key;
  const bucket = event.Records[0].s3.bucket.name;

  return getFileFroms3(bucket, key).then(deletePreviousData).then(processAndUpload)
  .catch((err) => {
    console.log(JSON.stringify(err));
  });
};
