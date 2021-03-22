#!/usr/bin/python3

import machine, ssd1306, time
import network
import urequests

def myInit():
    global oled, station, bt0, touch
    i2c = machine.I2C(scl=machine.Pin(15), sda=machine.Pin(4))
    reset_oled = machine.Pin(16, machine.Pin.OUT)
    reset_oled.value(0)
    time.sleep(0.05)
    reset_oled.value(1)
    oled = ssd1306.SSD1306_I2C(128, 64, i2c)

    station = network.WLAN(network.STA_IF)
    station.active(True)
    station.connect('urznet', 'dlpdaiyadmqclrqlhaldadlpdaiyadmqdcdolldbm')

    bt0=machine.Pin(0, machine.Pin.IN)
    touch=machine.TouchPad(machine.Pin(12))


def mandIt(x,y,n):
    r=0
    i=0
    for k in range(n):
        nr=r*r-i*i+x
        i=2*i*r+y
        r=nr
        if r>5 or r<-5 or i>5 or i<-5:
            return True
    return False

myInit()

def mandel():
    oled.fill(0)
    for ix in range(128):
        x=(ix-64.0)/25.0
        for iy in range(64):
            y=(iy-32.0)/25.0;
            if mandIt(x, y, 100):
                oled.pixel(ix,iy,1)
        oled.show()

def drawH(x, y, sz, col=1):
    for i in range(sz): oled.pixel(x+i, y, col)

def drawV(x,y, sz, col=1):
    for i in range(sz): oled.pixel(x,y+i, col)

def drawSl(x,y,sz,col=1):
    for i in range(sz): oled.pixel(x+i//2, y+i, col)

def drawAs(x,y,sz,col=1):
    for i in range(sz): oled.pixel(x-i//2, y+i, col)

def drawSeg(dg, x, y, sz, col=1):
    if dg & 1: drawH(x,y,sz, col)
    if dg & 2: drawV(x,y,sz, col)
    if dg & 4: drawV(x+sz,y, sz, col)
    if dg & 8: drawH(x,y+sz, sz, col)
    if dg & 0x10: drawV(x,y+sz, sz, col)
    if dg & 0x20: drawV(x+sz, y+sz, sz, col)
    if dg & 0x40: drawH(x, y+2*sz, sz, col)
    if dg & 0x80: drawSl(x,y,sz, col)
    if dg & 0x100: drawAs(x+sz,y,sz, col)


sg={'0': 0x77, '1':0x24, '2':0x5D, '3':0x6D, '4':0x2E, '5':0x6B, '6':0x7B, '7':0x25, '8':0x7F, '9':0x6F,
    'L': 0x52, 'E':0x5B, 'C':0x53, ' ':0,
    'M': 0x1B6, '*':0x1FF}

def drawStr(str, x, y, sz, col=1):
    for i in range(len(str)):
        c=str[i]
        if not c in sg: c='*'
        drawSeg(sg[c], x+(sz+3)*i, y, sz, col)

loopi=0
lastlec='XXX'
lastMC='XXX'
while True:
    oled.fill(0)
    time.sleep(0.2)
    if bt0.value()==0:
        break
    loopi += 1
    ttt=touch.read()
    oled.text('touch '+str(ttt), 10, 0, 1)
    oled.text('MC '+lastMC, 10, 12, 1)
    oled.text(str(loopi), 110, 54, 1)
    sz=8
    drawStr('LEC '+lastlec, 10, 24, sz, 1)
    drawStr('MC  '+lastMC, 10, 24+2*sz+5, sz, 1)
    oled.show()
    if loopi<50 and ttt>500:
        continue
    loopi=0
    response = urequests.get('https://christophe.legal/ni/testlec.php')
    lastlec=response.text.replace('\n','')
    response = urequests.get('http://192.168.1.2/Documents/run/mailcount.txt')
    lastMC =response.text

