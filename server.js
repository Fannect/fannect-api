/*
Environmental variables
 - PORT
 - MONGO_URL
 - REDIS_URL
*/
require("nodefly").profile(
   "8bdbbd3e-684d-4668-aaea-77f52ac9319a",
   ["Fannect API","Heroku"],
   options // optional
);

require("coffee-script");
app = require("./controllers/host.coffee");
http = require("http");
port = process.env.PORT || 2100;

http.createServer(app).listen(port, function () {
   console.log("Fannect Core API listening on " + port);
});