% Returns a smaller set of tests that will achieve identical maximum mutant
% error results. 
%
% Inputs:
%   - a matrix of error values where each row holds results for a mutant and
%     each column holds results from a test (e.g., data(3,5) indicates the
%     relative error of the 3rd mutant when it is run using the 5th test)
%   - (optional) a cutoff value to limit the number of combinations that are
%     tested when attempting to find the optimal set of tests; if this cutoff
%     is passed then an approximate solution will be used instead; by default
%     this is 0 which means that the approximate solution is always returned
%   - (optional) if true this function will print information about the size
%     of the parameters that are being passed to the set cover function
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
%
function keys = getkeytests(data, cutoff, verbose)

    if nargin < 2
        cutoff = 1e5;
    end

    if nargin < 3
        verbose = false;
    end

    % get the maximum value for each mutant
    mutant_max = max(data, [], 2);

    % generate a mask the same size as data that is true wherever a
    % a mutant's max error occurs and false everywhere else
    max_mask = zeros(size(data));
    for n = 1:length(mutant_max)
        max_mask(n,:) = mutant_max(n) > 0 & data(n,:) == mutant_max(n);
    end

    % use key detector analysis on the max mask with a detect boundary of 1 to
    % determine the key tests
    keys = getkeydetectors(max_mask, 1, cutoff, verbose);
    
    % use assertion to confirm that maximum errors for mutants are the same when
    % only the key tests determined by this function are used; this should
    % always pass unless there is a coding mistake
    assert( all( max(data(:,keys), [], 2) == mutant_max ) )
