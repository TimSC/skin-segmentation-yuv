%Title: Chart Find
%Author: Timothy Sheerman-Chase
%Date: 15 Feb 2001
%Description: This allows the user to roughly specify the corners of the chart and does 5 sec
%of Monty Carlos changes to try to improve the fit. This is really rough and can be improved. Ideally this
%would be completely automatic.
%Arguments:

function Points = chart_find(Pic_yuv,disp_progress,full_search_step,chart_yuv,mask_pic)

%Defines default arguments
if nargin<1,
	Pic_default = imread('C:/My Documents/matlab/Workspace/Lighting_Conditions/Raw/Artificial/A006-0007.png');
	Pic_yuv = pictoyuv_opt(Pic_default);
end;
if nargin<2, disp_progress = 0; end;
if nargin<3, full_search_step = 0; end;
if nargin<4, 
	Chart_yuv = double(pictoyuv_opt(imread('C:/My Documents/matlab/Workspace/colour_chartA.png')));
else
	Chart_yuv = double(chart_yuv);
end


Chart = imrotate(Chart_yuv,0);
figure(1);imagesc(Pic_yuv);

Pic_in = Pic_yuv;

fprintf('\Done Reading Input Files');


%%%%%%%%%%%%%%%%%%%%55
%Allows selection of top left corner
continue = 1;
while continue == 1

fprintf('\nClick on the top left of the chart');
global M_pos;
M_pos=0;
while M_pos == 0,
   set(gcf,'WindowButtonDownFcn',...
      'global M_pos;M_pos=get(gcf,''CurrentPoint'');clear M_pos;');
   pause(0.1);
end;

size_pic = size(Pic_yuv);
figure_size = get(gcf,'Position');
axes_position = get(gca,'Position');

x_window = M_pos(1) ./ figure_size(3);
tl_x_axes = (x_window - axes_position(1)) ./ axes_position(3);
tl_x_pixel = round(tl_x_axes .* size_pic(2));

y_window = M_pos(2) ./ figure_size(4);
tl_y_axes = (y_window - axes_position(2)) ./ axes_position(4);
tl_y_pixel = round(size_pic(1) - (tl_y_axes .* size_pic(1)));

start_y = tl_x_pixel;
start_x = tl_y_pixel;
best_start_y = tl_x_pixel;
best_start_x = tl_y_pixel;

%End of select top left
%%%%%%%%%%%%%%

%%%%%%%%%%%%
%Allows selection of bottom right corner
fprintf('\nClick on the bottom right of the chart');
global M_pos;
M_pos=0;
while M_pos == 0,
   set(gcf,'WindowButtonDownFcn',...
      'global M_pos;M_pos=get(gcf,''CurrentPoint'');clear M_pos;');
   pause(0.1);
end;

figure_size = get(gcf,'Position');
axes_position = get(gca,'Position');

x_window = M_pos(1) ./ figure_size(3);
br_x_axes = (x_window - axes_position(1)) ./ axes_position(3);
br_x_pixel = round(br_x_axes .* size_pic(2));

y_window = M_pos(2) ./ figure_size(4);
br_y_axes = (y_window - axes_position(2)) ./ axes_position(4);
br_y_pixel = round(size_pic(1) - (br_y_axes .* size_pic(1)));
%End of select bottom right corner
%%%%%%%%%%%%%%%%%%%%%%%%

new_y = br_x_pixel- tl_x_pixel;%Works out size of chart but corner positions
new_x = br_y_pixel- tl_y_pixel;
best_new_y = br_x_pixel- tl_x_pixel;
best_new_x = br_y_pixel- tl_y_pixel;

continue = 0;%Check to see if the positions selected are valid
if tl_x_axes < 0, continue = 1;end;
if tl_y_axes < 0, continue = 1;end;
if br_x_axes < 0, continue = 1;end;
if br_y_axes < 0, continue = 1;end;
if tl_x_axes > 1, continue = 1;end;
if tl_y_axes > 1, continue = 1;end;
if br_x_axes > 1, continue = 1;end;
if br_y_axes > 1, continue = 1;end;
if br_x_pixel < tl_x_pixel, continue = 1;end;
if br_y_pixel < tl_y_pixel, continue = 1;end;
if continue == 1, fprintf('\nPlease try again - area not valid!'); end;
end; 

%%%%%%%%%%%%%%%%%%%%%%%%%
% Monty Carlos method of guessing improvements and see if they are better than current case
% Not sure this is the best approach.

best_dist = 10 .^ 50;
time_keeper=cputime; %Start timer (to see how long program takes)
continue = 1;
step = 5;

fprintf('\nImproving Fit of Chart....');
while(continue == 1),

