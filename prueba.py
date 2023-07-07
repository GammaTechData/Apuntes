from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def hello_world():
    return render_template('gamma.html')

@app.route('/saludar')
def hola():
    return "<h3> Segunda pagina <h3>"


if __name__ == '__main__':
    app.run(debug=True)










# @app.route("/")
# def hello_world():
#     #return "<p>Hello, World<p>"
#     return render_template('base.html')

# @app.route('/greet')
# def greet():
#     return "<p> Buenas <p>"

# if __name__ == '__main__':
#     app.run(debug=True)