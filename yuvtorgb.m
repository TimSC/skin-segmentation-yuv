%Title: Yuvtorgb
%Author: Timothy Sheerman-Chase
%Date: 25 Jan 2001
%Description: This is the inverse of the function under study. It uses the colour space
%map as a took up table so make sure it is accessible. Its pretty fast compared to the 
%other function too!
%
%Arguments:
function Pic_out = yuvtorgb(Pic_in)

Inv_map = imread('yuvmap_inverse.png');

[row,col,dim] = size(Inv_map);
UV = double(Pic_in(:,:,2)).*row + double(Pic_in(:,:,3));
Y = double(Pic_in(:,:,1));

%Reshapes inverse array for ease of use.
inv_R = reshape( double(Inv_map(:,:,1)) , row.*col , 1);
inv_G = reshape( double(Inv_map(:,:,2)) , row.*col , 1);
inv_B = reshape( double(Inv_map(:,:,3)) , row.*col , 1);

%compares UV input to array inv_? to convert back to RGB.
R = inv_R(UV);
G = inv_G(UV);
B = inv_B(UV);

%Uses Y component to work out brightness control
Yy = (77 .* R + 150 .* G + 29 .* B)./(255);
Zer = (Yy == 0);
Yy = Yy + (Zer .* 1000);

%Writes data to output (and combines brightness data)
Pic_out(:,:,1) = uint8(R .* Y ./ Yy);
Pic_out(:,:,2) = uint8(G .* Y ./ Yy);
Pic_out(:,:,3) = uint8(B .* Y ./ Yy);


