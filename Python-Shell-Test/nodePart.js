var PythonShell = require('python-shell')

var options = {
    mode: 'text',
    pythonPath: 'python3'
}

var pyshell = new PythonShell('pythonPart.py',options);

pyshell.on('message', function(message) {
    console.log(message)
});

pyshell.send('This is a thing');
