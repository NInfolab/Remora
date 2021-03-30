#!/usr/bin/python3

NBUF=10
NHIST=10000

import serial, re
import numpy as np
from matplotlib import pyplot as plt
import datetime
from serial.tools.list_ports import comports


lstSer=comports()
devName="/dev/ttyUSB0"
patNames=["ttyUSB", ".usbserial"]
for s in lstSer:
    for k in patNames:
        if k in s.device: devName=s.device

ser=serial.Serial(devName, 115200, timeout=1)
r=re.compile('pulse\s([0-9]*)\s([0-9]*)\send')

dates=np.full((NHIST,), datetime.datetime.now(), dtype='datetime64[s]')
co2s=np.zeros((NHIST,), dtype=np.float)
i=0

plt.ion()
fig=plt.figure()
ax=plt.subplot(111)
data=ax.plot(dates, co2s)[0]

plt.show(block=False)

k=0
buf=[0]*NBUF

while True:
    line=ser.readline()
    v=r.findall(line.decode().strip())
    if len(v)!=1: continue
    if len(v[0])!=2: continue
    co2=int(v[0][1])
    if co2<300: continue
    buf[k]=co2
    k=(k+1)%NBUF
    lis=sum(buf)/NBUF
    print("co2 =", co2, lis)
    dates[i]=datetime.datetime.now()
    co2s[i]=lis
    if i==0 and k!=0: continue
    i+=1
    if i<5: continue
    if i>=NHIST:
        dates=np.roll(dates, -NHIST//10)
        dates[-NHIST//10:]=None
        co2s=np.roll(co2s, -NHIST//10)
        co2s[-NHIST//10:]=0
    ax.set_ylim(min(co2s[:i]), max(co2s[:i]))
    ax.set_xlim(min(dates[:i]), max(dates[:i]))
    data.set_data(dates[:i], co2s[:i])
    fig.canvas.draw()
    fig.canvas.start_event_loop(0.01)
