% This script demonstrates the use of MATmute by running mutation tests on 8
% simple numerical functions.

% The test inputs that are used to test the functions are divided in to two
% classes.  The Popperian (TPop) tests have been carefully selected from sets of
% reasonable inputs in an attempt to push the boundaries of the functions under
% test.  The pseudo-random (Trnd) tests have been randomly selected from the
% same sets of reasonable inputs that the Popperian tests were drawn from.
% Both sets of tests have been combined into the combined (Tcmb) test set.

% Files used by this script:
%   -binSearch.m
%   -gaussQuad.m
%   -GEPiv.m
%   -nwtsqrt.m
%   -odeRK4.m
%   -powerit.m
%   -shiftedstairs.m (used for plotting)
%   -simpson.m
%   -sphereCd.dat
%   -sphereFnet.m
%   -tests.mat


% CLEAR WORKSPACE
% If workspace is not cleared, old data may be mixed with new results.
reply = input('Workspace will be cleared, is that ok? (y/n): ', 's');
disp(' ')

if reply == 'y'
    clear all;
else
    disp('Workspace cannot be cleared: cancelling execution.')
    return;
end


% USER CONFIGURATION
% Check if MATmute should be run verbosely.
reply = input('Do you want routines to execute in verbose mode? (y/n): ', 's');
disp(' ')
    
if reply == 'y'
    verbose = true;
else
    verbose = false;
end

% Get list of mutation operators to use.
disp('Currently the default mutation operators are ''sdl'', ''crp'', ''neg'', and ''orp''.')
disp('The ''asp'' operator can also be used.')
operators = input('Specify the mutation operators that should be used or press return for the default set:\n', 's');
disp(' ')

% Get list of functions to use.
disp('By default all 8 functions are tested.')
functions = input('Specify the functions that should be tested or press return for the default set:\n', 's');
disp(' ')


% LOADING THE TESTS
% The tests.mat file must be in the active directory to carry out this step.
disp('Loading sets of tests into TPop and Trnd structs.')
disp(' ')
load genetic_test_set.mat
load GSA_test_set.mat
TPop=GSA_test_set;
Trnd=genetic_test_set;
% Remove fields from test struct that are not listed in string given by user.
if ~isempty(functions)
    functions = regexp(functions, '\s', 'split');
    TPop = rmfield(TPop, setxor(functions, fieldnames(TPop)));
    Trnd = rmfield(Trnd, setxor(functions, fieldnames(Trnd)));
end


% GENERATING AND EXECUTING THE MUTANTS
% Use matmute routine to generate, execute, and evaluate the mutants.
disp('Generating and executing mutants.  Note that some mutants may take a')
disp('long time to execute.')
disp('Error scores are stored in TPopErrs and TrndErrs structs.')
%%    
% Run Popperian tests.
for fn = fieldnames(TPop)'
    if strcmp(fn,'index')
        break
    end
    disp(' ')
    fprintf('Executing %i Popperian tests on mutants of %s.\n', length(TPop.(fn{:})), fn{:})
    [TPopErrs.(fn{:}) TPopTime.(fn{:})] = matmute(fn{:}, TPop.(fn{:}), 1, operators, verbose);
end

% Run pseudo-random tests.
for fn = fieldnames(Trnd)'
    disp(' ')
    fprintf('Executing %i pseudo-random tests on mutants of %s.\n', length(Trnd.(fn{:})), fn{:})
    [TrndErrs.(fn{:}) TrndTime.(fn{:})] = matmute(fn{:}, Trnd.(fn{:}), 1, operators, verbose);
end
disp(' ')
% Concatenate results from Popperian and pseudo-random tests to form the set of
% Tcmb results.
disp('Assembling scores for Tcmb in the TcmbErrs struct.')
disp(' ')
for fn = fieldnames(TPop)'
    TcmbErrs.(fn{:}) = [TPopErrs.(fn{:}) TrndErrs.(fn{:})];
