% This function can be used to evaluate the characteristics of a set of tested
% mutants that have been run on a set of tests.
%
% Inputs:
%   - a matrix of relative error values where each row holds results for a
%   mutant and each column holds results from a test (e.g., data(3,5) indicates
%   the relative error of the 3rd mutant when it is run using the 5th test).
%   - (optional; defaults to 0) weak reveal bound L; any result R such that
%   R <= L is considered to have been weakly revealed
%   - (optional; defaults to Inf) strong reveal bound; any result R such that
%   R >= U will be considered to have been strongly revealed (i.e., detected)
%
% Outputs:
%   - a list of all the mutants sorted by their most strongly revealed result
%   - a struct containing four lists
%       detected: mutants that were detected by the given tests
%       revealed: mutants that were revealed by the given tests but which
%           were not strongly or weakly revealed
%       undetected: mutants that were not detected by the given tests (these
%           mutants may be equivalent to the original program)
%       weak: mutants that were weakly revealed by the given tests
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

function [sorted_errors list] = eval_mutants(data, lower, upper)

    if nargin < 2
        lower = 0;
    end

    if nargin < 3
        upper = Inf;
    end

    num_mutants = size(data, 1);
    
    % We only care about the largest error score for each mutant so take the
    % maximum error value accross the rows.
    data = max(data, [], 2);
    
    % Get lists of the mutants in each regime.
    detected = find(data >= upper); % get mutants where max error >= U
    undetected = find(data == 0); % get mutants where max error = 0
    weakly_revealed = find(data<=lower & data>0); % get mutants where 0 < max error <= L
    revealed = find(data<upper & data>lower); % get mutants where L < max error < U
    
    % Check that all mutants are in one and only one of the four categories.
    assert( isempty(setdiff([detected; undetected; weakly_revealed; revealed], 1:num_mutants)) )

    sorted_errors = sortrows([(1:length(data))' data], 2);
    
    list.detected = detected;
    list.undetected = undetected;
    list.weak = weakly_revealed;
    list.revealed = revealed;
    
    % Prints some stats to the screen.
    fprintf('\n%i mutants were analyzed.\n', num_mutants)
    fprintf('\n')
    
    fprintf('Using the given tolerances there were\n')
    fprintf('     %i detected mutants\n', length(detected))
    fprintf('     %i revealed mutants\n', length(revealed))
    if lower > 0
        fprintf('     %i weakly revealed mutants\n', length(weakly_revealed))
    end
    fprintf('     %i undetected mutants\n', length(undetected))
    fprintf('\n')
