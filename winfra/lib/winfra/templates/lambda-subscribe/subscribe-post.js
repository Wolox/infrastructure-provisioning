var AWS = require('aws-sdk')
var ses = new AWS.SES()

var RECEIVER = 'hello@wolox.co'
var SENDER = 'no-reply@wolox.com.ar'
var SDB_DOMAIN = 'subscriptions'
var REQUIRED_ATTRS = ['email', 'fullName', 'message']

function savesDataToDB (event, done) {
  var simpledb = new AWS.SimpleDB({
     endpoint: 'sdb.amazonaws.com',
     region: 'us-east-1'
   });
   var params = {
     Attributes: [ /* required */
       {
         Name: 'Timestamp', /* required */
         Value: (new Date()).toString(), /* required */
       },
       {
         Name: 'Email', /* required */
         Value: event.email, /* required */
       },
       {
         Name: 'FullName', /* required */
         Value: event.fullName, /* required */
       },
       {
         Name: 'Phone', /* required */
         Value: event.phone, /* required */
       },
       {
         Name: 'Message', /* required */
         Value: event.message, /* required */
       }
     ],
     DomainName: SDB_DOMAIN, /* required */
     ItemName: event.email, /* required */
   };
   simpledb.putAttributes(params, done);
}

function sendEmail (event, done) {
    var params = {
        Destination: {
            ToAddresses: [
                RECEIVER
            ]
        },
        Message: {
            Body: {
                Html: {
                    Data: '<strong>Someone contacted the Wolox Landing</strong><br><br>'+
                          '<strong>From:</strong> ' + event.fullName + '<br>' +
                          '<strong>Email:</strong> ' + event.email  + '<br>'+
                          '<strong>Phone:</strong> ' + event.phone + '<br>' +
                          '<strong>Message:</strong><br>' + event.message,
                    Charset: 'UTF-8'
                }
            },
            Subject: {
                Data: 'Wolox Landing Contact Form: ' + event.fullName,
                Charset: 'UTF-8'
            }
        },
        Source: SENDER
    }
    ses.sendEmail(params, done)
}

exports.handler = function (event, context) {
    console.log('Received event:', event)
    var presentRequiredAttrs = true;
    REQUIRED_ATTRS.forEach(function(attr) {
      if (presentRequiredAttrs && !event[attr]) {
        presentRequiredAttrs = false;
        console.log('Missing ' + attr)
        context.fail('Required parameters missing'); // Missing required parameters
      }
    });
    if (!presentRequiredAttrs) {
      return;
    }
    savesDataToDB(event, function (err, data) {
      if (err) {
        console.log(err);
        context.fail("Internal Error when saving to DB: " + JSON.stringify(err)); // an error occurred
      } else {
        context.done(err, { 'status': 'created' })
      }
    })
    // sendEmail(event, function (err, data) {
    //   if (err) {
    //     console.log(err);
    //     context.fail("Internal Error when sending email: " + JSON.stringify(err)); // an error occurred
    //   } else {
    //     context.done(err, null)
    //   }
    // })
}
