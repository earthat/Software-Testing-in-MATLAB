% Provides an interface to the MATmute mutation testing system.
%
% Syntax:
%
%	[errors time mutant_outputs original_outputs] = matmute('fn_name', {TEST1, TEST2, ..., TESTN}, noutarg, 'op1 op2 ...', verbose)
%
%
% Terminology:
%	mutation: a change to the code of a program statement
%
%	mutation operator: a function which generates mutations of a statement in a 
%			well-defined way
%
%	mutation target: the program (.m file) which is to be mutated
%
%	mutant: a program which differs from the mutation target by one mutation
%
%	mutant ID: mutants are sequentially numbered as they are created, this
%			number is the mutant's ID
%
%	relative error: given a quantity q and its expected value q0, the relative
%			error er of the quantity is given by
%					er = |q - q0|/|q0|
%
%
% Description:
%	This function generates mutations of MATLAB .m files, executes these
%	mutants using given inputs (i.e., tests), and compares the results with the
%	results from the execution of the non-mutated file to determine the relative
%	error in the result of each test.
%
%	WARNING: Care should be taken when running the matmute command on .m file
%	programs which include code that can have permanent effects on the file
%	system or configuration of a computer.  This is because program mutations
%	can behave in strange and unexpected ways.  For example, a program which
%	normally overwrites a certain file, might overwrite a completely different
%	file when mutated.  The mutator will never introduce new code that
%	modifies files or configurations so it is safe to use with .m files that do
%	not currently exhibit any behaviour of that kind.
%
%	[errors mute_outs orig_outs time] = matmute('fn_name', {TEST1, TEST2, ..., TESTN}, noutarg)
%	generates mutants of function 'fn_name' and uses the input arguments given
%	in {TEST1, TEST2, ..., TESTN} to run the mutants. Each test is a cell array
%	containing a valid set of inputs for the target function.  The function and
%	mutants are asked to produce the number of outputs specified by the integer
%	noutarg.
%
%	Because TEST1, TEST2, ..., TESTN are themselves cell arrays, it is important
%	to understand that the second argument to matmute will be a nested cell
%	array.
%
%	The outputs for mutant M when run using test N can be found in position
%	(M,N) of the mute_outs cell array and the relative error of each test-mutant
%	pair can be found in the (m,n) position of the error matrix.  The outputs
%	of the original function on each test are found in the orig_outs cell array.
%	The time taken relative to the unmutated function is stored in time (note
%	that this is calculated as the mutant time divided by the original time).
%
%	Note that an error score of Inf means that execution aborted or that the
%	mutant output could not be compared with the target output.  A negative
%	time score means that execution aborted after a relative time equal to the
%	absolute value of the time score.
%
%	'op1 op2 ...' is an optional space delimited list of the mutation operators
%	which are to be used to create the mutants.  If this argument is not given
%	then the default operators as defined in ops_config.py will be used.  For
%	details about the operators see the Implementation section in this header
%	or examine the operators.py file.  The following operators are currently
%	implemented and can be selected with their 3-letter ID:
%
%			crp: constant replacement
%			neg: branch expression negation
%			orp: operator replacement
%			sdl: statement deletion
%			asp: assignment perturbation
%
%	The operatores will be applied to each statement in the order which they
%	are given.
%
%	If the verbose flag is set to true then text will be printed listing the
%	current test and mutant that are running.
%
%
% Remarks:
%	The computer must be set up to use MATmute.  See INSTALL.txt in the MATmute
%	package for instructions.
%
%	The mutation target 'fn_name' must be in the current working directory.  A
%	folder named 'fn_name'_mutes will be created in this directory during
%	execution.  This folder will not be deleted when the mutation testing is
%	completed (although the mutator will overwrite its contents on each run)
%	and must be manually deleted when no longer needed.  Therefore, it is
%	suggested that a copy of the mutation target .m file is moved to a
%	designated directory before running MATmute on it.  (Don't forget that
%	MATmute must be called from this directory.)
%
%	During the mutation process an unmutated but reformatted and instrumented
%	file is created and named "unmutated.m".  The program in this file should
%	be functionally equivalent to the mutation target, but its contents are
%	different for two reasons.  Firstly, the mutator requires that the target
%	code be reformatted so that each line of text contains exactly one
%	statement.  Comments (except for mutation control comments) are also
%	removed in the reformatting process.  Secondly, the code is instrumented
%	with loop monitoring code to count and store the number of times that each
%	loop executes.  This is used to kill mutants in which infinite loops may
%	have been introduced.
%
%	The results from the unmutated code are compared with the results
%	from the mutation target in order to confirm that the reformatting and
%	instrumentation steps haven't affected the behaviour of the program.  If
%	the outputs from the mutation target depends on timing this test may fail.
%	It may also be possible to write MATLAB code in such a way that the
%	reformattting step misbehaves and forms code which is not equivalent.
%	There are currently no known instances of this kind of misbehaviour, but
%	the parser is not been strongly verified and may make mistakes.
%
%	When calling the matmute function it is important to understand that the
%	function's behaviour may be effected by the number of output arguments that
%	are requested.  Some functions behave differently when called with
%	different numbers of storage arguments, and when dealing with these kinds
%	of functions it is important to ensure that the right number of outputs
%	are being requested in order to elicit the desired behaviour of the
%	mutation target.
%
%	Unless an attempt is being made to elicit some specific behaviour from the
%	mutation target (as discussed in the previous paragraph), it is usually
%	best to request as many outputs as possible.  More outputs will give
%	the mutator more data to examine for noticeable errors.
%
%
% Implementation:
%	Mutations are created by applying mutation operators to each statement
%	in the mutation target's .m file.
%
%	The statements are fed, one at a time and in sequential order, to the
%	mutation operators.  Each operator returns a list of mutations of the given
%	input statement, and this list is appended to the existing list of
%	mutations which has been formed by the operators that have already run on
%	that statement.  The operators execute in the default order defined in
%	ops_config.py unless the user has specified the mutation operators which
%	are to be used.
%
%	To generate the mutant programs the mutator loops through the statements
%	of the mutation target.  For each mutation (generated by the mutation
%	operators) of some statement S the mutator generates an .m file where S
%	has been replaced by that mutation.  The mutation in a mutant file (i.e.,
%	the one change in the code) falls into one of any four types (each mutation
%	operator is responsible for one type of mutant):
%
%		sdl: a statement is deleted (or commented out)
%		neg: a branch condition is negated (forcing the opposite decision)
%		crp: hard-coded constants (i.e., digits) in the code are modified
%			(e.g., value is incremented by one)
%		orp: operators are replaced by another operator from the same class
%			(e.g., '+' -> '*', '&' -> '|', or '<' -> '==')
%		asp: a string is prepended to the bracketed right-hand side of an
%			assignment statement (e.g., the right-hand side is multiplied
%			by a constant)
%			
%
%	For a full understanding of the mutation operators effects see the
%	operators.py file which is part of the MATmute package.  New operators can
%	be added by modifying operators.py and the behaviour of existing operators
%	can be modified by modifying operators.py or ops_config.py.  The parameters
%	in the ops_config.py affect the behaviour of some of the operators and are
%	intended to allow easy customization of the behaviour of some operators.
%
%	Further details about the implementation of the mutator can be determined
%	by examining the code in the .py files in the MATmute package.
%
% Copyright 2008 Daniel Hook (dan_hook@users.sourceforge.net)
%
%  This file is part of MATmute.
%
%  MATmute is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  MATmute is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with MATmute.  If not, see <http://www.gnu.org/licenses/>.

