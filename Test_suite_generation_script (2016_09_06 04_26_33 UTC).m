function [genetic_test_set] = Test_suite_generation_script(fn_name, no_variables)
loop_timing_factor = 100;
fail_on_bad_loop = true;

% used for loop monitoring
global MUTE_ticks MUTE_ticklimit MUTE_testcnt
global MutantName

% If function's mutant directory exists then erase it's contents so that
% the new mutants will not be mixed with old mutants.
if isdir([pwd '/' fn_name '_mutes'])
   rmdir([fn_name '_mutes'], 's')
end
initdir = pwd; % store the current directory
initpath = path; % store current path so it can be restored
initwarning = warning('query', 'all');

% Generate the call string which calls the mutator.
callstring = ['C:\Python34\python.exe -m matmute ' fn_name];

% If fail_on_bad_loop is true then append "--inferr" flag to call string.
if fail_on_bad_loop
   callstring = [callstring ' --inferr'];
end

% Call the mutator using the callstring.
[status output] = system([callstring]);

% Check if the mutator reported any errors.
if status == 0
   disp('Creation of mutants complete.')
else
disp(output);
error('Mutator encountered a problem when creating the mutants. See error message above.')
end

% Parse the mutant IDs from the mutator's output string.
mute_ids = regexp(deblank(output), '\n', 'split');
% If empty string is returned as the mutant IDs then quit.
if isempty(mute_ids)
    error('No mutants created. Perhaps you should try different mutation operators?')
else
fprintf('Tests will be executed on %i mutants.\n', length(mute_ids))
end

% Add the current directory to the path (so that any functions in this
% directory are still accessible).
path(initdir, path);
% Change to the directory where the mutants are stored.
% cd([fn_name '_mutes']);

% Use try-catch to ensure that MATLAB returns to the original directory.
% try
    % MUTE_testcnt counts the number of tests that have been executed on
% each mutant. It is used by the mutated files to determine which
% ticklimit corresponds to each test, and must be reset every time a new
% mutant is being analysed.
MUTE_testcnt = 0;
% Execute tests on the unmutated function and compare the results with
% the results from original function.
% Use results from the instrumented version to set loop iteration limits.
% (+1 ensures that ticklimit is nonzero.)
MUTE_ticklimit = (MUTE_ticks+1)*loop_timing_factor;
%genetic_test_set = zeros(length(mute_ids), 1);
count = 1;

%To get initial population for genetic algorithm
%initialPop = Convert_cellarray_to_array();
% Loop through all the mutants.
hh=waitbar(0,'processing...');

for m = 1:length(mute_ids)
MUTE_testcnt = 0; % as above, MUTE_testcnt must be reset
% Turn off warnings (except desired mutant warnings) while
% running mutants.
warning('off', 'all')
warning('on', 'mutant:TickLimitExpired')
warning('on', 'get_error:RelErrDivByZero')
warning('on', 'get_error:NaN')
warning('on', 'get_error:Inf')
% try
%create object for genetic solver and call the function
%genetic test find.
geneticTestObject = Genetic_solver_SphereFnet;
geneticTestObject.mutantname = mute_ids{m};
mutepath=[pwd '/' fn_name '_mutes'];
% Genetic_test_case =geneticTestObject.geneticTestFind(no_variables,mute_ids{m});
[Genetic_test_case,index] =GSATestFind(no_variables,mutepath,mute_ids{m});

%save the test case in a format such that it can be used in
%MATmute
genetic_test_set.sphereFnet{count,1} = Genetic_test_case;
genetic_test_set.index(count)=index;
count = count + 1;
% m
% catch ME
% s = ME.stack(1);
% end

% Turn warnings back on.
warning(initwarning)
hh=waitbar(m/(length(mute_ids)),hh,['Mutant: ',num2str(m)]);

end
close(hh)
% catch ME
%     % Return to main directory, reset variables and pass error along.
% cd(initdir);
% path(initpath);
% warning(initwarning)
% clear global MUTE_ticks MUTE_ticklimit MUTE_testcnt
% rethrow(ME)
% end

% Change back to the original directory and remove addition to the path.
cd(initdir);
path(initpath);
%Reset global variables.
clear global MUTE_ticks MUTE_ticklimit MUTE_testcnt
% Display success message.
disp('Tests finished executing.')
end