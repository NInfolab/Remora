#!/usr/bin/python3

import serial, re
import numpy as np
import sys
import tkinter as tk
from matplotlib import pyplot as plt
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import (FigureCanvasTkAgg, NavigationToolbar2Tk)
import datetime, time
from serial.tools.list_ports import comports

NHIST=10000
DURHIST=3600

class Gui:
    def __init__(self, data):
        self.mainwin=tk.Tk()
        self.mainwin.wm_title("CO2 graph")
        self.data=data
        self.loop=False
        self.plotShown=False
        plt.ion()
        self.fig=Figure(figsize=(5,4), dpi=100)
        self.canvas=FigureCanvasTkAgg(self.fig, master=self.mainwin)
        self.canvas.draw()
        self.canvas.get_tk_widget().pack(side=tk.TOP, fill=tk.BOTH, expand=1)
        self.toolbar = NavigationToolbar2Tk(self.canvas, self.mainwin)
        self.toolbar.update()
        self.canvas.get_tk_widget().pack(side=tk.TOP, fill=tk.BOTH, expand=1)
        self.ax=self.fig.add_subplot(111)
        self.tick()
        
    def initPlot(self):
        self.plotShown=True
        self.plotdata=self.ax.plot(self.data.dates[:2], self.data.co2s[:2])[0]
    #    plt.show(block=False)
        self.draw()

    def draw(self):
        if self.plotShown:
            datemin, datemax, co2min, co2max=self.data.minmax(DURHIST, 10)
            self.ax.set_ylim(co2min, co2max)
            self.ax.set_xlim(datemin, datemax)
            self.plotdata.set_data(self.data.dates[:self.data.i], self.data.co2s[:self.data.i])
            self.fig.canvas.draw()
            self.process()

    def process(self):
        if self.plotShown:
            self.fig.canvas.start_event_loop(0.01)

    def tick(self):
        if self.loop: self.loop()
        self.mainwin.after(1000, self.tick)
        

class Serial:
    def __init__(self):
        lstSer=comports()
        devName="/dev/ttyUSB0"
        patNames=["ttyUSB", ".usbserial", "COM"]
        for s in lstSer:
            print(s.device)
            for k in patNames:
                if k in s.device: devName=s.device
        self.ser=serial.Serial(devName, 115200, timeout=0.1)
        self.regexCo2=re.compile('pulse\s([0-9]*)\s([0-9]*)\send')

    def getCo2(self):
        try:
            line=self.ser.readline()
            self.err=0
        except KeyboardInterrupt:
            sys.exit(0)
        except:
            self.err+=1
            if err>100: raise Exception('Serial port failed')
            return None
        v=self.regexCo2.findall(line.decode().strip())
        if len(v)!=1 or len(v[0])!=2: return None
        co2=int(v[0][1])
        if co2<300: return None
        return co2

class Data:
    def __init__(self, nhist):
        self.nhist=nhist
        self.dates=np.full((nhist,), datetime.datetime.now(), dtype='datetime64[s]')
        self.co2s=np.zeros((nhist,), dtype=np.float32)
        self.i=0

    def addCo2(self, co2):
        self.co2s[self.i]=co2
        self.dates[self.i]=datetime.datetime.now()
        self.i += 1
        if self.i>=self.nhist: self.roll(nhist//10)

    def roll(self, dt):
        self.dates=np.roll(self.dates, -dt)
        self.co2s=np.roll(self.co2s, -dt)
        self.i -= dt

    def minmax(self, durhist=-1000000000, ecmin=0):
        imin=np.argmax(self.dates[:self.i]>(self.dates[self.i-1]-durhist))
        dmin=self.dates[imin]
        dmax=self.dates[self.i-1]
        cmin=min(self.co2s[:self.i])
        cmax=max(self.co2s[:self.i])
        if dmin==dmax: dmin -= 1
        if ecmin>0 and cmax-cmin<ecmin:
            cmin -= ecmin/2
            cmax += ecmin/2
        return dmin, dmax, cmin, cmax

def loop():
    global starting
    co2=ser.getCo2()
    if co2 is None: return 
    print("co2 =", co2, "[starting]" if starting else "")
    if starting<=2: data.addCo2(co2)
    if starting==1: gui.initPlot()
    if starting>0: starting-=1
    gui.draw()

starting=16
ser=Serial()
data=Data(NHIST)
gui=Gui(data)
gui.loop=loop
tk.mainloop()
