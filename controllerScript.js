var noble = require('noble');
var Quaternion = require('quaternion');
var PythonShell = require('python-shell')

//First and foremost, start up the python script
var options = {
    mode: 'text',
    pythonPath: 'python3',
    args: process.argv[2]
}
var pyshell = new PythonShell('controller.py',options);

//constants

const SCREENWIDTH = 20 //Screen width in cm
const SCREENHEIGHT = 15 //Screen height in cm

noble.on('stateChange', function(state) {
  if (state === 'poweredOn') {
    noble.startScanning();
  } else {
    noble.stopScanning();
  }
});

//Some initialization
let state = {};
distance = 80 //distance from screen in cm.
state.yOff = 0; state.pOff = 0
state.mode = 1
state.wasVolPlusDown
let volPlusWaiting, volMinusWaiting
lastTime = 0;

noble.on('discover', function(peripheral) {
    //console.log(peripheral.advertisement.localName);
    if(peripheral.advertisement.localName == 'Daydream controller'){
        console.log('FOUND!');
        peripheral.connect(function(error){
            console.log('Connected');
            peripheral.discoverServices(['fe55'], function(error, services){
                var dataService = services[0];
                dataService.discoverCharacteristics(null, function(error, characteristics){
                    characteristics[0].subscribe(function(data){
                    });
                    characteristics[0].on('data',function(data){
                        handleData(data);
                    });
                });
            });
        });
    }
});