Chart_resize = imresize(Chart,[new_x,new_y]);

	[pic_x,pic_y,null] = size(Pic_in); 
	if(new_x < 0), new_x = 1;end;%checks if the test region is valid and not out of range
	if(new_y < 0), new_y = 1;end;      
	if(start_x < 0), start_x = 1;end;
	if(start_y < 0), start_y = 1;end;      
	if(pic_x < new_x + start_x), new_x = pic_x - start_x;end;
	if(pic_y < new_y + start_y), new_y = pic_y - start_y;end;

	%figure(1); imagesc(Chart_read);

	%disp(new_x);disp(new_y);disp(start_x+new_x);disp(start_y+new_x);

	clear U_dist;clear V_dist;
	%Works out the quality of match.
	U_dist = ( double(Pic_yuv ([start_x:start_x+new_x-1],[start_y:start_y+new_y-1],2))...
	  	 - double(Chart_resize([1:new_x],[1:new_y],2)) ).^2;
	V_dist = ( double(Pic_yuv ([start_x:start_x+new_x-1],[start_y:start_y+new_y-1],3))...
	  	 - double(Chart_resize([1:new_x],[1:new_y],3)) ).^2;  
	
	%figure(2); imagesc(U_dist);colormap gray; colorbar;
	%figure(3); imagesc(V_dist);colormap gray; colorbar;

	[size_x,size_y] = size(U_dist);
	fit_dist = ( sum(sum(U_dist))+sum(sum(V_dist)) ) ./ (size_x.*size_y) ;

if (fit_dist < best_dist), %If fit is better, keep it
	best_new_x = new_x;
	best_new_y = new_y;
	best_start_x = start_x;
   best_start_y = start_y;
   best_dist = fit_dist;
else %Otherwise go back to old fit
   new_x = best_new_x;
	new_y = best_new_y;
	start_x = best_start_x;
   start_y = best_start_y;
end;



change_rand = floor(8.*rand(1)); %Guess a new change to see if it is better
	if change_rand == 0, new_x = new_x + step;end;
	if change_rand == 1, new_x = new_x - step;end;
	if change_rand == 2, new_y = new_y + step;end;
	if change_rand == 3, new_y = new_y - step;end;
	if change_rand == 4, start_x = start_x + step;end;
	if change_rand == 5, start_x = start_x - step;end;
	if change_rand == 6, start_y = start_y + step;end;
	if change_rand == 7, start_y = start_y - step;end;

if disp_progress == 1,fprintf('\nDistance: %i   Time: %f',fit_dist,cputime - time_keeper);end;

if(cputime - time_keeper > 5), step = 2;end;
if(cputime - time_keeper > 10), continue = 0;end;

end;

% End of Monty Carlos fit improvement
%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nFit Details X:%f Y:%f SX:%f SY:%f',start_x,start_y,new_x,new_y);

Chart_resize = imresize(Chart,[best_new_x,best_new_y]);
%Pic_in ([best_start_x:best_start_x+best_new_x-1],[best_start_y:best_start_y+best_new_y-1],:) = Chart_resize;


if nargin<5, 
	Mask_read = imread('C:/My Documents/matlab/Workspace/colour_chart_maskA.png');
else
	Mask_read = mask_pic;
end
%Mask= imrotate(pictoyuv_opt(Mask_read),0);
Mask= imrotate(double(Mask_read),0);
Mask = imresize(Mask,[best_new_x,best_new_y]);

%Output image to show colour regions
%Overlay = Pic_yuv;
%Overlay([best_start_x:best_start_x+best_new_x-1],[best_start_y:best_start_y+best_new_y-1],:) = Mask;
%Overlay = double(bwperim((Overlay(:,:,1)==255),8));
%Overlay2(:,:,1) = Overlay;
%Overlay2(:,:,2) = Overlay;
%Overlay2(:,:,3) = Overlay;
%figure(1); imagesc(uint8(double(Pic_yuv).*(1-Overlay2)));

Mask = double(Mask(:,:,1));
number_of_cols = max(max(Mask .* (Mask < 255)));

for loop = 1:number_of_cols, %Read colours from image and works out average value
   
   Single_col_U = double(Pic_yuv([best_start_x:best_start_x+best_new_x-1],...
      [best_start_y:best_start_y+best_new_y-1],2)) .* (loop == Mask);
   Single_col_V = double(Pic_yuv([best_start_x:best_start_x+best_new_x-1],...
      [best_start_y:best_start_y+best_new_y-1],3)) .* (loop == Mask);
   total_U = sum(sum(Single_col_U));
   total_V = sum(sum(Single_col_V));
   pixels = sum(sum(loop == Mask));   
   average_U = total_U ./ pixels;
   average_V = total_V ./ pixels;
   fprintf('\nColour %i - U: %f V: %f',loop,average_U,average_V);
   Points(loop,1) = average_U;
   Points(loop,2) = average_V;
end;

fprintf('\n');