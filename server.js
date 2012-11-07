/*
Environmental variables
 - PORT
 - COOKIE_SECRET
 - REDISTOGO_URL
*/

require("coffee-script");
app = require("./controllers/host.coffee");
http = require("http");
port = process.env.PORT || 1000;

http.createServer(app).listen(port, function () {
   console.log("Snapture Web listening on " + port);
});