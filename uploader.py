#!/usr/bin/env python3

import sys

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
    cmds.append(WrapCommand(0x11, bytes({0x00, 0x20, 0x7e})))
    for g in Groups(data, 8):
        cmds.append(WrapCommand(0x12,g))
    cmds.append(WrapCommand(0x11, bytes({0x00, 0x20, 0x7e})))
    cmds.append(WrapCommand(0x10, bytes(0)))
    return cmds

def Main(args):
    if len(args) != 3:
        print("script input output")
        return 1
    f = open(args[1],"rb")
    fout = open(args[2],"wb")
    cmds = UploadAndExecute(f.read())
    for cmd in cmds:
        fout.write(cmd)
    f.close()
    fout.close()

if __name__ == "__main__":
    sys.exit(Main(sys.argv))