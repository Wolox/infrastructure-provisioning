var AWS = require('aws-sdk');

exports.handler = function(event, context) {
    var AWS = require('aws-sdk');
    var simpledb = new AWS.SimpleDB({
      endpoint: 'sdb.amazonaws.com',
      region: 'us-east-1'
    });
    console.log(event)
    var params = {
      SelectExpression: 'SELECT * FROM subscriptions', /* required */
    };

    simpledb.select(params, function(err, data) {
        if (err) {
          console.log(err);
          context.fail("Internal Error: " + JSON.stringify(err));
        } else {
            console.log(data);
            context.succeed(data.Items);
        }
    });
}
