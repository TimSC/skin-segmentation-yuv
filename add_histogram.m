

%Title: Histogram Adder/Subtractor
%Author: Timothy Sheerman-Chase
%Date: - 25 Jan 2001
%Description: This adds histograms but this does not run in the main program
% It is just included for utility in case if the need arises.
%Dependencies: 
%Arguments: first_hist,second_hist,first_weight,second_weight
%Note: negative weights should subtract histograms


function out_hist = add_histogram(first_hist,second_hist,first_weight,second_weight)

if nargin<3
   first_weight=1; second_weight=1;
end

out_hist = double(first_hist).*first_weight + double(second_hist).*second_weight;
max_value = max(max(out_hist));
out_hist = out_hist .* 255 ./ max_value;%renormalise output
