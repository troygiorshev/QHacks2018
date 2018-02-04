import sys
import serial
import math
serial = serial.Serial()
serial.close()

def bitstring_to_bytes(s):
    return int(s, 2).to_bytes(len(s) // 8, byteorder='big')

def Main(args):
    try:
        buff = ''
        sys.stderr.write("{0}\n".format(args))
        if len(args) != 2:
            return 1

        serial.port = args[1]
        serial.baudrate = 115200
        serial.timeout = 10
        serial.open()

        while True:
            buff = input()
            if(buff == 'START'):
                #Set everything to zero to start
                b = 0
                y = 0
                select = 0
                start = 0
                up = 0
                down = 0
                left = 0
                right = 0
                a = 0
                x = 0
                lb = 0
                rb = 0
                home = 0
                app = 0
                click = 0
                volm = 0
                buff = input()
                mode = int(buff)
                if(mode == 1):
                    buff = input()
                    #<crapcode>
                    if(buff == ''):
                        buf = 0
                    else:
                        buf = float(buff)
                    if(buf < -0.3):
                        left = 1
                        right = 0
                    elif(buf > 0.3):
                        right = 1
                        left = 0
                    #</crapcode>
                    buff = input()
                    if (buff): home = 1
                    up = home
                    buff = input()
                    if (buff): app = 1
                    down = app
                    if(home or app): a = 1
                    buff = input()
                    if(buff): click = 1
                    lb = click
                    buff = input()
                    if(buff): volm = 1
                    start = volm
                    #<crapcode2.0>
                    buff = input()
                    if(buff == ''):
                        buf = 0
                    else:
                        buf = int(buff)
                    if(buf < 128 and buf > 0):
                        y = 1
                        b = 0
                    elif(buf > 128):
                        b = 1
                        y = 0
                    else:
                        b = 0
                        y = 0
                    buff = input()
                    pass
                    #</crapcode2.0>
                if(mode == 2):
                    buff = input()
                    pass
                    buff = input()
                    if(buff): home = 1
                    b = home
                    buff = input()
                    if(buff): app = 1
                    x = app
                    buff = input()
                    pass
                    buff = input()
                    pass
                    buff = input()
                    xTouch = int(buff)-128 if buff else 0
                    buff = input()
                    yTouch = int(buff)-128 if buff else 0
                    #Do the math to turn the touchpad to a d pad
                    if(xTouch != 0 and yTouch != 0 and (math.sqrt(xTouch ** 2 + yTouch ** 2))>55):
                        angle = (math.atan2(xTouch, yTouch)*360/6.28) +180
                        if(angle < 45 or angle > 315):
                            left = 1
                        elif(angle > 45 and angle < 135):
                            down = 1
                        elif(angle > 135 and angle < 225):
                            right = 1
                        elif(angle > 225 and angle < 315):
                            up = 1
            buff = ''

            controllerData = str(b)+str(y)+str(select)+str(start)+str(up)+str(down)+str(left)+str(right)+str(a)+str(x)+str(lb)+str(rb)+'0000'
            contDataBytes = bitstring_to_bytes(controllerData)
            print(contDataBytes)

            serial.reset_output_buffer()
            serial.write(contDataBytes)

            echo = serial.read(len(contDataBytes))
            if len(echo) != len(contDataBytes):
                print("BAD!")

            #print(controllerData)
    except KeyboardInterrupt:
        sys.stdout.flush()
        serial.close()
        pass

    print("DONE")

if __name__ == "__main__":
    sys.exit(Main(sys.argv))
