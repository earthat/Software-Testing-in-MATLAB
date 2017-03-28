close all 
clear all
clc
Tga= load('GA_test_set');
gsa= load('GSA_test_set');
mutepath=[pwd '/' 'sphereFnet' '_mutes'];
a = dir(mutepath);
for i = 3:length(a)-2;  
    filename = a(i).name;
%     load strcat(mutepath, filename);
    temp=regexp(deblank(filename),'\m', 'split');
    temp1=regexp(deblank(temp{2}),'\L', 'split');
    fileID(i-2)=str2num(temp1{1});
end
[actualID,index]=sort(fileID,'ascend');
for i=1:length(actualID)
    filename=a(index(i)+2).name;
    file=regexp(deblank(filename),'\.', 'split');
    relativeError_GA(i) = Fitness_function_SphereFnet(cell2mat(Tga.genetic_test_set.sphereFnet{i}),mutepath,file{1});
    relativeError_GSA(i) = Fitness_function_SphereFnet(cell2mat(gsa.GSA_test_set.sphereFnet{i}),mutepath,file{1});
end



figure
% shiftedstairs(relativeError_GA, relativeError_GSA,'-b')
% set(gca, 'XScale', 'log')
% xlim([10^-3 10^3])
% % hold allsfn_name
% % shiftedstairs(TrndX,TrndY,'-r')
% % shiftedstairs(TcmbX,TcmbY,'-g')
% % title_str = sprintf('Results for %i Mutants', length(TcmbMaxErrs));
% % title(titler)
% xlabel('Detection Boundary  \gamma_d')
% ylabel('Detection Score (%)')
% % legend('T_{Pop}', 'T_{rnd}', 'T_{cmb}')

%%
plot(relativeError_GA(1:5))
figure
plot(relativeError_GSA(1:5),'-or')
grid on
legend('GA','GSA')
disp('Done.')
disp(' ')
