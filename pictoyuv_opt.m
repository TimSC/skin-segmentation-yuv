%Title: Pictoyuv Optimiser
%Author: Timothy Sheerman-Chase
%Date: 25 Jan 2001
%Description: Ok this is a quick hack to speed this routine up. Let me try to explain:
% I notices the pictoyuv was pretty fast with small pictures and exponenially slow
% with big ones. I just make it process the big picture as lots of small ones.
% (Sorry. Perhaps get the routine to work in c and this would be unneeded.)
%Arguments: None
function Pic_out = pictoyuv_opt(Pic_in)

pictoyuv_time_keeper = cputime;
size_Pic_in = size(Pic_in);
fprintf('\nSize of input image is %i by %i with %i colour components',size_Pic_in(1),size_Pic_in(2),size_Pic_in(3));

band_height = ceil(60000 ./ size_Pic_in(1)); %it makes it deal with 60k pixels in one iteration
steps_needed = round(size_Pic_in(1) ./ band_height);%Works out how many steps to process image
steps_needed = steps_needed + (steps_needed == 0);

Pic_out = uint8(zeros(size(Pic_in)));

start_x=0;
fprintf('\nProgress:');
%Feeds bits of picture to routine and reassembles them
for loop = 1:steps_needed
   
start_x=start_x +1;
fin_x = round(loop.*size_Pic_in(1) ./ steps_needed);

Pic_out(start_x:fin_x,1:size_Pic_in(2),:) =...
   pictoyuv( Pic_in(start_x:fin_x,1:size_Pic_in(2),:) ,0);

start_x = fin_x;
fprintf('...%u%%',round(100.*fin_x./size_Pic_in(1)) );%Shows progress
end

fprintf('\nFunction pictoyuv_opt Completed in: %f\n',cputime - pictoyuv_time_keeper);
