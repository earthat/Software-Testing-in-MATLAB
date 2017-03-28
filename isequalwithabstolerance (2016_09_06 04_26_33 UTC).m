% Checks for equality within absoulte bounds.
%
% If input is a matrix of floats or doubles then this method checks to see if
% the  second input is approximately equal to the first within a given absolute
% tolerance.  If the inputs are cell arrays or structs then they will be
% recursively explored for equality.  If the inputs are anything else then they
% will be checked for strict equality.
%
% Inputs:
% - an object (usually the "correct" value)
% - an object (to be checked against the "correct" value
% - an absolute tolerance
%
% Outputs:
% - true if values considered to be equal, false otherwise
%
% Absolute Equality:
%   A floating point number y is considered to be equal to a floating point
%   number x  within absolute tolerance a if
%
%		|Re(x) - Re(y)| <= a   and   |Im(x) - Im(y)| <= a
%
%   where Re(q) and Im(q) denote the real and imaginary parts of a number q.
%
% The behaviour of this function is different than the MATLAB isequal()
% function which only checks for strict equality.  Other differences between
% this method and isequal() include the following:
% - NaNs are treated as being equal (like isequalwithequalnans()).
% - A warning is issued when comparing a logical value with a numeric
% value or an integer value with a floating-point value.
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

function result = isequalwithabstolerance(original, mutated, abs_tol)

    result = isequalwithtolerance(original, mutated, Inf, abs_tol);