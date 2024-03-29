function [ f ] = ERB2f( ERB )
% [ f ] = ERB2F( ERB )
%   Calculates the ERB value corresponding to a given frequency f (see Eq. 17
%   of Hohmann (2002)  
%
% Author: Leo Varnet 2016

l = 24.7;
q = 9.265;
f = l*q*(exp(ERB/q)-1);