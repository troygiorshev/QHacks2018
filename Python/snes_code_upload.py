import serial

serial = serial.Serial("COM6", 115200, timeout=1)
serial.close()

# -------------------- CONSTANTS --------------------

# PRT address is $7E2000
FIXED_PTR_LOCATION_0 = 0x00
FIXED_PTR_LOCATION_1 = 0x20
FIXED_PTR_LOCATION_2 = 0x7E

PUT_DATA_COMMAND   = 18 # (0x12), Type 0
CHANGE_PTR_COMMAND = 17 # (0x11), Type 1
START_EXEC_COMMAND = 16 # (0x10), Type 2

# -------------------- SPLIT --------------------

def split(arr, size):
     arrs = []
     while len(arr) > size:
         pice = arr[:size]
         arrs.append(pice)
         arr = arr[size:]
     arrs.append(arr)
     return arrs

# -------------------- SEND DATA --------------------

def sendData(typeOfData, data):
    if typeOfData == 0:
        dataToSend = ("\x00\x00\x00" + chr(PUT_DATA_COMMAND) + data)
    if typeOfData == 1:
        dataToSend = ("\x00\x00\x00" + chr(CHANGE_PTR_COMMAND) + data.decode('utf-8'))
    if typeOfData == 2:
        dataToSend = ("\x00\x00\x00" + chr(START_EXEC_COMMAND) + data)

    print(dataToSend)
    #serial.write(dataToSend)

# -------------------- READ & SEND FILE --------------------

with open("testBinFile", mode='rb') as file: # rb = read binary
    fileContent = file.read()

    serial.open()

    # -------------------- CHANGE PTR TO START --------------------

    sendData(1, bytes([FIXED_PTR_LOCATION_0, FIXED_PTR_LOCATION_1, FIXED_PTR_LOCATION_2, 0x00, 0x00, 0x00, 0x00, 0x00]))

    # -------------------- SEND PROGRAM DATA --------------------
    
    for v in split(fileContent, 8):
        v = v.decode("utf-8")
        sendData(0, v)
        
    # -------------------- CHANGE PTR TO START --------------------

    sendData(1, bytes([FIXED_PTR_LOCATION_0, FIXED_PTR_LOCATION_1, FIXED_PTR_LOCATION_2, 0x00, 0x00, 0x00, 0x00, 0x00]))

    # -------------------- START EXEC --------------------

    sendData(2, chr(0))

    serial.close()