function handleData(dataOLD) {

    dataMID = toArrayBuffer(dataOLD);
    data = new DataView(dataMID);

    //Credit to: mrdoob/daydream-controller.js

    state.isClickDown = (data.getUint8(18) & 0x1) > 0;
	state.isAppDown = (data.getUint8(18) & 0x4) > 0;
	state.isHomeDown = (data.getUint8(18) & 0x2) > 0;
	state.isVolPlusDown = (data.getUint8(18) & 0x10) > 0;
	state.isVolMinusDown = (data.getUint8(18) & 0x8) > 0;

	state.time = ((data.getUint8(0) & 0xFF) << 1 | (data.getUint8(1) & 0x80) >> 7);

	state.seq = (data.getUint8(1) & 0x7C) >> 2;

	state.xOri = (data.getUint8(1) & 0x03) << 11 | (data.getUint8(2) & 0xFF) << 3 | (data.getUint8(3) & 0x80) >> 5;
	state.xOri = (state.xOri << 19) >> 19;
	state.xOri *= (2 * Math.PI / 4095.0);

	state.yOri = (data.getUint8(3) & 0x1F) << 8 | (data.getUint8(4) & 0xFF);
	state.yOri = (state.yOri << 19) >> 19;
	state.yOri *= (2 * Math.PI / 4095.0);

	state.zOri = (data.getUint8(5) & 0xFF) << 5 | (data.getUint8(6) & 0xF8) >> 3;
	state.zOri = (state.zOri << 19) >> 19;
	state.zOri *= (2 * Math.PI / 4095.0);

	state.xAcc = (data.getUint8(6) & 0x07) << 10 | (data.getUint8(7) & 0xFF) << 2 | (data.getUint8(8) & 0xC0) >> 6;
	state.xAcc = (state.xAcc << 19) >> 19;
	state.xAcc *= (8 * 9.8 / 4095.0);

	state.yAcc = (data.getUint8(8) & 0x3F) << 7 | (data.getUint8(9) & 0xFE) >>> 1;
	state.yAcc = (state.yAcc << 19) >> 19;
	state.yAcc *= (8 * 9.8 / 4095.0);

	state.zAcc = (data.getUint8(9) & 0x01) << 12 | (data.getUint8(10) & 0xFF) << 4 | (data.getUint8(11) & 0xF0) >> 4;
	state.zAcc = (state.zAcc << 19) >> 19;
	state.zAcc *= (8 * 9.8 / 4095.0);

	state.xGyro = ((data.getUint8(11) & 0x0F) << 9 | (data.getUint8(12) & 0xFF) << 1 | (data.getUint8(13) & 0x80) >> 7);
	state.xGyro = (state.xGyro << 19) >> 19;
	state.xGyro *= (2048 / 180 * Math.PI / 4095.0);

	state.yGyro = ((data.getUint8(13) & 0x7F) << 6 | (data.getUint8(14) & 0xFC) >> 2);
	state.yGyro = (state.yGyro << 19) >> 19;
	state.yGyro *= (2048 / 180 * Math.PI / 4095.0);

	state.zGyro = ((data.getUint8(14) & 0x03) << 11 | (data.getUint8(15) & 0xFF) << 3 | (data.getUint8(16) & 0xE0) >> 5);
	state.zGyro = (state.zGyro << 19) >> 19;
	state.zGyro *= (2048 / 180 * Math.PI / 4095.0);

	state.xTouch = ((data.getUint8(16) & 0x1F) << 3 | (data.getUint8(17) & 0xE0) >> 5);
	state.yTouch = ((data.getUint8(17) & 0x1F) << 3 | (data.getUint8(18) & 0xE0) >> 5);

    //</credit>

    //This orientation data starts with Axis-Angle orientation, where the magnitude of the vector represents the angle.

    state.angle = Math.sqrt(state.xOri*state.xOri + state.yOri*state.yOri + state.zOri*state.zOri);

    state.xA = state.xOri / state.angle;
    state.yA = state.yOri / state.angle;
    state.zA = state.zOri / state.angle;

    //Now we're in true Axis-Angle orientation form.
    //What we're looking for is to convert to Euler angles: yaw, pitch, roll
    //In that order, and then we'll just drop the roll, because we don't care!
    //Converting to quaternions first seems like the typical way.

    state.q = Quaternion.fromAxisAngle([state.xA, state.yA, state.zA], state.angle);

    //Woot, we have a quaternion!

    //Solve the gimbal lock pole issue
    t = state.q.y * state.q.x + state.q.z * state.q.w;
    t = t > 0.499 ? 1 : (t < -0.499 ? -1 : 0);
    //Ternary operators are cool

    state.Pitch = t == 0 ? Math.asin(2*(state.q.w * state.q.x - state.q.z * state.q.y) <= -1 ? -1 : 2*(state.q.w * state.q.x - state.q.z * state.q.y) >= 1 ? 1 : 2*(state.q.w * state.q.x - state.q.z * state.q.y)) : t *  Math.PI * 0.5;

    //Woot, we have Pitch and Yaw!
    //Sort of.  The Yaw works perfectly, ranging between -3.14 to +3.14, with 0 being forward.  The Pitch is interesting.  It ranges from 1.57 to -1.57, with 0 being flat, and 1.57 being directly upwards.  Then, once you continue a "backflip", the values decrease from 1.57 back down to zero.  But, whatever, that's good enough!

    currentTime = Date.now()

    //Time to correct the values for forward.

    //Get wrong orientations
    if(state.isVolPlusDown && !state.wasVolPlusDown){
        downTime = currentTime
        state.wasVolPlusDown = true
        state.pOff = state.Pitch;
    }else if(!state.isVolPlusDown && state.wasVolPlusDown){
        if(currentTime > downTime + 500){
            state.mode = state.mode == 1 ? 2 : 1
        }
    }
    state.wasVolPlusDown = state.isVolPlusDown

    //Correct Orientation
    state.Pitch = state.Pitch - state.pOff

    if(currentTime - lastTime > 20){
        pyshell.send('START')
        pyshell.send(state.mode)
        pyshell.send(state.Pitch)
        pyshell.send(state.isHomeDown)
        pyshell.send(state.isAppDown)
        pyshell.send(state.isClickDown)
        pyshell.send(state.isVolMinusDown)
        pyshell.send(state.xTouch)
        pyshell.send(state.yTouch)
        lastTime = currentTime
    }
}

function toArrayBuffer(buf) {
    var ab = new ArrayBuffer(buf.length);
    var view = new Uint8Array(ab);
    for (var i = 0; i < buf.length; ++i) {
        view[i] = buf[i];
    }
    return ab;
}

pyshell.on('message', function(message) {
    console.log(message)
});
