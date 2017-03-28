% Given a set that is to be covered (the "universe") and a collection of subsets
% of the universe, this function determines how many of the subsets are needed
% to cover the universe.
%
% Inputs:
%   - the "universe", i.e., the set to be covered
%   - a 1-dimensional cell array where each cell contains one of the subsets
%     that are to be used to cover the universe
%   - (optional) a cutoff value: if the number of combinations that are to be
%     checked in the current iteration of the function are larger than this
%     value the the function gives up on finding the optimal solution and uses
%     an approximate solution that is calculated using the greedy algorithm;
%       - a warning is given when the cutoff is exceeded unless this value
%         is set to 0
%       - if set to 0 then the approximation algorithm is used immediately
%       - by default this value is set to 5e6
%   - (optional) if true, the function prints the number of combinations that
%     are being checked in each iteration when that iteration is reached
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
function minsetcover = getminsetcover(universe, subsets, cutoff, verbose)

    if nargin < 3
        cutoff = 5e6;
    end

    if nargin < 4
        verbose = false;
    end

    minsetcover = [];


    % list important subsets that may form part of the min set cover
    important = 1:length(subsets); % start with all subsets
    
    % while loop is used reduce the number of subsets that must be considered
    % by removing obviously extraneous subsets and storing obviously needed
    % subsets
    old_important = -1;
    while (~isequal(important, old_important))
        old_important = important;

        % determine if there are any elements that are covered by all important subsets
        all_covered = universe;
        for n = important
            all_covered = intersect(all_covered, subsets{n});
        end

        % these fully covered elements can be removed from consideration
        universe = setdiff(universe, all_covered); % remove them from universe
        for n = important
            subsets{n} = setdiff(subsets{n}, all_covered); % remove them from subsets
        end
        
        % if universe is now empty then choose any important subset and finish
        if isempty(universe)
            minsetcover = union(minsetcover, important(1));
            return
        end
        
        % subsets that are subsets of other subsets can be ignored because they are
        % obviously extraneous
        marked = []; % track subsets that are to be ignored
        for m = 1:length(important) % loop over important subsets
            if any(marked == m) % if mth subset is already marked
                continue % continue to next m
            end
            for n = m+1:length(important) % loop over important subsets after mth
                if any(marked == n) % if nth subset is already marked
                    continue % continue to next n
                end
                mUn = union(subsets{important(m)}, subsets{important(n)});
                if isequal(mUn, subsets{important(m)}) % if m U n same as m
                    marked = union(marked, n); % n is extraneous so mark for removal
                elseif isequal(mUn, subsets{important(n)}) % if m U n same as n
                    marked = union(marked, m); % m is extraneous so mark for removal
                    break % m is extraneous so move to next m
                end
            end
        end
        important(marked) = []; % marked subsets are not important so remove

        % find elements that are only covered by one important subset
        counts = zeros(size(universe));
        for n = important
            counts = counts + ismember(universe, subsets{n});
        end
        one_covered = universe(counts == 1);

        % determine which subsets cover single covered elements, add them to the
        % min set cover, and remove them and the elements they cover from
        % futher consideration
        for n = important
            if ~isempty(intersect(one_covered, subsets{n}))
                minsetcover = union(minsetcover, n);
                important = setdiff(important, n);
                universe = setdiff(universe, subsets{n});
                if isempty(universe) % if nothing left
                    return % then done
                end
            end
        end

    end % end while loop


    % make sure that subsets can actually cover the universe
    if ~all( ismember(universe, [subsets{[minsetcover important]}]) )
        error('Subsets cannot be used to cover universe.')
    end
    
    
    % set subsets to the important subsets; important must be kept as a
    % reference to retrieve the actual indices at the end
    subsets = {subsets{important}};


    % use the greedy algorithm to get an approximate solution, this is used to
    % put a lower bound on the size of the optimal solution set
    approxsetcover = getapproxsetcover(universe, subsets);
    
    % if cutoff is 0 then return the approximate answer with the subsets that
    % have already been identified as part of the min set cover; or if the
    % approx set contains only 1 subset then it is optimal so return it as
    % solution.
    if cutoff == 0 || length(approxsetcover) == 1
        minsetcover = union(minsetcover, important(approxsetcover));
        return
    end

    % determine which subset is the biggest; used to calculate lower bound on
    % solution size
    biggest = 0;
    for n = 1:length(subsets)
        if length(subsets{n}) > biggest;
            biggest = length(subsets{n});
        end
    end

    % the iterations will start with sets that are the size of the lower bound
    % which is calculated here and stop at sets that are the same size as the
    % approximate solution; we know that the solution must require at least 2
    % subsets or it would have already been found
    start = max( 2 , ceil( length(approxsetcover)/harmonic(biggest) ) );
    stop = length(approxsetcover) - 1;


    % for faster processing: convert sets and subsets to vectors of logicals
    % where nth number in set is represented by "true" in the nth position;
    universe = ismember(1:max(universe), universe);
    for n = 1:length(subsets)
        subsets{n} = ismember(1:length(universe), subsets{n});
    end
    subsets = cell2mat(subsets'); % join cells of subsets into one matrix

    % columns in subsets where universe vector is false can deleted because they
    % are extraneous; false locations in universe vector can also be deleted
    subsets(:,~universe) = [];
    universe(~universe) = [];
    
    % subsets will always be needed in the negated form, so negate them now
    subsets = ~subsets;
    
    if verbose && start <= stop
        fprintf('Choosing combinations of %i to %i subsets from %i subsets.\n', start, stop, size(subsets,1));
    end

    % start looking at sets the size of start and try all other combinations up
    % to the size of the approximate solution
    for k = start:stop
        
        % get number of possible combinations
        ncmb = nchoosek(size(subsets,1), k);
        
        % if the number of combinations is larger than the cutoff then give up,
        % issue a warning, and use the approximation algorithm
        if ncmb > cutoff
            warning('minsetcover:ApproxSolnUsed', 'Problem size exceeded cutoff value so approximate set cover solution used.')
            minsetcover = union(minsetcover, important(approxsetcover));
            return
        end

        if verbose
            fprintf('Checking %i combinations of %i subsets.\n', ncmb, k);
        end
        
        % check if universe can be covered by combinations of k subsets by
        % using recursive subfunction
        cover = checkcmb(universe, subsets, 1, k-1);

        % if a cover was returned then the min set cover has been found;
        % don't forget that already determined subsets must be included
        if ~isempty(cover)
            minsetcover = union(minsetcover, important(cover));
            return
        end
        
    end
    
    % if loop terminates without solution then approximate solution is optimal
    minsetcover = union(minsetcover, important(approxsetcover));

end % end main function


% Recursive subfunction that is used to check varying number of combinations
% to see if they cover the universe.  Function is designed to execute in a way
% that attempts to reduce the number of repeated calculations.
%
% Inputs:
%   - universe to be covered
%   - subsets to cover the universe
%   - index of the first subset to be used as a cover at current depth
%   - maximum recursive depth remaining
%
% Output:
%   - list of subsets that cover the given universe; if output is empty then a
%     cover does not exist
function cover = checkcmb(universe, subsets, start, depth)
    cover = [];
    
    % loop through possible combinations of subsets at this depth
    for n = start:size(subsets,1)-depth
        % get universe without the current subset
        newuniverse = universe & subsets(n,:);
        
        % if not at end then recursively call this function again
        if depth > 0
            sub_cover = checkcmb(newuniverse, subsets, n+1, depth-1);
            if ~isempty(sub_cover) % if result has a cover then return
                cover = [sub_cover n]; % with current subset included
                return
            end
            
        % if at end and the universe is empty then a solution has been found
        % return current subset to indicate this
        elseif ~any(newuniverse)
            cover = n;
            return
            
        end
        
    end
end % end checkcmb subfunction


% Calculates the nth harmonic number; used to calculate lower bound on size
% of the solution.
function S = harmonic(n)
    S = sum( 1./(1:n) );
end
