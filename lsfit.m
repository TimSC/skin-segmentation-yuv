%Title: Leasted Squares Fit
%Author: Timothy Sheerman-Chase
%Date: 15 Feb 2001
%Description: Uses Newton-Coates to find a rough least squares fit. There probabily better
%numberical techniques that could be applied, but this is satifactory.
%
%Arguments:

function Par = lsfit(Start,Finish,disp_progress)

if nargin<1,%Sets defaults
   Start=[84.583259 50.025977;...
         23.300226 61.349041;...
      	26.262024 42.844872; ...
         57.892615 55.162263;...
         57.736426 63.534540];
end;
if nargin<2,
   Finish=[70.516201 44.233147;...
         20.547414 55.417596;...
      	29.960676 40.751381;...
 			49.299338 48.455188;...
 			52.070752 61.271462];
 end;
 
 if nargin<3, disp_progress = 0; end;

	old_dist=10000000;
	%Par= [ 4.5 -2.1 0.8 -0.17 -0.02 0.9];
   Par =[1 1 1 1 1 1]; %Guess values
   
fitting_data = 1;
if disp_progress == 1,fprintf('\nTotal distance: %i',lsfit_func(Par,0,Start,Finish));end;

time_keeper=cputime; %Start timer (to see how long program takes)
continue = 1;
while continue == 1
   
   [null,rows]=size(Par);
   for loop = 1:rows, %Applies newton coates
   	
   
   High_Par = Par;
   Low_Par = Par;
   High_Par(loop) = Par(loop).* 1.000001;
   High_Par(loop) = Par(loop).* 0.999999;
   	interval = High_Par(loop) - Low_Par(loop);
      new_dist = lsfit_func(High_Par,loop,Start,Finish);
      total_dist=lsfit_func(Low_Par,loop,Start,Finish);
      grad = (new_dist - total_dist) ./ interval;
      
      Par_calc = Par;
      Par_calc(loop) = Par(loop) - 1.1 .* (total_dist ./ grad);
   
      Par = Par_calc;
      
   end;
   
   new_dist = lsfit_func(Par,0,Start,Finish);
   
   if disp_progress == 1,fprintf('\nTotal distance: %i    Grad: %i',new_dist,grad);end;
   
   if(cputime - time_keeper > 5) , continue = 0;end; %Proceeds for 5 seconds to get reasonable accuracy.

end
fprintf('\nDone with Least Squares Fit in: %f sec',cputime - time_keeper);
