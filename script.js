var noble = require('noble');

noble.on('stateChange', function(state) {
  if (state === 'poweredOn') {
    noble.startScanning();
  } else {
    noble.stopScanning();
  }
});

var state = {};

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

function handleData(data) {
    console.log(data);
}
