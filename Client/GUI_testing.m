clear all;
filename='H:\Google drive\Škola\Mìøení\2017\C\800\UB0\C37_UB0_signal.csv';
data=dlmread(filename,';',10,0);
[f,y]=MyFFT(data(:,2),195e+3);
            
h=TestROIClass([f, y]);