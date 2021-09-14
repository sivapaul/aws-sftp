const AWS = require("aws-sdk");
const crypto = require("crypto");
const config = require("./config.json");
const dynamodb = new AWS.DynamoDB({
  region: "eu-west-1",
  apiVersion: "2012-08-10",
});

function computeHash(password, salt, fn) {
  var len = config.CRYPTO_BYTE_SIZE;
  var iterations = config.ITERATION;
  var hash = config.HASH;
  if (3 == arguments.length) {
    crypto.pbkdf2(password, salt, iterations, len, hash, function (
      err,
      derivedKey
    ) {
      if (err) return fn(err);
      else fn(null, salt, derivedKey.toString("base64"));
    });
  } else {
    fn = salt;
    crypto.randomBytes(len, function (err, salt) {
      if (err) return fn(err);
      salt = salt.toString("base64");
      computeHash(password, salt, fn);
    });
  }
}

exports.handler = (event, context, callback) => {
  var clearPassword = event.password;
  var datetime = new Date().getTime().toString();
  computeHash(clearPassword, function (err, salt, hash) {
    if (err) {
      context.fail("Error in hash: " + err);
    } else {
      const params = {
        TableName: process.env.DYNAMO_TABLE,
        Item: {
          username: {
            S: event.username,
          },
          password: {
            S: hash,
          },
          passwordSalt: {
            S: salt,
          },
          publickey: {
            S: event.publickey,
          },
          accountseq: {
            S: event.accountseq,
          },
          date: {
            S: datetime,
          },
          migrated: {
            S: 'Y',
          },
        },
      };
      dynamodb.putItem(params, function (err, data) {
        if (err) {
          console.log(err);
          callback(err);
        } else {
          console.log(data);
          callback(null, data);
        }
      });
    }
  });
};
