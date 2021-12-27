var Riak = require("basho-riak-client");

//Connecting to Riak
var client = new Riak.Client(["192.168.1.8:8087"], function (err, c) {
  if (err) {
    throw new Error(err);
  } else {
    console.log("Connect successfully");
  }
});

var logger = require("winston");
//Function store user
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
//Create user "18521288"
var user = {
  userid: "18521288",
  username: "18521288@gm.uit.edu.vn",
  name: "Trần Minh Quân",
  bio: "Đang học tại UIT",
  birthday: "2000-05-10",
  sex: "male",
  location: "Vietnam",
};
storeUser(user);


//Function read from Riak
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
//Read user "18521464"
fetchUser("18521464");



//Modifying Existing Data
function updateBio(key, newBio) {
  var riakObj;
  client.fetchValue(
    { bucket: 'users', key: key, convertToJs: true },
    function (err, rslt) {
      if (err) {
        throw new Error(err);
      } else {
        riakObj = rslt.values.shift();
        if (!riakObj) {
          logger.info("Can NOT found %s", key);
        } else {
          value = riakObj.value;
          value.bio = newBio;
          riakObj.setValue(value);
          client.storeValue({ value: riakObj }, function (err, rslt) {
            if (err) {
              throw new Error(err);
            }
          });
          logger.info("Update bio user %s", key);
        }
      }
    }
  );
}
//update bio user "18521464"
updateBio("18521464", "Đang học tại UIT");
//read user 3
fetchUser("18521464");


