import socket

HOST = "172.16.213.108" # Khushi's Raspberry PI
# HOST = "100.85.99.31" # Roy's Raspberry PI
PORT = 65432          # The port used by the server

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    while 1:
        text = input("Enter your message: ") # Note change to the old (Python 2) raw_input
        if text == "quit":
            break
        s.send(text.encode())     # send the encoded message (send in binary format)

        data = s.recv(1024)
        print("from server: ", data)
