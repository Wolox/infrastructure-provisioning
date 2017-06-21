const _ = require('lodash');
const fs = require('fs');
const path = require('path');
const elasticsearch = require('elasticsearch');
const csv = require('fast-csv');
const uuid = require('uuid');
const Promise = require('bluebird');

function elasticsearch_csv (options) {
  this.options = options || {};

  if (!this.options.es || !this.options.es.index) {
    throw new Error('index is invalid or missing');
  }
  if (!this.options.es || !this.options.es.type) {
    throw new Error('type is invalid or missing');
  }

  this.esClient = new elasticsearch.Client(_.omit(this.options.es, ['index', 'type']));

  return this;
}

elasticsearch_csv.prototype = {
  parse () {
    return new Promise(function (resolve, reject) {
      const request = {
          body: []
        },
        csvStream = csv(_.omit(this.options.csv, ['filePath']))
                    .on('data', function (data) {
                      if (_.isPlainObject(data)) {
                        const id = `${data['identity/LineItemId'] }_${ data['identity/TimeInterval']}`;
                        request.body.push({ index: { _index: this.options.es.index, _type: this.options.es.type, _id: id } });
                        _.forEach(data, function (value, key) {
                          try {
                            data[key] = JSON.parse(value);
                          } catch (ignore) {
                          }
                        });
                        request.body.push(data);
                      } else {
                        reject(new Error('Data and/or options have no headers specified'));
                      }
                    }.bind(this))
                    .on('end', function () {
                      resolve(request);
                    })
                    .on('data-invalid', reject);

      this.options.inputStream.pipe(csvStream);
    }.bind(this));
  },
  import () {
    return new Promise(function (resolve, reject) {
      this.parse().then(function (request) {
        console.log(request.body.length);
        this.esClient.bulk(request, function (err, res) {
          if (err) {
            console.log(err);
            reject(err);
          } else {
            resolve(res);
          }
        });
      }.bind(this), reject);
    }.bind(this));
  }
};

module.exports = elasticsearch_csv;
