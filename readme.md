# Heroku Buildpack: NGINX

Nginx-buildpack vendors NGINX inside a dyno and connects NGINX to an app server via UNIX domain sockets.

## Motivation

Some application servers (e.g. Ruby's Unicorn) halt progress when dealing with network I/O. Heroku's Cedar routing stack [buffers only the headers](https://devcenter.heroku.com/articles/http-routing#request-buffering) of inbound requests. (The Cedar router will buffer the headers and body of a response up to 1MB) Thus, the Heroku router engages the dyno during the entire body transfer –from the client to dyno. For applications servers with blocking I/O, the latency per request will be degraded by the content transfer. By using NGINX in front of the application server, we can eliminate a great deal of transfer time from the application server. In addition to making request body transfers more efficient, all other I/O should be improved since the application server need only communicate with a UNIX socket on localhost. Basically, for webservers that are not designed for efficient, non-blocking I/O, we will benefit from having NGINX to handle all I/O operations.

## Versions

* NGINX Version: 1.5.11
* PCRS 8.34
* headers-more Module 0.25

## Requirements

* Your webserver listens to the socket at `/tmp/nginx.socket`.
* You touch `/tmp/app-initialized` when you are ready for traffic.
* You can start your web server with a shell command.

## Features

* Unified NXNG/App Server logs.
* [L2met](https://github.com/ryandotsmith/l2met) friendly NGINX log format.
* [Heroku request ids](https://devcenter.heroku.com/articles/http-request-id) embedded in NGINX logs.
* Crashes dyno if NGINX or App server crashes. Safety first.
* Language/App Server agnostic.
* Customizable NGINX config.
* Application coordinated dyno starts.

### Logging

NGINX will output the following style of logs:

```
measure.nginx.service=0.007 request_id=e2c79e86b3260b9c703756ec93f8a66d
```

You can correlate this id with your Heroku router logs:

```
at=info method=GET path=/ host=salty-earth-7125.herokuapp.com request_id=e2c79e86b3260b9c703756ec93f8a66d fwd="67.180.77.184" dyno=web.1 connect=1ms service=8ms status=200 bytes=21
```

### Language/App Server Agnostic

Nginx-buildpack provides a command named `bin/start-nginx` this command takes another command as an argument. You must pass your app server's startup command to `start-nginx`.

For example, to get NGINX and Node up and running:

```bash
$ cat Procfile
web: bin/start-nginx node web.js
```

### Building
```bash
heroku run bash

git config --global user.email = "Donald Armstrong"
git config --global user.name = "Donald Armstrong"

git clone https://github.com/TGTLabs/nginx-buildpack.git

cd scripts
sh build_nginx.sh
```

Copy the binary to bin/nginx
commit back to github

### Setting the Worker Processes

You can configure NGINX's `worker_processes` directive via the
`NGINX_WORKERS` environment variable.

For example, to set your `NGINX_WORKERS` to 8 on a PX dyno:

```bash
$ heroku config:set NGINX_WORKERS=8
```

### Customizable NGINX Config

You can provide your own NGINX config by creating a file named `nginx.conf.erb` in the config directory of your app. Start by copying the buildpack's [default config file](config/nginx.conf.erb).

### Customizable NGINX Compile Options

See [buidling-nginx](https://targetrad.squarespace.com/rad-internal-bla-bla-blog/2014/3/10/building-nginx) on the TargetRad blog on how to build an NGINX binary.

### Application/Dyno coordination

The buildpack will not start NGINX until a file has been written to `/tmp/app-initialized`. Since NGINX binds to the dyno's $PORT and since the $PORT determines if the app can receive traffic, you can delay NGINX accepting traffic until your application is ready to handle it.

## Setup

Update Buildpacks
```bash
$ heroku config:set BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git
$ echo 'https://github.com/TargetRAD/nginx-buildpack.git' >> .buildpacks
$ echo 'https://github.com/heroku/heroku-buildpack-nodejs.git' >> .buildpacks
$ git add .buildpacks
$ git commit -m 'Add multi-buildpack'
```
Update Procfile:
```
web: bin/start-nginx node web.js
```
```bash
$ git add Procfile
$ git commit -m 'Update procfile for NGINX buildpack'
```
Update node launch script (ie. web.js)
```javascript
var fs = require('fs');
// write nginx tmp
fs.writeFile("/tmp/app-initialized", "Ready to launch nginx", function(err) {
    if(err) {
        console.log(err);
    } else {
        console.log("The file was saved!");
    }
});

// listen on the nginx socket
app.listen('/tmp/nginx.socket', function() {
	console.log("Listening ");
});
```
```bash
$ git add web.js
$ git commit -m 'Update web.js to listen on NGINX socket.'
```
Deploy Changes
```bash
$ git push heroku master
```

Visit App
```
$ heroku open
```

## License
Copyright (c) 2013 Ryan R. Smith
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
