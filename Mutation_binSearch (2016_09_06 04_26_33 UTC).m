function mutationChildren = Mutation_binSearch(parents ,options,NVARS, ...
FitnessFcn, state, thisScore,thisPopulation,mutationRate)
% MUTATE_PERMUTATION Custom mutation function for traveling salesman.
% MUTATIONCHILDREN = MUTATE_PERMUTATION(PARENTS,OPTIONS,NVARS, ...
% FITNESSFCN,STATE,THISSCORE,THISPOPULATION,MUTATIONRATE) mutate the
% PARENTS to produce mutated children MUTATIONCHILDREN.
%
% The arguments to the function are
% PARENTS: Parents chosen by the selection function
% OPTIONS: Options structure created from GAOPTIMSET
% NVARS: Number of variables
% FITNESSFCN: Fitness function
% STATE: State structure used by the GA solver
% THISSCORE: Vector of scores of the current population
% THISPOPULATION: Matrix of individuals in the current population
% In this function extra element is added to the list,
mutationChildren = cell(length(parents),2);
for i=1:length(parents)
getArray = thisPopulation{parents(i)};
arraySize = size(getArray,2);
MuteType = randi([1 2]);
if arraySize < 25
getArray(arraySize + 1) = randi([-10.^10 10.^10]);
end
mutationChildren{i} = sort(getArray);
mutationChildren{i,2} = getArray(randi([1 size(getArray,2)]));
end