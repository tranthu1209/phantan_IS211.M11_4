//Connecting to Riak
var async = require("async");
var logger = require('winston');
var Riak = require("basho-riak-client");
var node = ["192.168.1.5:8087"];

var client = new Riak.Client(node, function (err, c) {
  if (err) {
    throw new Error(err);
  } else {
    console.log("Connect successfully");
  }
});

//list user
var users = [
  {
    userid: "1",
    username: "tranthu@gmail.com",
    name: "Trần Thư",
    bio: "Cố lên",
    birthday: "2000-10-20",
    sex: "female",
    location: "Vietnam",

  },
  {
    userid: "2",
    username: "tranthanh@gmail.com",
    name: "Trần Thành",
    bio: "Cố lên",
    birthday: "2000-06-13",
    sex: "male",
    location: "Vietnam",

  },
  {
    userid: "3",
    username: "hodung@gmail.com",
    name: "Hồ Dũng",
    bio: "Cố lên",
    birthday: "2000-05-20",
    sex: "male",
    location: "Vietnam",

  },
];


//Creating Objects In Riak KV
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


//Store list user
function storeProfile(profiles) {
  var storeProfileFuncs = [];
  users.forEach(function (p) {
    storeProfileFuncs.push(function (async_cb) {
      store_user(p);
    });
  });
  async.parallel(storeUserFuncs, function (err, rslts) {
    if (err) {
      throw new Error(err);
    }
  });
}

storeProfile(users);


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
//Read user 4
fetchObject('users', '4');

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
//Delete user 4
delete_user('users', '4');
//Read user 4
fetchObject('users', '4');


