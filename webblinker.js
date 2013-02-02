var app = require('http').createServer(handler)
	, io = require('socket.io').listen(app)
	, fs = require('fs')
	, url = require('url')

app.listen(8131);

function handler (req, res) {
	var pathname = url.parse(req.url).pathname;
	console.log("Client request: " + pathname);

	fs.readFile(__dirname + pathname, function (err, data) {
		if (err) {
			res.writeHead(500);
			return res.end('Error loading ' + pathname);
		}

		res.writeHead(200);
		res.end(data);
	});
}

var clientcounter = 1;

var led = new Array();
for (var z=0; z<16; z++) {
	led[z] = false;
}

var iocmdpipe = fs.createWriteStream("/webblinker/cmdpipe");

io.sockets.on('connection', function (socket) {
	console.log("[1;34mNew operative, sending our greetings[0m");
	socket.emit('greetings', { number: clientcounter++ });
	socket.on('confirmation', function (data) {
		console.log("[1;33mReceived data: " + data + "[0m");
	});
	socket.emit('currentstate', led );

	socket.on('turnon', function (data) {
		if (data == "*") {
			for (var z=0; z<16; z++) { led[z] = true; }
		}
		else if (data >= 0) {
			led[data] = true;
		}
		console.log("[1;33mUpdate from client: turn on " + data + "[0m");
		socket.broadcast.emit('ledupdate', { num: data, state: true });
		iocmdpipe.write(data + ",1\n");
		console.log("[1;34mDispatched ON update to clients for led " + data + "[0m");
	});

	socket.on('turnoff', function (data) {
		if (data == "*") {
			for (var z=0; z<16; z++) { led[z] = false; }
		}
		else if (data >= 0) {
			led[data] = false;
		}
		console.log("[1;33mUpdate from client: turn off " + data + "[0m");
		socket.broadcast.emit('ledupdate', { num: data, state: false });
		iocmdpipe.write(data + ",0\n");
		console.log("[1;34mDispatched OFF update to clients for led " + data + "[0m");
	});


});

