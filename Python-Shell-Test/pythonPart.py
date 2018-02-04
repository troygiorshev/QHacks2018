import sys

test = "hello"

print(sys.version)
print(test)

#Okay, just something simple now to echo stuff back

try:
    buff = ''
    while True:
        buff = input()
        print(buff)
        buff = ''
except KeyboardInterrupt:
    sys.stdout.flush()
    pass

print("DONE")
