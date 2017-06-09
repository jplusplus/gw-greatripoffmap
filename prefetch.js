var  fs = require("fs"),
      _ = require("underscore"),
// This will load the current .env file
    env = require('node-env-file'),
  async = require("async"),
  chalk = require('chalk'),
// Settings "jar" to true cause consistancy
request = require("request").defaults({jar: true});

/**
 * Get the resource for the given URI
 * @param  {String}   uri      Resource's uri
 * @param  {Function} callback Callback function
 */
function getResource(uri, callback) {
  request(API + uri, function(error, response, body) {
    try {
      // Something goes wrong
      if(error) return callback(error, null);
      // Parse request's body normally
      else return callback(null, JSON.parse(body) );
    // Catch parsing error
    } catch (e) {
      callback("Unable to parse " + uri)
    }
  });
}

var envpath = __dirname + '/.env';
// Load local environement file
if( fs.existsSync(envpath) ) env(envpath);

// Parse command line arguments
var argv = require("nomnom").parse();

// No output file given
if(!argv.output) {
  console.error("Please set an output file.");
  console.error("Usage: node prefetech.js --output file.json");
  process.exit(1);
}

// Configuration
var API = 'https://www.detective.io',
   TYPE = argv.type || 'company',
   LIST = API + '/api/global-witness/anon-shell-companies/v1/' + TYPE + '/?limit=200',
  LOGIN = API + "/api/detective/common/v1/user/login/",
COOKIES = null,
  AUTHS = { 'username': process.env.DIO_USER, 'password': process.env.DIO_PASS};

// Output what we are about to prefetch
console.log( chalk.bold.white("\nPrefetching '" + TYPE + "' from " + API) )

// Use stdout to avoid new line
process.stdout.write( chalk.grey(">> ") + " Authenticating '" + AUTHS.username + "'")
// Firstly, we need to authenticate the request
request.post({url: LOGIN, json: AUTHS}, function (error, response, body) {

  if(process.stdout.clearLine != null) {
    process.stdout.clearLine();
    process.stdout.cursorTo(0);
  }

  if(response.statusCode != 200 || !body.success) {
    process.stdout.write( chalk.red(">> ") + "Authentication failed\n" )
    process.exit(1);
  } else {
    process.stdout.write( chalk.green(">> ") + "Authenticating '" + AUTHS.username + "'\n" )
  }

  process.stdout.write( chalk.gray(">> ") + "Loading entities list")
  // Then we load the list of element
  request({ url: LIST }, function (error, response, body) {

    if(process.stdout.clearLine != null) {
      process.stdout.clearLine();
      process.stdout.cursorTo(0);
    }
    // Everything is OK, we start to load every resource one by one
    if (!error && response.statusCode == 200) {
      process.stdout.write( chalk.green(">> ") + "Loading entities list\n" )
      // Parse JSON body
      var data =  JSON.parse(body),
          uris = _.pluck(data.objects, "resource_uri");

      process.stdout.write( chalk.grey(">> ") + "Loading entities detail" )
      // Get all dataset one by one
      async.map(uris, getResource, function(error, datasets) {

        if(process.stdout.clearLine != null) {
          process.stdout.clearLine();
          process.stdout.cursorTo(0);
        }

        // Output error
        if(error) {
          process.stdout.write( chalk.red(">> ") + error )
        // Generate the data file
        } else {
          process.stdout.write( chalk.green(">> ") + "Loading entities detail\n" )
          fs.writeFile(argv.output, JSON.stringify(datasets) );
          process.stdout.write( chalk.green(">> ") + "Writing data to " + argv.output + "\n\n"  )
        }
      });
    }
  });

});
