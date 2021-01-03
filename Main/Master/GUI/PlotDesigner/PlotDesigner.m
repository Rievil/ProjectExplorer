classdef PlotDesigner < handle
    
    %Main souborp ro plti designing
    %Struktura je zalo�en� na tom, �e poprv� jak se nahraje data z
    %dataloadru do design�ra, tak by m�lo b�t mo�n� nastvit jak� jsou
    %popisov� prom�nn� jednotliv�ch m��en�
    
    %Objektu p�ed�m data z selekce z project exploreru a projedu, v
    %hlavn�m okn� aplikace pak vyzvu u�ivatele aby se rozhodl, zda
    %m�m data nasekat za n�j pomoc� datacarouselu, nebo mu m�m
    %rovnou umo�nit vyb�rat konkr�tn� m��en� a jejich prom�nn�

    %Data sorter bench
    %z jedn� selekce dat bych m�l moci vytvo�it n�kolik plotovac�h
    %profil�, ka�d� profil je definov�n vlastn�m v�b�rem typu
    %plotu, grafiky, legendy, barev, skupin dat apod.


    %�vodn� v�b�r typu plotu by m�l d�le umo��ovat dopo��t�vat.
    %simulovat upravovat, filtrovat data, p�ed t�m ne� budou
    %vykresleny, z �eho� je d�le�it� zm�nit n�sleduj�c�,
    %interpolace, extrapolace, vykreslen� bod� dle zadan� k�ivky,
    %kontrola po�tu bod�, nastavit limity (min,max), kontrolovat
    %neopakuj�c� se hodnoty k�ivek = m�lo byse jednat o skupinu
    %modl�, kter� lze pou��t i zp�tn�, jako reakce na nemo�nost
    %n�co vykreslit, pokud u�ivatel projde touto ��st�, nenastav�
    %to a najednou to nefunguje

    %Variable bench
    %T�m jak nat�hnu data z dataloaderu, tak pro kreslen� grafu je
    %pot�eba definovat prom�nn�, kter� p�jdou do jednotliv�ch
    %iterac� dle datacarouselu / ru�n�ho v�b�ru, v tento moment mou
    %upravovat ji� existuj�c� prom�n� a p�id�vat nov� dopo��t�van�

    %mo�nost pod�vat se co konkr�tn�ho m�m v dan�m m��en� - funkce,
    %kter� by m�la b�t sou��st� datov�ch typ� jako takov�ch

    %Rules - co d�lat kdy� u n�jak�ho vzorku n�hodou nem�m t�eba
    %events? Nebo kdy� po n�jak�m filtru nen� co zobrazit?

    %Mo�nost prov�d�t anal�zu by m�la b�t vlastnost vlastn�
    %objektov� rodin� pro prov�d�n� anal�z na datech,
    
    properties
        GeneralPlot;
        PlotProfiles;
        Parent; %projectobj
    end
    
    methods %main - obecne pouzivan� designera
        %konstruktor objektu
        function obj = PlotDesigner(~)
            
        end
        
        function FillGui(obj,Parent)
            obj.Parent=Parent;
            LoadPlotDesigner(obj);
        end
        
        function LoadProfiles(obj)
            if size(obj.Parent.PlotProfiles)>0
                %no profiles were yet created
                
            else
                %there already is a profile which can be loaded
                
            end
        end
        
        function GiveData(obj,data)
            
            
        end
        
        function SetKeyVar(obj,KeyVarNum)
            %
        end
        
        function RunAnalysis(obj)
            %
        end
    end
end

