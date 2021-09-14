"use strict";
const AWS = require("aws-sdk");
const crypto = require("crypto");
const config = require("./config.json");
const dynamodb = new AWS.DynamoDB();

//Function implementation
function getPolicy() {
  return (
    `{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "AllowListingOfUserFolder",
          "Action": [
              "s3:ListBucket"
          ],
          "Effect": "Allow",
          "Resource": [` +
    '"arn:aws:s3:::${transfer:HomeBucket}"' +
    `],
          "Condition": {
              "StringLike": {
                  "s3:prefix": [` +
    '"${transfer:UserName}/*",' +
    '"${transfer:UserName}"' +
    `]
              }
          }
      },
      {
          "Sid": "AWSTransferRequirements",
          "Effect": "Allow",
          "Action": [
              "s3:ListAllMyBuckets",
              "s3:GetBucketLocation"
          ],
          "Resource": "*"
      },
      {
          "Sid": "HomeDirObjectAccess",
          "Effect": "Allow",
          "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObjectVersion",
              "s3:DeleteObject",
              "s3:GetObjectVersion"
          ],` +
    '"Resource": "arn:aws:s3:::${transfer:HomeDirectory}*"' +
    `}
  ]
}`
  );
}

function computeHash(password, salt, fn) {
  var len = config.CRYPTO_BYTE_SIZE;
  var iterations = config.ITERATION;
  var hash = config.HASH;
  if (3 == arguments.length) {
    crypto.pbkdf2(
      password,
      salt,
      iterations,
      len,
      hash,
      function (err, derivedKey) {
        if (err) return fn(err);
        else fn(null, salt, derivedKey.toString("base64"));
      }
    );
  } else {
    fn = salt;
    crypto.randomBytes(len, function (err, salt) {
      if (err) return fn(err);
      salt = salt.toString("base64");
      computeHash(password, salt, fn);
    });
  }
}

function getUser(username, fn) {
  dynamodb.getItem(
    {
      TableName: process.env.DYNAMO_TABLE,
      Key: {
        username: {
          S: username,
        },
      },
    },
    function (err, data) {
      if (err) return fn(err);
      else {
        if ("Item" in data) {
          var hash = data.Item.password.S;
          var salt = data.Item.passwordSalt.S;
          var publickey = data.Item.publickey.S;
          fn(null, hash, salt, publickey);
        } else {
          fn(null, null); // User not found
        }
      }
    }
  );
}

// Main Function Start here

exports.handler = (event, context, callback) => {
  console.log("Event:", JSON.stringify(event));
  var response;
  var clearPassword = event.password;
  var username = event.username;

  if (event.serverId == process.env.SERVER_ID) {
    getUser(username, function (err, correctHash, salt, publickey) {
      if (err) {
        context.fail("Error in getUser: " + err);
      } else {
        if (correctHash == null) {
          console.log("User not found: " + username);
        } else if (clearPassword !== "") {
          computeHash(clearPassword, salt, function (err, salt, hash) {
            if (err) {
              context.fail("Error in hash: " + err);
            } else {
              if (hash == correctHash) {
                console.log("User new auth with password");
                response = {
                  Role: process.env.ROLE_ARN,
                  Policy: getPolicy(),
                  HomeDirectory: `/${process.env.BUCKET_ARN.substring(
                    "arn:aws:s3:::".length
                  )}/${event.username}`,
                  HomeBucket: process.env.BUCKET_ARN.substring(
                    "arn:aws:s3:::".length
                  ),
                };
                callback(null, response);
              } else {
                console.log("Incorrect credentials");
              }
            }
          });
        } else if (publickey != undefined || publickey != "") {
          console.log("User new auth with key");
          response = {
            Role: process.env.ROLE_ARN,
            Policy: getPolicy(),
            HomeDirectory: `/${process.env.BUCKET_ARN.substring(
              "arn:aws:s3:::".length
            )}/${event.username}`,
            HomeBucket: process.env.BUCKET_ARN.substring(
              "arn:aws:s3:::".length
            ),
            PublicKeys: [publickey],
          };
          console.log(response);
          callback(null, response);
        } else {
          console.log(response);
          response = {};
        }
      }
    });
  } else {
    console.log(response);
    response = {};
  }
};
