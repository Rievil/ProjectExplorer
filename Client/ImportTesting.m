
filenames={};

filenames=[filenames; 'D:\ZEDO_DATA_Export\190913_Melichar\FCH_28_5\fch_28_5.65.1a-ae-parameters.txt'];
opts = detectImportOptions(filenames{1});
T = readtable(filenames{1},opts);

names=replace(opts.VariableNames,'_','');
T.Properties.VariableNames=names;
