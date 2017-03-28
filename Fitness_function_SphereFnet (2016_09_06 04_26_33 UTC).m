function relativeError = Fitness_function_SphereFnet(x,mutepath,mutant)
global MUTE_testcnt sel;
%Initialize variables
actualValue = cell(1, 1);
muteValue = cell(1, 1);
%Calculate actual value
actualValue{1} = sphereFnet(x);
try
handle = str2func(mutant);
%Calculate mutant output
cd (mutepath)
muteValue{1} = feval(handle,x);

catch ME
s = ME.stack(1);
muteValue{1} = sprintf('_MUTE_err caught originating from line %d of "%s":\n%s', s.line, s.name,ME.message);
end
cd C:\Users\THE\Documents\MATLAB\deepaphd\220816
MUTE_testcnt = 0 ;
%find relative error
relativeError = max(get_error(actualValue,muteValue));
% Genetic algorithm in matlab tries to find the smallest value,
% But we need maximum relative error. So the sign is changed.
if sel==1
relativeError = -relativeError;

end
end