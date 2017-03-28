close all
clear all
global sel
sel=2;
[GSA_test_set]=Test_suite_generation_script('sphereFnet',6);
save GSA_test_set GSA_test_set
%%
clear sel
sel=2;
[genetic_test_set]=Test_suite_generation_script_GA('sphereFnet',6);
save genetic_test_set genetic_test_set