end
% CLEAN UP THE DATA
% Keep only those mutants that do not fail on all tests and which are revealed.
disp('Forming clean data sets in the TPopErrsClean, TrndErrsClean, and TcmbErrsClean structs.')
disp(' ')
for fn = fieldnames(TPopErrs)'
    TPopErrsClean.(fn{:}) = TPopErrs.(fn{:})( ~all(TcmbErrs.(fn{:})==Inf, 2) & ~all(TcmbErrs.(fn{:})==0, 2), : );
end

for fn = fieldnames(TrndErrs)'
    TrndErrsClean.(fn{:}) = TrndErrs.(fn{:})( ~all(TcmbErrs.(fn{:})==Inf, 2) & ~all(TcmbErrs.(fn{:})==0, 2), : );
end



% FORM RESULT MATRIX
disp('Building result matrices.  See TPopResults, TrndResults, and TcmbResults.')
disp(' ')

% Start by determining the number of rows and columns needed in each result
% matrix.
rows = 0;
Popcols = 0;
rndcols = 0;
for fn = fieldnames(TPopErrsClean)'
    rows = rows + size(TPopErrsClean.(fn{:}), 1);
    Popcols = Popcols + size(TPopErrsClean.(fn{:}), 2);
    rndcols = rndcols + size(TrndErrsClean.(fn{:}), 2);
end
cmbcols = Popcols + rndcols;

% Construct a matrix filled with -1 for each test set.  (-1 is used to indicate
% that no test was conducted for that position.)
TPopResults = -ones(rows, Popcols);
TrndResults = -ones(rows, rndcols);


% Fill values into result matrices.
rpos = 1;
cpos = 1;
for fn = fieldnames(TPopErrsClean)'
    [r c] = size(TPopErrsClean.(fn{:}));
    TPopResults(rpos:rpos+r-1, cpos:cpos+c-1) = TPopErrsClean.(fn{:});
    rpos = rpos + r;
    cpos = cpos + c;
end
rpos = 1;
cpos = 1;
for fn = fieldnames(TrndErrsClean)'
    [r c] = size(TrndErrsClean.(fn{:}));
    TrndResults(rpos:rpos+r-1, cpos:cpos+c-1) = TrndErrsClean.(fn{:});
    rpos = rpos + r;
    cpos = cpos + c;
end



% GET MAXIMUM OBSERVED ERRORS
% For each revealed, viable (i.e., clean) mutant, get the maximum observed error.
disp('Forming lists of maximum observed error for each mutant on a given test set:')
disp('results saved in TPopMaxErrs, TrndMaxErrs, and TcmbMaxErrs structs.')
disp(' ')
TPopMaxErrs = max(TPopResults, [], 2);
TrndMaxErrs = max(TrndResults, [], 2);



% GENERATE DETECTION SCORE GRAPH
disp('Plotting detection scores for each test set at various detection boundaries.')
disp(' ')

% Get x-axis (gamma_d) values.
TPopX = unique(TPopMaxErrs);
TrndX = unique(TrndMaxErrs);


% Get y-axis (detection score) values.
TPopY = zeros(size(TPopX));
TrndY = zeros(size(TrndX));

for n = 1:length(TPopX)
    TPopY(n) = 100*sum(TPopMaxErrs>=TPopX(n))/length(TPopMaxErrs);
end
for n = 1:length(TrndX)
    TrndY(n) = 100*sum(TrndMaxErrs>=TrndX(n))/length(TrndMaxErrs);
end
%%

% Plot the detection score plots.
figure
shiftedstairs(TPopX,TPopY,'-b')
set(gca, 'XScale', 'log')
xlim([10^-3 10^3])
hold all
shiftedstairs(TrndX,TrndY,'-r')
% shiftedstairs(TcmbX,TcmbY,'-g')
title_str = sprintf('Results for 87 Mutants of Rastrigin Function');
title(title_str)
xlabel('Detection Boundary  \gamma_d')
ylabel('Detection Score (%)')
legend('GSA', 'GA')

disp('Done.')
disp(' ')
