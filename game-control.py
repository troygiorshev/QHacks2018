#!/usr/bin/env python3

import sys
import serial
serial = serial.Serial()
serial.close()

def Main(args):
    global port
    if len(args) != 2:
        print("Invalid input arguments")
        return 1

    serial.port = args[1]
    serial.baudrate = 115200
    serial.timeout = 3
    serial.open()

    input("Press enter to send data...")
    
    nCmdsGood = 0

    print("Starting upload on " + args[1] + "...")
    while True:
        cmd = bytes([ (0x80 if ((nCmdsGood % 5) == 0) else 0) | (0x01 if ((nCmdsGood % 3) == 0) else 0), 0 ])
        serial.write(cmd)
        resp = serial.read(len(cmd))
        if len(resp) > 0:
            if resp == cmd:
                nCmdsGood += 1
            print(resp)
        else:
            print("Waited too long.")
            break

    input("Press enter to close serial port...")

    serial.close()
    print("Done!")

if __name__ == "__main__":
    sys.exit(Main(sys.argv))
