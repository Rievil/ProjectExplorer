# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import os
import numpy as np
from MyFunctions import MyFunctions as mf
import re

folder=r'C:\Users\Richard\OneDrive - Vysoké učení technické v Brně\Měření\2021\Szymon\BendingProcess\Data\Bending'

def GetFiles(folder):
    filelist=[]
    
    for files in os.walk(folder):
        for txtfiles in files[2]:
            if txtfiles.endswith(".txt"):
                tmp=files[0] + '\\' + txtfiles
                filelist.append(tmp)
                
    return filelist

def GetNames(filelist):
    newarr=[]
    for i in range(0,len(filelist)):
        tmp=filelist[i].split('\\')
        newarr.append(tmp[-1].replace('.txt',''))
    return newarr
        
        

filelist=GetFiles(folder)
allnames=GetNames(filelist)

import pandas as pd
import matplotlib.pyplot as plt

from astropy.convolution import Gaussian1DKernel, convolve

row=36
df=pd.read_csv(filelist[row],sep="\t",names=("Time","Deformation","Force"))

names=filelist[row].split('\\')

x=mf.FillLine(mf,df.Deformation)
y=df.Force

#f = interpolate.interp1d(x, y,kind='cubic')

g = Gaussian1DKernel(stddev=100)
z = convolve(y, g)

x2=np.arange(x[0]*1000,x[len(x)-1]*1000)
x2=x2/1000
#y2=f(x2)

plt.plot(x,y,'-')
#plt.plot(x2,y2,'-')
#plt.plot(x,z,'-',color='red')


plt.gcf().set_dpi(300)

plt.xlabel('Deformace (mm)')
plt.ylabel('Síla F (N)')
plt.title(names[-1].replace('.txt',''))

ylist=y.tolist()

maxidx=ylist.index(max(ylist))

plt.plot(x[maxidx],y[maxidx],'o')
#%%

strength=np.empty([len(filelist)])

strength=pd.DataFrame(columns=("Name","MaxForce"))

df=pd.read_excel("Popis.xlsx",header=2,sheet_name="List2")
df=df.fillna(method="ffill")

def SepName(name,n):
    parts=name.split('_')
    
    nameID=parts[-1]
    parts[-1]=[]
    
    if parts[0]=="REF":
        Layers=0
    else:
        Layers=parts[0]
            
    
    
    if "F" in parts:
        HasFibers=1
    else:
        HasFibers=0
    
    if "P" in parts:
        Type="P"
    elif "REF" in parts:
        Type="REF"
    else:
        Type="W"
        
    r=pd.DataFrame(data={"Layers": Layers,"Type": Type, "HasFibers": HasFibers, "ID": nameID},
                   index=[n])
    return r    

namedf=pd.DataFrame(columns=("Layers","Type","HasFibers","ID"))
for i in range(0,len(filelist)):
    bendtest=pd.read_csv(filelist[i],sep="\t",names=("Time","Deformation","Force"))
    y=bendtest.Force
    ylist=y.tolist()
    maxidx=ylist.index(max(ylist))
    tst=SepName(allnames[i],i)
    namedf=pd.concat([namedf,tst])
    strength=strength.append({"Name": allnames[i], "MaxForce": y[maxidx]},ignore_index=True)

strfin=pd.concat([strength,namedf],axis=1)
#plt.xlim(0.2,0.25)

sz=strfin.shape

MaxForce=np.empty(df.shape[0])
MaxForce[:]=0
FileName = ["" for x in range(0,df.shape[0])]


for i in range(0,sz[0]):
    #idx=(df.Layers==strfin.Layers[i]) & (df.Type==strfin.Type[i]) & (df.HasFibers==strfin.HasFibers[i]) & (df.ID==strfin.ID[i])
    idx=(df.Layers==int(strfin.Layers[i])) & (df.Type==strfin.Type[i]) & (df.HasFibers==bool(strfin.HasFibers[i])) & (df.ID==strfin.ID[i])
    row=df[(idx)].index
    MaxForce[row[0]]=strfin.MaxForce[i]
    FileName[row[0]]=strfin.Name[i]

mf=pd.DataFrame({"MaxForce": MaxForce,"File": FileName})
fintab=pd.concat([df,mf],axis=1)

maxf=fintab["MaxForce"]
wid=fintab["width"]/1000
heig=fintab["height"]/1000
sfin=maxf*0.120*3/(2*wid*np.power(heig,2))

s2=pd.DataFrame({"TensileStrength": sfin,"Key": FileName},)
# s3=pd.DataFrame({"SpecName": allnames})
result = pd.concat([df,s2], axis=1)
result=pd.concat([result.pop('Key'),result],axis=1)
result.to_excel('MainTable.xlsx',index=False)
#%%

#%%
FileName = ["" for x in range(0,df.shape[0])]
FileName[0]=strfin.Name[row[0]]
        #pass
#%% Vytvoreni prehledové matrice
from scipy.io import savemat
from MyFunctions import MyFunctions as mf
import numpy as np
import sqlite3

strength=np.empty([len(filelist)])

strength=pd.DataFrame(columns=("Name","MaxForce"))

df=pd.read_excel("Popis.xlsx",header=2,sheet_name="List2")
df=df.fillna(method="ffill")

