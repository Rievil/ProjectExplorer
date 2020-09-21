
%% Testing of categorical arrays and their sorting
A=["Name";"DateTime";"Number";"Name";
   "DateTime";"DateTime";"Name";"Category"];

 ColNames=categorical(A,'ordinal',true);
     
 B=sort(ColNames)
 %%
 B=DataFrame.MTBlueprint
 %%
all_files = dir('K:\ZEDO_DATA_Export\190913_Melichar\');
all_dir = all_files([all_files(:).isdir]);
all_dir(1:2)=[];
%%
folders=OperLib.DirFolder('K:\ZEDO_DATA_Export\190913_Melichar');