var Riak = require("basho-riak-client");

//Connecting to Riak
var client = new Riak.Client(["192.168.1.4:8087"], function (err, c) {
  if (err) {
    throw new Error(err);
  } else {
    console.log("Connect successfully");
  }
});

//list user
var users = [
  {
    userid: "18521464",
    username: "18521464@gm.uit.edu.vn",
    name: "Trần Anh Thư",
    bio: "Đang học tại THPT Tây Sơn",
    birthday: "2000-09-12",
    sex: "female",
    location: "Vietnam",
  },
  {
    userid: "18521414",
    username: "18521414@gm.uit.edu.vn",
    name: "Trần Quốc Thành",
    bio: "Đang học tại UIT",
    birthday: "2000-06-13",
    sex: "male",
    location: "Vietnam",
  },
  {
    userid: "18520630",
    username: "18520630@gm.uit.edu.vn",
    name: "Hồ Anh Dũng",
    bio: "Đang học tại UIT",
    birthday: "2000-05-20",
    sex: "male",
    location: "Vietnam",
  },
];

var async = require("async");
var logger = require("winston");
//Function store Object in Riak KV
function storeUser(user) {
  logger.info("Storing user %s", user.userid);
  client.storeValue(
    {
      bucket: "users",
      key: user.userid,
      value: user,
    },
    function (err, rslt) {
      if (err) {
        throw new Error(err);
      }
    }
  );
}

//Store users
var storeFuncs = [];
users.forEach(function (user) {
    storeFuncs.push(function (async_cb) {
        storeUser(user)
    });
});
async.parallel(storeFuncs, function (err, rslts) {
    if (err) {
        throw new Error(err);
    }
});



//Reading from Riak
function fetchUser(key) {
  var riakObj, KH26;
  client.fetchValue(
    { bucket: 'users', key: key, convertToJs: true },
    function (err, rslt) {
      if (err) {
        throw new Error(err);
      } else {
        riakObj = rslt.values.shift();
        if (!riakObj) {
          logger.info("Can NOT found user %s", key);
        } else {
          value = riakObj.value;
          console.log(value);
        }
      }
    }
  );
}
//Read user "18521288"
fetchUser("18521288");

//Function Delete User
function deleteUser(key) {
  client.deleteValue(
    {
      bucket: 'users',
      key: key,
    },
    function (err, rslt) {
      if (err) {
        throw new Error(err);
      }
    }
  );
}
//Delete user "18521288"
deleteUser("18521288");
//Read user "18521288"
fetchUser("18521288");
