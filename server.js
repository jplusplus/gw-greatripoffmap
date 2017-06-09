var express = require('express');
var compression = require('compression')
var app = express();
// Activate prerender middleware to cache `_escaped_fragment_` parameter
app.use(require('prerender-node').set('prerenderToken', process.env.PRERENDER_TOKEN));
// Activate compression
app.use(compression());
// Exclude node_module from public directories
app.use("/node_modules/*", function(req, res) { res.send(403); });
// Add the current directory to the public file
app.use(express.static(__dirname));
// Add prerender middleware
// Listen on default port
var port = process.env.PORT || 3000;
app.listen(port);
