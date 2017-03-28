function [testcase,index] = GSATestFind(numberofVariables,mutepath,currentmute)
for loop = 1 : 1
%Fitness function
% ObjectiveFunction = @(x)simple_fitness_SphereFnet(x,currentmute);
ObjectiveFunction = @(x)Fitness_function_SphereFnet(x,mutepath,currentmute);
% Variables number must be given to GA
nvars = numberofVariables;
% Lower bound of input parameters
LB = [-2.048];
% Upper bound of input parameters
UB = [2.048];
% FitnessLimit, TolFun and StallGenLimit are stopping criteria
% UseParallel is multi threading option
% generations is a stopping criteria
% population size specifies the number of members
% Crossover fraction is set to 0 because it is not useful at all for us.
% opts = gaoptimset(' FitnessLimit ',-1,' StallGenLimit ', 100, ' TolFun ',0, 'UseParallel','always','Generations',200,'CrossoverFraction ',0, ' PopulationSize ' ,500);
%Call GA with the options defined.
% opts=gaoptimset('Display','iter');
[Fval,x,BestChart,MeanChart] = GSA(mutepath,currentmute,nvars,LB,UB);
% Fval
all_tests(loop,:) = [x,Fval];
end
plot(BestChart)
% retrieve the test case and return it
[relative_err,index] = min(all_tests(:,numberofVariables + 1));

best_test = all_tests(index,:);
testcase = {best_test};
end