function [errors time mute_outputs original_results] = matmute(fn_name, inarg, noutarg, op_list, verbose)

    % Given timing factor F and unmutated loop iterations I, if a mutant's
    % loops use more than F*I iterations then the action specified by the
    % fail_on_bad_loop flag (see below) will be taken.
    loop_timing_factor = 100;
    
    % If fail_on_bad_loop is set to true then loops which exceed the tick
    % limit will be fail with an error.  Otherwise, the loop will be exited
    % but the program will execute until completion.
    fail_on_bad_loop = true;

    % Required declarations for running the mutations.
    global MUTE_ticks MUTE_ticklimit MUTE_testcnt % used for loop monitoring
    
    % Create output storage cell.  This is used whenever calling a function
    % with the number of storage arguments given in noutarg.
    out = cell(1, noutarg);
    

    % Check for input errors.
    if nargin < 3
        error('At least three input arguments are required.')
    elseif ~ischar(fn_name)
        error('First input argument must be a string.')
    elseif ~iscell(inarg)
        error('Second input argument must be a cell array.')
    elseif ~isnumeric(noutarg)
        error('Third input argument should be a whole number.')
    end
    
    % If op_list not given then set it as empty (for default behaviour).
    if nargin < 4
        op_list = [];
    end
    
    % If verbose flag not given then set to false.
    if nargin < 5
        verbose = false;
    end
    
    
    % If function's mutant directory exists then erase it's contents so that
    % the new mutants will not be mixed with old mutants.
    if isdir([pwd '/' fn_name '_mutes'])
        rmdir([fn_name '_mutes'], 's')
    end
    
    % All functions in memory are cleared before starting, this avaoids
    % problems related to using old versions of files that are still stored
    % in memory.
    clear functions
    
    initdir = pwd; % store the current directory
    initpath = path; % store current path so it can be restored
    initwarning = warning('query', 'all');
    
    
    % Generate the call string which calls the mutator.
    callstring = ['C:\Python34\python.exe -m matmute ' fn_name];
    
    % If operators selected then append the active operator list.
    if ~isempty(op_list)
        callstring = [callstring ' -o "' op_list '"'];
    end
    
    % If fail_on_bad_loop is true then append "--inferr" flag to call string.
    if fail_on_bad_loop
        callstring = [callstring ' --inferr'];
    end

    % Call the mutator using the callstring.
    [status output] = system(callstring);
        
    % Check if the mutator reported any errors.
    if status == 0
        disp('Creation of mutants complete.')
    else
        disp(output);
        error('Mutator encountered a problem when creating the mutants.  See error message above.')
    end
    
    % Parse the mutant IDs from the mutator's output string.
    mute_ids = regexp(deblank(output), '\n', 'split');
    
    % If empty string is returned as the mutant IDs then quit.
    if isempty(mute_ids)
        error('No mutants created.  Perhaps you should try different mutation operators?')
    else
        fprintf('Tests will be executed on %i mutants.\n', length(mute_ids))
    end
    
    
    % Pre-allocate variables for mutation results and analysis.
    original_results = cell(length(inarg), 1);
    unmute_time  = zeros(length(inarg), 1);
    errors = zeros(length(mute_ids), length(inarg) );
    time = zeros(length(mute_ids), length(inarg) );
    mute_outputs = cell( length(mute_ids), length(inarg) );

    % Execute tests on the original version of the function and store results.
    for n = 1:length(inarg)
        if verbose
            fprintf('Running test %i on original function.\n', n)
        end
        
        try
            [out{:}] = feval(fn_name, cell2mat(inarg{n}));
            original_results{n} = out;
        catch causeME
            baseME = addCause(MException('matmute:badtest', 'Test %i did not run on the original function.\n', n), causeME);
            throw(baseME)
        end
    end
    
    
    % Add the current directory to the path (so that any functions in this
    % directory are still accessible).
    path(initdir, path);
    
    % Change to the directory where the mutants are stored.
    cd([fn_name '_mutes']);
    
    % Use try-catch to ensure that MATLAB returns to the original directory.
    try
    
        % MUTE_testcnt counts the number of tests that have been executed on
        % each mutant.  It is used by the mutated files to determine which
        % ticklimit corresponds to each test, and must be reset every time a new
        % mutant is being analysed.
        MUTE_testcnt = 0;
        
        % Execute tests on the unmutated function and compare the results with
        % the results from original function.
        for n = 1:length(inarg)
            if verbose
                fprintf('Running test %i on instrumented function.\n', n)
            end
            tic; % reset timer
            [out{:}] = feval('unmutated', cell2mat(inarg{n}));
            unmute_time(n) = toc;
            if ~isequalwithequalnans(original_results{n}, out)
                error('Mutator fault: instrumented (but unmutated) version gives different results than the original version.')
            end
        end
    
        % Use results from the instrumented version to set loop iteration limits.
        % (+1 ensures that ticklimit is nonzero.)
        MUTE_ticklimit = (MUTE_ticks+1)*loop_timing_factor;
        
    
        % Loop through all the mutants.
        for m = 1:length(mute_ids)
        
            MUTE_testcnt = 0; % as above, MUTE_testcnt must be reset
    
            % Turn off warnings (except desired mutant warnings) while
            % running mutants.
            warning('off', 'all')
            warning('on', 'mutant:TickLimitExpired')
            warning('on', 'get_error:RelErrDivByZero')
            warning('on', 'get_error:NaN')
            warning('on', 'get_error:Inf')
            
            % Begin execution of the mutants using the tests in inarg.
            for n = 1:length(inarg)
                
                if verbose
                    fprintf('Running test %i on mutant %i.\n', n, m)
                end
                
                try
                    tic; % reset timer
                    [out{:}] = feval(mute_ids{m}, cell2mat(inarg{n}));
                    mute_time = toc; % get execution time
                % If error caught then store message and location.
                catch ME
                    s = ME.stack(1);
                    for k = 1:noutarg
                        out{k} = sprintf('_MUTE_err caught originating from line %d of "%s":\n%s', s.line, s.name, ME.message);
                    end
                    mute_time = -toc; % (-) indicates error time
                end
                
                mute_outputs{m,n} = out;
                errors(m,n) = max(get_error(original_results{n}, out));
                time(m,n) = mute_time/unmute_time(n);
            end
            
            % Turn warnings back on.
            warning(initwarning)
            
        end
        
    
    catch ME
        
        % Return to main directory, reset variables and pass error along.
        cd(initdir);
        path(initpath);
        warning(initwarning)
        clear global MUTE_ticks MUTE_ticklimit MUTE_testcnt
        rethrow(ME)
        
    end
    
    % Change back to the original directory and remove addition to the path.
    cd(initdir);
    path(initpath);
    
    % Reset global variables.
    clear global MUTE_ticks MUTE_ticklimit MUTE_testcnt
    
    % Display success message.
    disp('Tests finished executing.')
   
end
