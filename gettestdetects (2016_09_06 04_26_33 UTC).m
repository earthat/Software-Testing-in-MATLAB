% Given a list of tests and the test results this function get the list of
% mutants uniquely detected by each test.  This can be used to rank the tests
% in the inpuset set based on their importance.
%
% Inputs:
%   - a matrix of relative error values where each row holds results for a
%   mutant and each column holds results from a test (e.g., data(3,5) indicates
%   the relative error of the 3rd mutant when it is run using the 5th test)
%   - the ID number of the tests that are to be evaluated
%   - (optional; defaults to Inf) the detection boundary; mutants greater than
%   equal to this value are considered to have been detected
%
% Outputs:
%   - an array where
%       - row 1 is tests sorted from most important (i.e., most unique detects)
%       to the weakest (i.e., smallest number of unique detects)
%       - row 2 is the number of unique detects for each test
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

function list = gettestdetects(data, tests, k_b)

    if nargin < 3
        k_b = Inf;
    end

    list = [];
    
    % loop until all mutants that are detected by the tests have been eliminated;
    % best remaining test is added to the list with every iteration and the
    % mutants detected by that test are recorded and then eliminated
    while any( max( data(:,tests),[],1) >= k_b )
        [k t] = max( sum( data(:,tests) >= k_b, 1 ) ); % get index of best test
        t = tests(t); % change index into test number
        list = [list [t; k]]; % add best test and its # of detects to list
        data(data(:,t)>=k_b, :) = []; % eliminate mutants that the test detects
    end
