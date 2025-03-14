document.onkeydown = updateKey;
document.onkeyup = resetKey;

var server_port = 65432;
// var server_addr = "172.16.213.108"  // Khushi's Raspberry PI
var server_addr = "100.85.99.31" // Roy's Raspberry PI

function client(){
    
    const net = require('net');
    var input = document.getElementById("message").value;

    const client = net.createConnection({ port: server_port, host: server_addr }, () => {
        // 'connect' listener.
        console.log('connected to server!');
        // send the message
        client.write(`${input}\r\n`);
    });
    
    // get the data from the server
    client.on('data', (data) => {
        try {
            const parsedData = JSON.parse(data.toString());
            document.getElementById("temperature").innerHTML = parsedData.cpu_temp;
            document.getElementById("cpu_usage").innerHTML = parsedData.cpu_usage;
            document.getElementById("memory_usage").innerHTML = parsedData.memory_usage;
            document.getElementById("network_stats").innerHTML = parsedData.network_stats;
            console.log('Received data:', parsedData);
        } catch (error) {
            console.error('Error parsing data:', error);
            console.log('Raw data received:', data.toString());
        }
        client.end();
        client.destroy();
    });

    client.on('end', () => {
        console.log('disconnected from server');
    });


}

// for detecting which key is been pressed w,a,s,d
function updateKey(e) {
    e = e || window.event;

    const net = require('net');
    const client = net.createConnection({ port: server_port, host: server_addr }, () => {
        if (e.keyCode == '87') {
            // up (w)
            document.getElementById("upArrow").style.color = "green";
            client.write(`87\r\n`);
        }
        else if (e.keyCode == '83') {
            // down (s)
            document.getElementById("downArrow").style.color = "green";
            client.write(`83\r\n`);
        }
        else if (e.keyCode == '65') {
            // left (a)
            document.getElementById("leftArrow").style.color = "green";
            client.write(`65\r\n`);
        }
        else if (e.keyCode == '68') {
            // right (d)
            document.getElementById("rightArrow").style.color = "green";
            client.write(`68\r\n`);
        }
        client.end();
    });

    client.on('error', (err) => {
        console.log('Error:', err);
    });
}

// reset the key to the start state 
function resetKey(e) {

    e = e || window.event;

    document.getElementById("upArrow").style.color = "grey";
    document.getElementById("downArrow").style.color = "grey";
    document.getElementById("leftArrow").style.color = "grey";
    document.getElementById("rightArrow").style.color = "grey";
}


// update data for every 50ms
function update_data(){
    setInterval(function(){
        // get image from python server
        client();
    }, 50);
}
