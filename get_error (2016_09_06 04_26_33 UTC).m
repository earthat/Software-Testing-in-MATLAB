% Calculate relative and absolute errors of a data set compared with a
% reference.
%
% Input:
%   - a cell array R containing the reference data (in theory, this would be
%   the "correct" data)
%   - a cell array M containing the data with errors that are to be measured
%   Note: M must have the same number of cells in the first dimension as R has
%   cells in its only dimension, but M can have any number in the second
%   dimension. Each set of cells in the second dimension will be compared with
%   the set of cells from R's single dimension. 
%
% Output:
%   - a matrix of relative errors where each element in the matrix gives the
%   relative error of the corresponding cell in M to the relevant cell in R
%   - a matrix of absolute errors where each element in the matrix gives the
%   absolute error of the corresponding cell in M to the relevant cell in R
%
%   Notes: Strict equality will be used when comparing arguments that are not
%   numeric (i.e., if they are equal the result is 0, otherwise it is Inf). If
%   arguments are not numeric then a type mismatch evaluates to Inf.  For more
%   details about the equality testing see the isequalwithtolerance function.
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

function [rel_errs, abs_errs] = get_error(original, mutated)

    num_vars = length(original);
    num_mutes = size(mutated, 1);

    abs_errs = zeros(num_mutes, num_vars);
    rel_errs = zeros(num_mutes, num_vars);

    for m = 1:num_vars
        
        for n = 1:num_mutes
            
            % Warn if original result (the denominator) is NaN or Inf.
            if any(isnan(original{m}(:)))
                warning('get_error:NaN', 'Reference value of NaN.')
            elseif any(isinf(original{m}(:)))
                warning('get_error:Inf', 'Reference value of Inf.')
            end
            
            if isequalwithequalnans(original{m}, mutated{n,m})
                % if MATLAB believes they are equal then return 0 error.
                
                abs_errs(n,m) = 0;
                rel_errs(n,m) = 0;    
            
            elseif isequalwithtolerance(original{m}, mutated{n,m}, Inf) && all(~isnan(mutated{n,m}(:)))
                % isequalwithtolerance is used to check if the two inputs are
                % numeric and of comparable types and sizes.  Any comaprable
                % numeric arguments will pass the test while any incompatible or
                % non-numeric arguments will fail.  Note that non-numeric but
                % equal arguments will have been caught before this point.
                
                abs_diff = abs(original{m} - mutated{n,m});
                abs_err = max(abs_diff(:));
                rel_err = max(abs_diff(:)./abs(original{m}(:)));
                
                % If original result (the denominator) is 0 then use absolute
                % error to avoid division by 0. 
                if original{m} == 0
                    warning('get_error:RelErrDivByZero', 'Absolute error used instead of relative error to avoid a division by 0.')
                    rel_err = abs_err;
                end
 
                % Reserve Inf for obvious faults, for numerical errors that
                % overflow into Inf, use realmax instead.
                if rel_err == Inf
                    rel_err = realmax;
                end

                abs_errs(n,m) = abs_err;
                rel_errs(n,m) = rel_err;
                
            else
                % Othewise return Inf to denote an obvious fault.  (This assumes
                % that non-numeric inequalities are obvious.)
                
                abs_errs(n,m) = Inf;
                rel_errs(n,m) = Inf;
                
            end

        end
        
    end

