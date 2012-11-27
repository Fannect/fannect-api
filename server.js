/*
Environmental variables
 - PORT
 - COOKIE_SECRET
 - REDISTOGO_URL
*/

require("coffee-script");
app = require("./controllers/host.coffee");
http = require("http");
port = process.env.PORT || 2100;

http.createServer(app).listen(port, function () {
   console.log("Fannect Web App listening on " + port);
});