dates=('2021-08-02','2021-08-04','2021-08-10')

def SepName(name,n):
    parts=name.split('_')
    
    nameID=parts[-1]
    parts[-1]=[]
    
    if parts[0]=="REF":
        Layers=0
    else:
        Layers=parts[0]
            
    
    
    if "F" in parts:
        HasFibers=1
    else:
        HasFibers=0
    
    if "P" in parts:
        Type="P"
    elif "REF" in parts:
        Type="REF"
    else:
        Type="W"
        
    r=pd.DataFrame(data={"Layers": Layers,"Type": Type, "HasFibers": HasFibers, "ID": nameID},
                   index=[n])
    return r    

out=pd.DataFrame(columns=("Key","Time","Deformation","Force"))
namedf=pd.DataFrame(columns=("Layers","Type","HasFibers","ID"))
for i in range(0,len(filelist)):
    bendtest=pd.read_csv(filelist[i],sep="\t",names=("Time","Deformation","Force"))    
    
    
    x=bendtest.Time
    y=pd.Series(mf.FillLine(mf,bendtest.Deformation))
    z=bendtest.Force
    bend2=pd.DataFrame({"Time": x, 
                        "Deformation": y,
                        "Force": z})
    
    tst=SepName(allnames[i],i)
    tmp=pd.DataFrame({"Key": allnames[i],
                      "Time": bend2["Time"].values.tolist(),
                      "Deformation": bend2["Deformation"].values.tolist(),
                      "Force": bend2["Force"].values.tolist()})
    out=pd.concat([out,tmp])

con=sqlite3.connect('PresData.db')
tableSQL='''CREATE TABLE [PressData](
[ID] INTEGER PRIMARY KEY,
[KEY] [ntext] not null,
[Time] [double] not null,
[Deformation] [double] not null,
[Force] [double] not null)'''

tableNamesSQL='''CREATE TABLE [ColumnNames](
[ID] INTEGER PRIMARY KEY,
[Name] [ntext] not null)'''
    
names=pd.DataFrame({"Name": ("Key","Time","Deformation","Force")})    

    

cur=con.cursor()

checkquerry="""SELECT count(name) FROM sqlite_master WHERE type='table' AND name='PressData';"""
cur.execute(checkquerry)

if cur.fetchone()[0]==1:
    print('table does exists')
else:
    cur.execute(tableSQL)

checkquerry="""SELECT count(name) FROM sqlite_master WHERE type='table' AND name='ColumnNames';"""
cur.execute(checkquerry)
if cur.fetchone()[0]==1:
    print('table does exists')
else:        
    cur.execute(tableNamesSQL)

out.to_sql("PressData",con,if_exists="replace",index=False)
names.to_sql("ColumnNames",con,if_exists="replace",index=False)
con.commit()
con.close()
#%%
import matplotlib.pyplot as plt
idx=out["Key"]=='1_W_A'
x=out["Deformation"][idx].values
y=out["Force"][idx].values

plt.plot(x,y)
#%%
import matplotlib.pyplot as plt
import pandas as pd

df=pd.read_excel("Popis.xlsx",sheet_name="List2",header=2)
df.fillna(method='ffill',inplace=True)

vhratio=df["VH_RATIO"]

vhratio.plot.hist(grid=False,bins=20,density=True)
plt.ylabel('Četnost')
plt.xlabel('Poměr Vertical to horizontal velocity')

#%%

sada=result[(result.TensileStrength>0)]
sada=sada[(sada.Layers==0) | (sada.Layers==5) | (sada.Layers==4)]
unqnames=np.unique(sada["Name"])
for i in range (0,len(unqnames)):
    df2=sada[sada.Name==unqnames[i]]
    if df2.size>0:
        
        strength=df2["TensileStrength"]/1e+6
        x2=np.mean(strength)
        xerr=np.std(strength)
        y2=np.mean(df2["VelocityMean"])
        yerr=np.std(df2["VelocityMean"])
        
        #plt.scatter(df2["VH_RATIO"],df2["VelocityMean"],label=unqnames[i])
        plt.errorbar(x2,y2,xerr=xerr,yerr=yerr,label=unqnames[i],fmt='-o',capsize=5)
        
plt.legend(ncol=4)
plt.xlabel('Pevnost v tahu za ohybu (MPa)')
plt.ylabel('Rychlost ultrazvuku (m/s)')

#%%
sada=df[(df.Type=="W")]

unqnames=np.unique(sada["Name"])
for i in range (0,len(unqnames)):
    df2=sada[sada.Name==unqnames[i]]
    if df2.size>0:
        
        x2=np.mean(df2["VH_RATIO"])
        xerr=np.std(df2["VH_RATIO"])
        y2=np.mean(df2["VelocityMean"])
        yerr=np.std(df2["VelocityMean"])
        
        #plt.scatter(df2["VH_RATIO"],df2["VelocityMean"],label=unqnames[i])
        plt.errorbar(x2,y2,xerr=xerr,yerr=yerr,label=unqnames[i],fmt='-o')
        
plt.legend(ncol=4)
plt.xlabel('VH Poměr (-)')
plt.ylabel('Rychlost ultrazvuku (m/s)')

