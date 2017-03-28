% Uses greedy algorithm to find an approximate solution to the set cover
% problem.  The size of the solution will be equal to the size of the optimal
% solution within an approximation ratio given by
%
%           |Aprx|/|Opt| <= H(n)
%
% where Aprx is the the solution from this function, Opt is the optimal
% solution, and H(n) is the nth harmoic number.
%
% Inputs:
%   - the universe, i.e., the set of numbers that is to be covered
%   - a 1-dimensional cell array where each cell contains one of the subsets
%     that are to be used to cover the universe
%
% Output:
%   - a list of the subsets that can be used to cover the universe, the size of
%     this may not be optimal, but its distance from the optimal set is bounded
%     by the approximation ratio given above
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
function setcover = getapproxsetcover(universe, subsets)

    % make sure that subsets can actually cover the universe
    if ~all( ismember(universe, [subsets{:}]) )
        error('Subsets cannot be used to cover universe.')
    end

    setcover = [];

    % continue this loop until the set is covered
    while ~isempty(universe)

        % determine the winner, i.e., the subset that covers the most of the
        % remaining universe
        winner = 1;
        for n = 2:length(subsets)
            if sum( ismember(universe, subsets{n}) ) > sum( ismember(universe, subsets{winner}) ) 
                winner = n;
            end
        end

        % add the winner to the list of covering subsets
        setcover = [setcover winner];

        % remove the winner from the universe
        universe = setdiff(universe, subsets{winner});

    end
