%Title: Pictoyuv Optimiser
%Author: Timothy Sheerman-Chase
%Date: 25 Jan 2001
%Description: Ok this is a quick hack to speed this routine up. Let me try to explain:
% I notices the pictoyuv was pretty fast with small pictures and exponenially slow
% with big ones. I just make it process the big picture as lots of small ones.
% (Sorry. Perhaps get the routine to work in c and this would be unneeded.)
%Arguments: None

function Pic_in = reftrans(Pic_in,mask_x,mask_y,Ref_points,inverse);

%clear;

%no_of_points = input('\nNo of points?');

%for loop1=1:no_of_points
%   fprintf('\nFor point number %i',loop1);
%   Points_old(loop1,1) = input('\nX(old) = ');
%   Points_old(loop1,2) = input('Y(old) = ');
%   Points_new(loop1,1) = input('\nX(new) = ');
%   Points_new(loop1,2) = input('Y(new) = '); 
%end
X = double(Pic_in(:,:,2));
Y = double(Pic_in(:,:,3));

back_mask = (X == mask_x) .* (Y == mask_y); %Finds areas that should not be changed
[no_of_points,null]=size(Ref_points);

ones_size=ones(size(X));

%Inverse simplt swaps the target and starting values
if  inverse == 1,
	Points_new(:,1) = Ref_points(:,1);
	Points_new(:,2) = Ref_points(:,2);
	Points_old(:,1) = Ref_points(:,3);
	Points_old(:,2) = Ref_points(:,4);
elseif inverse == 0,
	Points_new(:,1) = Ref_points(:,3);
	Points_new(:,2) = Ref_points(:,4);
	Points_old(:,1) = Ref_points(:,1);
	Points_old(:,2) = Ref_points(:,2);
end

Trans = Points_new - Points_old;
continue = 1;

for loop1 = 1:no_of_points %Calculates distance to each reference point
   Dist(loop1,:,:) = ( (ones_size.*Points_old(loop1,1)-X).^2 + (ones_size.*Points_old(loop1,2)-Y).^2 ).^0.5;
end

min_dist = min(Dist); %This stops devide by zeros by a small fudge
if min_dist == 0, disp('Warning: Devide by Zero prevented by Fudge Factor'); end;
min_dist_rotate(:,:) = min_dist(1,:,:);

zero_dist_mask = (Dist==0);
Dist = Dist + 0.001 .* zero_dist_mask; %Replaced 0s with 1s to avoid devide by zero.]
%the 0.001 is a fudge factor to avoid /0 issues.


for loop1 = 1:no_of_points
	Weight(loop1,:,:) = min_dist ./ Dist(loop1,:,:); %Works out weight of each point (to work out weighted average)
end
   total_weight = sum(Weight); %Total weight
   total_weight_rotate(:,:) = total_weight(1,:,:);
   
for loop1 = 1:no_of_points %Works out weighted mean for each point
   Trans_X(loop1,:,:) = ones_size.*Trans(loop1,1);
   Trans_X(loop1,:,:) = Trans_X(loop1,:,:) .* Weight(loop1,:,:);
   Trans_Y(loop1,:,:) = ones_size.*Trans(loop1,2);
   Trans_Y(loop1,:,:) = Trans_Y(loop1,:,:) .* Weight(loop1,:,:);
end   
   %Adds up each contribution
   sum_Trans_X = sum(Trans_X);
   sum_Trans_Y = sum(Trans_Y);
   sum_Trans_X_rotate(:,:) = sum_Trans_X(1,:,:);
   sum_Trans_Y_rotate(:,:) = sum_Trans_Y(1,:,:); 
   
X_new = X + sum_Trans_X_rotate ./ total_weight_rotate;%Devides by total
Y_new = Y + sum_Trans_Y_rotate ./ total_weight_rotate;

%Replace the green background
   X_new = X_new + (X - X_new) .* back_mask ;
	Y_new = Y_new + (Y - Y_new) .* back_mask ;

Pic_in(:,:,2) = uint8(X_new);
Pic_in(:,:,3) = uint8(Y_new);

disp('Completed Reference Point Transform');