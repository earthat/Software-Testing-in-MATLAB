function pop = Population_Creation(NVARS,FitnessFcn,options)
%CREATE_PERMUTATIONS Creates a population of permutations.
% POP = CREATE_PERMUTATION(NVARS,FITNESSFCN,OPTIONS) creates a population
% of permutations POP each with a length of NVARS.
%
% The arguments to the function are
% NVARS: Number of variables
% FITNESSFCN: Fitness function
% OPTIONS: Options structure used by the GA
totalPopulationSize = sum(options.PopulationSize);
n = NVARS;
pop = cell(totalPopulationSize,2);
arraySizeIncrementor = 1;
ValueIncrementor = 1;
for i = 1:totalPopulationSize
if arraySizeIncrementor > 25
arraySizeIncrementor = 1;
end
if ValueIncrementor > 10
    ValueIncrementor = 1;
end
pop{i} = sort(randi([-10.^ValueIncrementor 10.^ValueIncrementor],1, arraySizeIncrementor));
pop{i,2} = pop{i}(randi([1 size(pop{i},2)]));
arraySizeIncrementor = arraySizeIncrementor + 1;
ValueIncrementor = ValueIncrementor + 1;
end