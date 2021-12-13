# -*- coding: utf-8 -*-
"""
Created on Wed Sep  1 16:28:29 2021

@author: Richard.Dvorak
"""

import numpy as np


class MyFunctions:
    def __init__(self):
        pass
    
    def __FillPart(self,arr,orig,startidx,endidx):
        x2=np.linspace(orig[startidx]*1000,orig[endidx]*1000,abs(endidx-startidx))
        x2=x2/1000
        
        n=0
        for i in range(startidx,endidx):
            arr[i]=x2[n]
            n=n+1
            
        return arr
    
    def FillLine(self,inarr):
        newarr=np.empty([len(inarr)])
        newarr[:]=0
        deff=inarr+0.001
        tmp=deff[0]
        startidx=0
        count=0

        for  i in range(0,len(deff)-1):
            if tmp != deff[i]:
                
                tmp=deff[i]
                newarr=self.__FillPart(self,newarr,deff,startidx,i+1)
                
                startidx=i
                count+=1
        
        newarr=self.__FillPart(self,newarr,deff,startidx,len(inarr)-1)
        newarr=newarr-0.001
        newarr[len(newarr)-1]=inarr[len(inarr)-1]
        return newarr