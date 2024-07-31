#!/usr/bin/python3

from reportlab.pdfgen import canvas
from reportlab.lib.units import cm as cm
import math

pdf=canvas.Canvas("galvaBack.pdf")
#pdf.drawString(x,y,text)
#pdf.translate(x,y)
x0=5*cm
y0=5*cm
w=5.950*cm
h=3.54*cm
dr=0.567*cm
r=dr+0.626*cm
e=3.136*cm
de=0.32*cm
p0=(0.895*cm+x0, 1.670*cm+y0)
p50=(w/2+x0, 2.490*cm+y0)
p100=(x0+w-0.895*cm, 1.670*cm+y0)
dp=(((p100[0]-p0[0])/2)**2-(p50[1]-p0[1])**2)/2/(p50[1]-p0[1])
R=dp+p50[1]-p0[1]
dR=0.4*cm
xc=w/2+x0
yc=p0[1]-dp
u=1600/38.0
ppms=[0, 400, 600, 800, 1000, 1500, 2000]
def ppm2a(p):
    ua=(p-400)/u+10
    a=90-(ua-25)*(45/25)
    return a

pdf.rect(x0, y0, w, h)
pdf.circle(x0+w/2, y0-dr, r)
pdf.circle(x0+w/2-e/2, x0+de, 0.15*cm)
pdf.circle(x0+w/2+e/2, x0+de, 0.15*cm)
pdf.arc(xc-R, yc-R, xc+R, yc+R, 45, extent=90)
for p in ppms:
    a=ppm2a(p)*math.pi/180
    pdf.line(xc+R*math.cos(a), yc+R*math.sin(a), xc+(R+dR)*math.cos(a), yc+(R+dR)*math.sin(a))

pdf.drawString(x0+w/2-cm, y0+1.2*cm, "[co2] p/10k")
pdf.translate(xc, yc)
for p in ppms:
    a=ppm2a(p)-2
    pdf.rotate(a)
    pdf.drawString(R+dR, 0, "%d"%(p//100))
    pdf.rotate(-a)
    
    

pdf.setFont("Helvetica", 10)
pdf.showPage()
pdf.save()
