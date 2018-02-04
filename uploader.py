#!/usr/bin/env python3

import sys
import serial
serial = serial.Serial()
serial.close()
    
def WrapCommand(cmd, data):
    ret = bytearray(12)
    ret[1] = 0b00001101
    ret[3] = cmd
    for i in range(len(data)):
        ret[i+4] = data[i]
    accum = 0
    for v in ret:
        accum += v
    ret[2] = 0x100 - (accum & 0xff)
    return ret

def Groups(data, l):
    ret = []
    while data:
        ret.append(data[0:l])
        data = data[l:]
    return ret

def UploadAndExecute(data):
    cmds = []
    cmds.append(WrapCommand(0x11, bytes({0x00, 0xa0, 0x7f})))
    for g in Groups(data, 8):
        cmds.append(WrapCommand(0x12,g))
    cmds.append(WrapCommand(0x11, bytes({0x00, 0xa0, 0x7f})))
    cmds.append(WrapCommand(0x10, bytes(0)))
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
        resp = serial.read(12)
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
