
%Title: view_scdm.m
%Author: Timothy Sheerman-Chase
%Date: 25 Jan 2001
%Description: This is a simple little routine to make all my graphs appear the same.
%They plot so that only the area of skin pixels is really shown
%
%
%Dependencies: 

function view_scdm(scdm_path)

if nargin < 1 , scdm_path = 'scdm.png'; end;

figure(1);
clf;
Scdm_in = imread(scdm_path);

axis([40,60,40,70]);
colormap(gray);

surface(double(Scdm_in)./255);
colorbar;