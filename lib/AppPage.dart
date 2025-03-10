import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class AppPage extends StatefulWidget {
  final BluetoothDevice server;

  const AppPage({required this.server});

  @override
  _AppPage createState() => new _AppPage();
}


class _AppPage extends State<AppPage> {
  BluetoothConnection? connection;

  String _messageBuffer = '';
  String message = "";
  // new message variables
  String sentMessage = '';
  String receivedMessage = '';

  bool isConnecting = true;
  bool get isConnected => connection != null && connection!.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input?.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rapsberry Pi Bluetooth Chat"),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Text Box to type a message and send
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (String value) {
                  message = value;
                },
                decoration: InputDecoration(
                  labelText: 'Send a message',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: isConnected ? () => _sendMessage(message) : null,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Sent message
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    // align right with left padding
                    padding: EdgeInsets.only(left: 70.0), 
                    child: Container(
                      padding: EdgeInsets.all(8.0), 
                      decoration: BoxDecoration(
                        color: Colors.blue, 
                        borderRadius: BorderRadius.circular(10.0), 
                      ),
                      // display sent message
                      child: Text(
                        '$sentMessage',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    // align left with right padding
                    padding: EdgeInsets.only(right: 70.0),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10.0), 
                      ),
                      // display received message
                      child: Text(
                        '$receivedMessage',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // void _onDataReceived(Uint8List data) {
  //   print('Raw data: $data');

  //   // Allocate buffer for parsed data
  //   int backspacesCounter = 0;
  //   data.forEach((byte) {
  //     if (byte == 8 || byte == 127) {
  //       backspacesCounter++;
  //     }
  //   });
  //   Uint8List buffer = Uint8List(data.length - backspacesCounter);
  //   int bufferIndex = buffer.length;

  //   // Apply backspace control character
  //   backspacesCounter = 0;
  //   for (int i = data.length - 1; i >= 0; i--) {
  //     if (data[i] == 8 || data[i] == 127) {
  //       backspacesCounter++;
  //     } else {
  //       if (backspacesCounter > 0) {
  //         backspacesCounter--;
  //       } else {
  //         buffer[--bufferIndex] = data[i];
  //       }
  //     }
  //   }

  //   // Create message if there is new line character
  //   String dataString = String.fromCharCodes(buffer);
  //   print('Decoded string: $dataString');
  //   int index = buffer.indexOf(13);
  //   if (~index != 0) {
  //     setState(() {
  //       receivedMessage = dataString;
  //       message = backspacesCounter > 0
  //               ? _messageBuffer.substring(
  //                   0, _messageBuffer.length - backspacesCounter)
  //               : _messageBuffer + dataString.substring(0, index);
        
  //       _messageBuffer = dataString.substring(index);
  //     });
  //   } else {
  //     _messageBuffer = (backspacesCounter > 0
  //         ? _messageBuffer.substring(
  //             0, _messageBuffer.length - backspacesCounter)
  //         : _messageBuffer + dataString);
  //   }
  // }

  void _onDataReceived(Uint8List data) {
    print('Raw data: $data');

    // byte array to string
    String dataString = String.fromCharCodes(data);
    print('Decoded string: $dataString');

    setState(() {
      receivedMessage = dataString; 
    });
  }


  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text)));
        await connection!.output.allSent;
         setState(() {
          sentMessage = text;
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
