import socket

# HOST = "172.16.213.108" # Khushi's Raspberry PI
HOST = "100.85.99.31" # Roy's Raspberry PI

PORT = 65432          # Port to listen on (non-privileged ports are > 1023)

def callback(data):
    if data == '87':
        # forward (w)
        pass
    elif data == '83':
        # down (s)
        pass
    elif data == '65':
        # left (a)
        pass
    elif data == '68':
        # right (d)
        pass
    

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()

    try:
        while 1:
            client, clientInfo = s.accept()
            print("server recv from: ", clientInfo)
            data = client.recv(1024)      # receive 1024 Bytes of message in binary format
            callback(data)

            if data != b"":
                print(data)     
                client.sendall(data) # Echo back to client
    except: 
        print("Closing socket")
        client.close()
        s.close()    

