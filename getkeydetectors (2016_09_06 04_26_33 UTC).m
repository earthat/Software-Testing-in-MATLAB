% Determines which tests are necessary to detect all mutants that exhibit errors
% greater than some detect boundary k_b.
%
% Inputs:
%   - a matrix of error values where each row holds results for a mutant and
%     each column holds results from a test (e.g., data(3,5) indicates the
%     relative error of the 3rd mutant when it is run using the 5th test)
%   - the value of the detect boundary k_b
%   - (optional) a cutoff value to limit the number of combinations that are
%     tested when attempting to find the optimal set of detectors; if this cutoff
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
function key_detectors = getkeydetectors(data, k_b, cutoff, verbose)

    if nargin < 2
        k_b = Inf;
    end

    if nargin < 3
        cutoff = 0;
    end

    if nargin < 4
        verbose = false;
    end

    % get only detected mutants; the others tell us nothing about detectors
    detected = find( max(data, [], 2) >= k_b ); % get detected mutants
    
    % if no mutants are detected then no key detectors so quit
    if isempty(detected)
        key_detectors = [];
        return
    end
    
    % get a list of all tests that detect
    detectors = find( max(data, [], 1) >= k_b );
    
    % get the a list of mutants that each test detects
    detect_lists = cell(1, length(detectors)); % create array to hold lists of detects
    for n = 1:length(detectors) % loop over detectors
        detect_lists{n} = find( data(:, detectors(n)) >= k_b )'; % get detecter n detects
    end

    if verbose
        fprintf('Calling set cover routine with %i subsets.\n', length(detectors))
    end
        
    % key detectors are the minimum set of detectors that detect (cover) all detected
    key_detectors = detectors( getminsetcover(detected, detect_lists, cutoff, verbose) );
    
    % use assertion to confirm that key detectors really are sufficient (they
    % should be unless there is a bug in the code)
    assert( sum( max(data, [], 2) >= k_b ) == sum( max(data(:,key_detectors), [], 2) >= k_b ) )
