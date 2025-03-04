from flask import Flask
from flask import render_template
from flask import request, jsonify

def greet(name):
    return "Hi " + name + " . Python server sends its regards."

app = Flask(__name__)
greeting = " "
@app.route('/', methods=["GET", "POST"])
def index():

    global greeting

    # recieve message from electron app
    if request.method == "POST":
        json_message = request.get_json()
        print(json_message)
        greeting = greet(json_message)
        return jsonify(server_greet = greeting)        

    # return 'Iot is fun!'
    return jsonify(server_greet = greeting)

if __name__ == '__main__':
    app.run( host='172.16.213.108', port = 65432, debug=True) # khushi's pi
    # app.run( host='100.85.99.31', port = 65432, debug=True) # roy's pi
