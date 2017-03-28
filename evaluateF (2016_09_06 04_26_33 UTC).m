% GSA code v1.1.
% Generated by Esmat Rashedi, 2010. 
% " E. Rashedi, H. Nezamabadi-pour and S. Saryazdi,
%�GSA: A Gravitational Search Algorithm�, Information sciences, vol. 179,
%no. 13, pp. 2232-2248, 2009."
%
%This function Evaluates the agents. 
function   fitness=evaluateF(X,mutepath,currentmute)

[N,dim]=size(X);
for i=1:N 
    %L is the location of agent number 'i'
    L=X(i,:); 
    %calculation of objective function for agent number 'i'
%     fitness(i)=test_functions(L,ObjectiveFunction,dim);
    fitness(i)=Fitness_function_SphereFnet(L,mutepath,currentmute);
end