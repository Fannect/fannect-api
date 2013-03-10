/*
Environmental variables
 - PORT
 - MONGO_URL
 - REDIS_URL
*/
if (process.env.NODE_ENV == "production") {
   require("nodefly").profile(
      "8bdbbd3e-684d-4668-aaea-77f52ac9319a",
      ["Fannect API","Heroku"]
   );
}

require("coffee-script");
app = require("./controllers/host.coffee");
http = require("http");
port = process.env.PORT || 2100;

http.createServer(app).listen(port, function () {
   console.log("Fannect Core API listening on " + port);
});