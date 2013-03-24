if (process.env.NODE_ENV == "production") {
   require("nodefly").profile(
      "8bdbbd3e-684d-4668-aaea-77f52ac9319a",
      ["Fannect API","Heroku"]
   );
}

require("coffee-script");
app = require("./controllers/host.coffee");
redis = require("./common/utils/redis.coffee");
mongoose = require("mongoose");
http = require("http");
port = process.env.PORT || 2100;

server = http.createServer(app).listen(port, function () {
   console.log("Fannect Core API listening on " + port);
});

exit = function () {
  console.log("Closing Fannect Core API");
  redis.closeAll();
  mongoose.connection.close()
  server.close(function () {
      process.exit();
  });
}

process.on("SIGTERM", exit);
process.on("SIGINT", exit);