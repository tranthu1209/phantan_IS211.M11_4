//Connecting to Riak
var async = require("async");
var logger = require('winston');
var Riak = require("basho-riak-client");
var node = ["192.168.1.8:8087"];

var client = new Riak.Client(node, function (err, c) {
  if (err) {
    throw new Error(err);
  } else {
    console.log("Connect successfully");
  }
});

//Reading from Riak
function fetchObject(bucket, key) {
  var riakObj, KH26;
  client.fetchValue({ bucket: bucket, key: key, convertToJs: true },
    function (err, rslt) {
      if (err) {
        throw new Error(err);
      } else {
        riakObj = rslt.values.shift();
        if (!riakObj) {
          logger.info("Can NOT found %s in %s", key, bucket);
        } else {
          value = riakObj.value
          console.log(value);
        }
      }
    }
  );
}
//Read user 3
fetchObject('users', '3');

//Creating Objects In Riak KV
//user
var user = {
    userid: "4",
    username: "tranquan@gmail.com",
    name: "Trần Quân",
    bio: "Cố lên",
    birthday: "2000-10-20",
    sex: "male",
    location: "Vietnam",
  }

//Store user
function store_user(user) {
  logger.info("Storing Data");
  client.storeValue(
    {
      bucket: 'users',
      key: user.userid,
      value: user
    },
    function (err, rslt) {
      if (err) {
          throw new Error(err);
      }
    }
  );
}
store_user(user);


//Modifying Existing Data
function updateBio(bucket, key, newBio) {
  var riakObj, KH26;
  client.fetchValue({ bucket: bucket, key: key, convertToJs: true },
    function (err, rslt) {
      if (err) {
        throw new Error(err);
      } else {
        riakObj = rslt.values.shift();
        if (!riakObj) {
          logger.info("Can NOT found %s in %s", key, bucket);
        } else {
          value = riakObj.value
          value.bio = newBio;
          riakObj.setValue(value);
          store_user(riakObj);
        }
      }
    }
  );
}
//update bio user 3
updateBio('users', '3', 'Yêu màu hông, ghét sự giả dối');
//read user 3
fetchObject('users', '3');


//Deleting Data
function delete_user(bucket, key) {
  client.deleteValue(
    {
      bucket: bucket,
      key: key,
    },
    function (err, rslt) {
      if (err) {
          throw new Error(err);
      }
    }
  );
}
//Delete user 3
delete_user('users', '3');
//Read user 3
fetchObject('users', '3');

