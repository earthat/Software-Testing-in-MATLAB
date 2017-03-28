classdef Genetic_solver_SphereFnet
properties
numberOfVariables
mutantname
end
methods
function testcase = geneticTestFind(numberofVariables,currentmute)
for loop = 1 : 1
%Fitness function
% ObjectiveFunction = @(x)simple_fitness_SphereFnet(x,currentmute);
ObjectiveFunction = @(x)Fitness_function_SphereFnet(x,currentmute);
% Variables number must be given to GA
nvars = numberofVariables;
% Lower bound of input parameters
LB = [eps 1 1 1 1 eps];
% Upper bound of input parameters
UB = [10^7 1000 1000 1000 1000 10^6];
% FitnessLimit, TolFun and StallGenLimit are stopping criteria
% UseParallel is multi threading option
% generations is a stopping criteria
% population size specifies the number of members
% Crossover fraction is set to 0 because it is not useful at all for us.
opts = gaoptimset(' FitnessLimit ',-1,' StallGenLimit ', 100, ' TolFun ',0, 'UseParallel','always','Generations',200,'CrossoverFraction ',0, ' PopulationSize ' ,500);
%Call GA with the options defined.
[x,Fval] = ga(ObjectiveFunction,nvars,[],[],[],[],LB,UB,[],opts);
Fval
all_tests(loop,:) = [x,Fval];
end
% retrieve the test case and return it
[relative_err,index] = min(all_tests(:,numberofVariables + 1));
best_test = all_tests(index,:);
testcase = {best_test(1),best_test(2),best_test(3),best_test(4),best_test(5),best_test(6)};
end
end
end