%Title: Least Squares Fit Internals File
%Author: Timothy Sheerman-Chase
%Date: 15 Feb 2001
%Description: These are internal rountines called in lsfit.m
%They work out the values of the function at certain point as well
%as thier numerical derivatives.
%Arguments:


function grad = ls_func(Par,DiffWRT,Start,Finish)
%Works out the gradient of function
if nargin<3, %Default values

   Start=[26.262024 42.844872; ...
         23.300226 61.349041;...
         57.892615 55.162263;...
         84.583259 50.025977;...
         57.736426 63.534540];
   end;
if nargin<4,         
   Finish=[29.960676 40.751381;...
 			20.547414 55.417596;...
 			49.299338 48.455188;...
 			70.516201 44.233147;...
 			52.070752 61.271462];
end;
    
    
    start_dist = eval_fn(Par,Start,Finish,DiffWRT);
    
    if DiffWRT > 0 %If a varible of differentiate wrt is specifed it attempts to work it out
       
       High_Par = Par;
       Low_Par = Par;
      High_Par(DiffWRT) = Par(DiffWRT).* 1.001;
      Low_Par(DiffWRT) = Par(DiffWRT) .* 0.999;
   	interval = High_Par(DiffWRT) - Low_Par(DiffWRT);
      high_dist = eval_fn(High_Par,Start,Finish,DiffWRT);
      low_dist = eval_fn(Low_Par,Start,Finish,DiffWRT);
      grad = (high_dist - low_dist) ./ interval;
   else %Otherwise it does not differnetiate
      grad=start_dist;
   end
   
   %Evaluates the function (this is the distance between the transformed values and the
   %Observed values.)
   function tot_Sqr = eval_fn(Par,Start,Finish,DiffWRT)
    

   B(1,1:2) = Par(1:2);   
   B(2,1:2) = Par(3:4);
   C= Par(5:6)';
   tot_Sqr = 0;
   
   [rows,null]=size(Start);
   for loop=1:rows,
   	Xstart = Start(loop,:)';
   	Xfinish = Finish(loop,:)';
   	Xdash = B * (Xstart) + C;
      tot_Sqr = tot_Sqr + (Xdash(1) - Xfinish(1)).^2;
      if DiffWRT == 0,
      %	fprintf('\n%i %i',(Xdash(1) - Xfinish(1)).^2,(Xdash(2) - Xfinish(2)).^2);
      end;
      tot_Sqr = tot_Sqr + (Xdash(2) - Xfinish(2)).^2;
   end;
   