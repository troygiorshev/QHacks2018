import sys

test = "hello"

print(sys.version)
print(test)

#Okay, just something simple now to echo stuff back

try:
    buff = ''
    while True:
        buff = input()
        if(buff == 'START'):
            buff = input()
            print('x: ' + buff)
            buff = input()
            print('y: ' + buff)
            buff = input()
            print('app: ' + buff)
            buff = input()
            print('click: ' + buff)
        buff = ''
except KeyboardInterrupt:
    sys.stdout.flush()
    pass

print("DONE")
