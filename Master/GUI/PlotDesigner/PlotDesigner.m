classdef PlotDesigner
    
    %Main souborp ro plti designing
    %Struktura je založená na tom, že poprvé jak se nahraje data z
    %dataloadru do designéra, tak by mìlo být možné nastvit jaké jsou
    %popisové promìnné jednotlivých mìøení
    
    properties
        Property1
    end
    
    methods %main - obecne pouzivaní designera
        %konstruktor objektu
        function obj = PlotDesigner(inputArg1,inputArg2)

        end
        
        function GiveData(obj,data)
            %Objektu pøedám data z selekce z project exploreru a projedu, v
            %hlavním oknì aplikace pak vyzvu uživatele aby se rozhodl, zda
            %mám data nasekat za nìj pomocí datacarouselu, nebo mu mám
            %rovnou umožnit vybírat konkrétní mìøení a jejich promìnné
            
            %Data sorter bench
            %z jedné selekce dat bych mìl moci vytvoøit nìkolik plotovacíh
            %profilù, každý profil je definován vlastním výbìrem typu
            %plotu, grafiky, legendy, barev, skupin dat apod.
            
            
            %Úvodní výbìr typu plotu by mìl dále umožòovat dopoèítávat.
            %simulovat upravovat, filtrovat data, pøed tím než budou
            %vykresleny, z èehož je dùležité zmínit následující,
            %interpolace, extrapolace, vykreslení bodù dle zadané køivky,
            %kontrola poètu bodù, nastavit limity (min,max), kontrolovat
            %neopakující se hodnoty køivek = mìlo byse jednat o skupinu
            %modlù, které lze použít i zpìtnì, jako reakce na nemožnost
            %nìco vykreslit, pokud uživatel projde touto èástí, nenastaví
            %to a najednou to nefunguje
            
            %Variable bench
            %Tím jak natáhnu data z dataloaderu, tak pro kreslení grafu je
            %potøeba definovat promìnné, které pùjdou do jednotlivých
            %iterací dle datacarouselu / ruèního výbìru, v tento moment mou
            %upravovat již existující promìné a pøidávat nové dopoèítávané
            
            %možnost podívat se co konkrétního mám v daném mìøení - funkce,
            %která by mìla být souèástí datových typù jako takových
            
            %Rules - co dìlat když u nìjakého vzorku náhodou nemám tøeba
            %events? Nebo když po nìjakém filtru není co zobrazit?
            
            %Možnost provádìt analýzu by mìla být vlastnost vlastní
            %objektové rodinì pro provádìní analýz na datech,
            
        end
        
        function SetKeyVar(obj,KeyVarNum)
            %
        end
        
        function RunAnalysis(obj)
            %
        end
        
        
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

