
%Title: Perform General Linear Transform
%Author: Timothy Sheerman-Chase
%Date: 25 Jan 2001
%Description: This performs a general linear transform on an image. The transform is defined
% in the array Par. The inverse is not yet implimented. (The algebra takes too long and not
% really needed)
%Arguments: None

function Pic_in = lintrans(Pic_in,mask_x,mask_y,Par,inverse);

X = double(Pic_in(:,:,2));
Y = double(Pic_in(:,:,3));

%Preserved the green colour
back_mask = (X == mask_x) .* (Y == mask_y); 

   B(1,1:2) = Par(1:2);   
   B(2,1:2) = Par(3:4);
   C= Par(5:6)';
   
   X_new = Par(1) .* X + Par(2) .* Y + Par(5);
   Y_new = Par(3) .* X + Par(4) .* Y + Par(6);

%Replace the green background
   X_new = X_new + (X - X_new) .* back_mask ;
	Y_new = Y_new + (Y - Y_new) .* back_mask ;

Pic_in(:,:,2) = uint8(X_new);
Pic_in(:,:,3) = uint8(Y_new);

disp('Completed General Linear Transform');