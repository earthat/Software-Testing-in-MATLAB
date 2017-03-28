function relativeError = Fitness_function_nwtsqrt(x,mutepath,mutant)
global MUTE_testcnt;
%Initialize variables
actualValue = cell(1, 1);
muteValue = cell(1, 1);
%Calculate actual value
actualValue{1} = nwtsqrt(x(:,1),x(:,2));
% try
handle = str2func(mutant);
%Calculate mutant output
cd (mutepath)
muteValue{1} = feval(handle,x(:,1),x(:,2));
cd C:\Users\SAHWAL\Documents\MATLAB\matlab
% catch ME
% s = ME.stack(1);
% muteValue{1} = sprintf('_MUTE_err caught originating from line %d of "%s":\n%s', s.line, s.name,ME.message);
% end
MUTE_testcnt = 0 ;
%find relative error
relativeError = max(get_error(actualValue,muteValue));
% Genetic algorithm in matlab tries to find the smallest value,
% But we need maximum relative error. So the sign is changed.
relativeError = -relativeError;
end