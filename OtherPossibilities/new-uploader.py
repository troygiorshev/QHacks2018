#!/usr/bin/env python3

import sys
import serial
serial = serial.Serial()
serial.close()
    
def WrapCommand(cmd, data):
    ret = bytearray(18)
    ret[1] = cmd & 0x3
    for i in range(len(data)):
        ret[i+2] = data[i]
    return ret

def Groups(data, l):
    ret = []
    while data:
        ret.append(data[0:l])
        data = data[l:]
    return ret

def UploadAndExecute(data):
    cmds = []
    for g in Groups(data, 16):
        cmds.append(WrapCommand(0x1,g))
    cmds.append(WrapCommand(0x3, bytes(0)))
    return cmds

def Main(args):
    global port
    if len(args) != 4:
        print("Invalid input arguments")
        return 1
    
    f = open(args[1],"rb")
    fout = open(args[2],"wb")
    cmds = UploadAndExecute(f.read())
    f.close()

    serial.port = args[3]
    serial.baudrate = 115200
    serial.timeout = 10
    serial.open()

    input("Press enter to send data.")
    
    nCmdsGood = 0

    print("Starting upload on " + args[3] + "...")
    for cmd in cmds:
        fout.write(cmd)
        serial.write(cmd)
        resp = serial.read(len(cmd))
        if len(resp) > 0:
            if resp == cmd:
                nCmdsGood += 1
            print(resp)
        else:
            print("Waited too long.")
            break

    if nCmdsGood == len(cmds):
        print("All commands transferred 'successfully'.")
    else:
        print("Error! # of commands: {0}   # of successes: {1}".format(len(cmds),nCmdsGood))
    input("Press enter to close serial port.")

    fout.close()
    serial.close()
    print("Done!")

if __name__ == "__main__":
    sys.exit(Main(sys.argv))
