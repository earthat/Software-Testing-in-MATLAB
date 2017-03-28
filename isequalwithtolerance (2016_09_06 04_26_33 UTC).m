% Checks for equality within relative and/or absoulte bounds.
%
% If input is a matrix of floats or doubles then this method checks to see if
% the  second input is approximately equal to the first within a given relative
% (i.e., fractional) and/or absolute tolerance.  If the inputs are cell arrays
% or structs then they will be recursively explored for equality.  If the
% inputs are anything else then they will be checked for strict equality.
%
% If both relative and absolute tolerances are given, then the 2nd input will
% only be considered equal to the 1st if both the relative and absolute
% equality tests are passed.
%
% Inputs:
% - an object (usually the "correct" value)
% - an object (to be checked against the "correct" value
% - a fractional (i.e., relative) tolerance (*)
% - an absolute tolerance (optional)
% (*) If only absolute tolerance is to be used then set 3rd argument to Inf.
%
% Outputs:
% - true if values considered to be equal, false otherwise
%
% Relative Equality:
%   A floating point number y is considered to be equal to a floating point
%   number x  within fractional tolerance f if
%
%    	|Re(x) - Re(y)| <= f*|Re(x)|   and   |Im(x) - Im(y)| <= f*|Im(x)|
%
%   where Re(q) and Im(q) denote the real and imaginary parts of a number q.
%
% Absolute Equality:
%   A floating point number y is considered to be equal to a floating point
%   number x  within absolute tolerance a if
%
%		|Re(x) - Re(y)| <= a   and   |Im(x) - Im(y)| <= a
%
%   where Re(q) and Im(q) denote the real and imaginary parts of a number q.
%
% This function is used by the MATmute mutation testing system to asses the
% equality of two inputs in order to determine which mutants survive a test or
% set of tests.
%
% The behaviour of this function is different than the MATLAB isequal()
% function which only checks for strict equality.  Other differences between
% this method and isequal() include the following:
% - NaNs are treated as being equal (like isequalwithequalnans()).
% - A warning is issued when comparing a logical value with a numeric
% value or an integer value with a floating-point value.
%
% When evaluating a test -- i.e., comparing an expected result with a generated
% result -- the expected result should be the first input so that it is used
% to determine the bound on relative equality.
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

function result = isequalwithtolerance(original, mutated, rel_tol, abs_tol)

    % Check that inputs are valid.
    if nargin < 3
        error('At least three inputs required.')
    elseif ~isnumeric(rel_tol)
        error('3rd argument must be numeric.')
    elseif nargin > 3 && ~isnumeric(abs_tol)
        error('4th argument must be numeric.')
    end
    
    % If 4th argument is not given then set absolute tolerance to infinite.
    % (Therefore, only relative equality test matters.)
    if nargin < 4
        abs_tol = Inf;
    end

    % If lengths of size() outputs are different then the number of dimensions
    % must be different so fail.
    if length(size(original)) ~= length(size(mutated))
        result = false;
        return
    end

    % If sizes are different then fail.
    if ~isequal(size(original), size(mutated))
        result = false;
        return
    end

    % Turn multidimensional data structures into vectors to make them easier to
    % handle.
    original = original(:);
    mutated = mutated(:);
    
    % The following tests are for numeric variables.
    if isnumeric(original) && isnumeric(mutated)
    
        % If both are integers then check strict equality.
        if isinteger(original) && isinteger(mutated)
            result = all(original == mutated);
            return
        end
    
        % If one is real and one is imaginary then fail.
        if isreal(original) ~= isreal(mutated)
            result = false;
            return
        end

        % If positions of NaNs do not agree then fail.  Otherwise zero-out the
        % NaNs so they do not taint later results.
        if any(isnan(original) ~= isnan(mutated))
            result = false;
            return
        else
            original(isnan(original)) = 0;
            mutated(isnan(mutated)) = 0;
        end
        
        % If positions of Infs do not agree then fail.  Otherwise zero-out the
        % Infs so they do not taint later results.
        if any(isinf(original) ~= isinf(mutated))
            result = false;
            return
        else
            original(isinf(original)) = 0;
            mutated(isinf(mutated)) = 0;
        end

        % If numerical types do not agree then issue a warning but allow the
        % comparison to continue.
        if isfloat(original) ~= isfloat(mutated)
            warning('isequalwithtolerance:FloatIntCmp', 'Floating point number was compared with an integer for equality.')
        end

        % If rel_tol is infinite then skip relative equality test.
        if isinf(rel_tol)
        	rel_result = true;
        else
    		if any(original == 0)
        		warning('isequalwithtolerance:ZeroCmp', 'Check for relative equality against 0; this means that exact equality was required.')
    		end
            real_cmp = all(abs(real(original) - real(mutated)) <= rel_tol*abs(original));
            imag_cmp = all(abs(imag(original) - imag(mutated)) <= rel_tol*abs(original));
            rel_result = real_cmp && imag_cmp;
        end

		% Carry out absolute equality test.
        real_cmp = all(abs(real(original) - real(mutated)) <= abs_tol);
        imag_cmp = all(abs(imag(original) - imag(mutated)) <= abs_tol);
        abs_result = real_cmp && imag_cmp;
        
        % Both absolute and relative equality must be true to yield true.
        result = rel_result && abs_result;
        return
        
    end
    
    % Check if a logical comparison is to be carried out.
    if islogical(original) || islogical(mutated) 
        if islogical(original) && ~islogical(mutated)
            warning('isequalwithtolerance:LogicNumCmp', 'Expected logical value compared with non-logical.')
        end
        result = isequal(original, mutated);
        return
    end
    
    % If the variable classes don't agree then fail (logical and numeric
    % classes have already been checked.)
    if ~isa(mutated, class(original))
        result = false;
        return
    end
    
    % If strings then return result of comparison.
    if ischar(original)
        result = strcmp(original, mutated);
        return
    end
    
    % If cell arrays then call this function on the elements.
    if iscell(original)
        for k = 1:length(original)
            if ~isequalwithtolerance(original{k}, mutated{k}, rel_tol, abs_tol)
                result = false;
                return
            end
        end
        result = true; % if no inequalities found then must be equal
        return
    end
    
    % If structs with the same field names then call this function on the
    % elements.
    if isstruct(original)
        orig_fn = fieldnames(original);
        mute_fn = fieldnames(mutated);
        if ~isequal(orig_fn, mute_fn) % if field names are different then fail
            result = false;
            return
        end
        for k = 1:length(orig_fn)
            if ~isequalwithtolerance(original.(orig_fn{k}), mutated.(mute_fn{k}), rel_tol, abs_tol)
                result = false;
                return
            end
        end
        result = true; % if no inequalities found then must be equal
        return
    end

    % If none of these cases are suitable then use MATLAB's method.
    result = isequalwithequalnans(original, mutated);
