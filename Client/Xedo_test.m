path=[cd '\Client\TestingData\XEDO_type\xedo\'];

files=struct2table(dir(path));
files.name=string(files.name);
files.folder=string(files.folder);

files(files.name=="." | files.name=="..",:)=[];
files=files(files.isdir==1,:);

Keys=files.name;

% filelist=WalkDirectory([char(files.folder(1)) '\' char(files.name(1))]);
filelist=WalkDirectory(path);
parts=split(filelist.folder,'\');
types=["smp","evn","cnt"];
type=strings(size(filelist,1),1);
for i=1:size(filelist,1)
    str=lower(filelist.name(i));
    str=replace(str,'.txt','');
    for j=1:numel(types)
       A = contains(str,types(j));
       if A 
           break;
       end
    end
    
    type(i)=types(j);
    
end
T=[table(parts(:,end-2),parts(:,end-1),parts(:,end),type,'VariableNames',{'Key','Box','Slot','Type'}), filelist];




otypes=["evn","cnt","smp"];

for i=1:numel(unqkeys)
    T2=T(T.Key==unqkeys(i),:);
    unqbox=unique(T2.Box);
    for j=1:numel(unqbox)
        T3=T2(T2.Box==unqbox(j),:);
        unqkeys=unique(T3.Key);
        for k=1:numel(unqslots)
            T4=T3(T3.Slot==unqslots(k),:);
            unqslots=unique(T4.Slot);
            for m=1:numel(types)

            end
        end
    end
end
%%
file='C:\Users\Richard\OneDrive - Vysoké učení technické v Brně\Dokumenty\Github\ProjectExplorer\Client\TestingData\XEDO_type\xedo\1\Box_18\Slot_01\Evn_21_03_17_12_16_06_634516.txt';

T=readtable(file);
%%
fileID = fopen(file,'r');
A = fscanf(fileID);
fclose(fileID);
%%
A=readlines(file);
%%
otypes=["evn","cnt","smp"];
sttype=["Události AE jednotky","Count a RMS AE jednotky","Signál AE jednotky"];
parlabels=["Události AE jednotky","Count a RMS AE jednotky","Signál AE jednotky",...
    "formát řádku: ","zesílení g=","maximální rozsah měření adc=","count prahy c1=","c2=","událostní prahy es=","ee=",...
    "mrtvá doba dt=","osciloskop trg=","paměť sm=","pretrigger pt=",...
    "osciloskop perioda pr=","timeout to=","vzorkování rt=","trigger zdroj ts=","master tm=",...
    "interval count ic=","hodnota 'cycle': "];

patterns=lower(parlabels);
desc=struct;
colnames=[];

str="";
for i=1:size(A,1)
    if contains(A(i),'#')
        for j=1:numel(patterns)
            
            if numel(char(str))==0
                str=lower(A(i));
                str=replace(str,"# ","");
                TF = contains(str,patterns(j),'IgnoreCase',true);
            end

            if TF
                str=replace(str,patterns(j),'');
                switch parlabels(j)
                    case "Události AE jednotky"
                        parts=split(str,'.');
                        desc.Box=str2double(parts(1));
                        desc.Slot=str2double(parts(2));
                        str="";
                    case "Count a RMS AE jednotky"
                        parts=split(str,'.');
                        desc.Box=str2double(parts(1));
                        desc.Slot=str2double(parts(2));
                        str="";
                    case "Signál AE jednotky"
                        parts=split(str,'.');
                        desc.Box=str2double(parts(1));
                        desc.Slot=str2double(parts(2));
                        str="";
                    case "formát řádku: "
                        colnames=split(str,',');
                        colnames=replace(colnames,' ','');
                        colnames=lower(colnames);
                    case "zesílení g="
                        num=replace(str,"[db]","");
                        desc.Gain=str2double(num);
                    case "maximální rozsah měření adc="
                        desc.MaxRange=str;
                    case "count prahy c1="
                        desc.Treashold=str;
                        j=j+1;
                    case "c2="
                        desc.TreasholdC2=str;
                    case "událostní prahy es="
                        desc.ETrsh=str;
                    case "ee="
                        desc.EETrsh=str;
                    case "mrtvá doba dt="
                        desc.DeadTime=str;
                    case "osciloskop trg="
                        desc.OscTrsh=str;
                    case "paměť sm="
                        desc.MemorySM=str;
                    case "pretrigger pt="
                        desc.Pretrigger=str;
                    case "osciloskop perioda pr="
                        desc.OscPeriodPr=str;
                    case "timeout to="
                        desc.TimeOut=str;
                    case "vzorkování rt="
                        desc.Sampling=str;
                    case "trigger zdroj ts="
                        desc.TriggerSource=str;
                    case "master tm="
                        desc.MasterTM=str;
                    case "interval count ic="
                        desc.IntervalCount=str;
                    case "hodnota 'cycle': "
                        desc.Cycle=str;
                    otherwise
                end

            end
        end
    else
        break;
    end
end
%%
signal='C:\Users\Richard\Vysoké učení technické v Brně\FYZ_Doktorandi - Dokumenty\General\Pomvěd\Data\16022022\B04_L_MEMS_5_02_000.csv';

T=readtable(signal,'NumHeaderLines',10);

plot(T.Var1,T.Var2);