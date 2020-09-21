
%% Testing of categorical arrays and their sorting
A=["Name";"DateTime";"Number";"Name";
   "DateTime";"DateTime";"Name";"Category"];

 ColNames=categorical(A,'ordinal',true);
     
 B=sort(ColNames)
 %%
 B=DataFrame.MTBlueprint
 %%
  ColNames=categorical(["StrName","DateTime","Number","Category"],{'StrName','DateTime','Number','Category'},'ordinal',true);