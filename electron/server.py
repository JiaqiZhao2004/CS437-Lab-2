import socket
from time import sleep
from system_stats import get_cpu_temperature, get_cpu_usage, get_memory_usage, get_network_stats
from picarx import Picarx


# HOST = "172.16.213.108" # Khushi's Raspberry PI
HOST = "100.85.99.31" # Roy's Raspberry PI
PORT = 65432          # Port to listen on (non-privileged ports are > 1023)


def callback(px, data):
    data = data.strip()
    if data == b'87':
        print("forward (w)")
        # forward (w)
        px.set_dir_servo_angle(0)
        px.forward(10)
        sleep(0.3)
        px.stop()
    elif data == b'83':
        # down (s)
        print("backward (s)")
        px.set_dir_servo_angle(0)
        px.backward(10)
        sleep(0.3)
        px.stop()
    elif data == b'65':
        # left (a)
        print('left (a)')
        px.set_dir_servo_angle(-35)
        px.forward(10)
        sleep(0.3)
        px.stop()
    elif data == b'68':
        # right (d)
        print('right (d)')
        px.set_dir_servo_angle(35)
        px.forward(10)
        sleep(0.3)
        px.stop()
    car_data = get_data()
    print(car_data)
    client.sendall(car_data)

def get_data():
    data = {
        "cpu_temp": get_cpu_temperature(),
        "cpu_usage": get_cpu_usage(),
        "memory_usage": get_memory_usage(),
        "network_stats": get_network_stats(),
    }
    return data


with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    px = Picarx()
    try:
        while 1:
            client, clientInfo = s.accept()
            print("server recv from: ", clientInfo)
            data = client.recv(1024)      # receive 1024 Bytes of message in binary format
            callback(px, data)
  
    except:
        print("Closing socket")
        client.close()
        s.close()
        px.stop()
