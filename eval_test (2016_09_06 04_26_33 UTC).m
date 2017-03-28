% This function can be used to evaluate the characteristics of a set of tests
% when run on a given set of mutants.
%
% Inputs:
%   - a matrix of relative error values where each row holds results for a
%   mutant and each column holds results from a test (e.g., data(3,5) indicates
%   the relative error of the 3rd mutant when it is run using the 5th test)
%   - the ID number of the test to be evaluated
%   - (optional; defaults to 0) a lower bound L on what will be considered
%   to be sufficient demonstrate a fault; any result R such that R <= L will be
%   considered to indicate equivalence or near equivalence
%   - (optional; defaults to Inf) an upper bound U on results; any result R
%   such that R >= U will be considered to indicate a detected mutant
%
% Outputs:
%   - a struct containing 4 lists
%       detected: mutants that were detected by the given test
%       revealed: mutants that were revealed by the given test but which
%           were not strongly or weakly revealed
%       undetected: mutants that were not detected by the given test
%       weak: mutants that were weakly revealed by the given test
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

function [list] = eval_test(data, test, lower, upper)

    if nargin < 3
        lower = 0;
    end

    if nargin < 4
        upper = Inf;
    end

    % Get lists of the mutants in each regime for given test.
    list.detected = find(data(:,test) >= upper); % get mutants where error >= U
    list.undetected = find(data(:,test) == 0); % get mutants where error = 0
    list.weak = find(data(:,test)<=lower & data(:,test)>0); % get mutants where 0 < error <= L
    list.revealed = find(data(:,test)<upper & data(:,test)>lower); % get mutants where L < error < U

    % Print some statistics to the screen.
    fprintf('\n')
    fprintf('Running on %i mutants, test %i:\n', size(data,1), test)
    fprintf('\tdetected %i\n', length(list.detected))
    fprintf('\tmissed %i\n', length(list.undetected))
    fprintf('\trevealed %i\n', length(list.revealed))
    if lower > 0
        fprintf('\tweakly revealed %i\n', length(list.weak))
    end
    fprintf('\n')
