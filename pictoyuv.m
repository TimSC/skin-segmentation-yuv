
%Title: pictoyuv.m
%Author: Timothy Sheerman-Chase
%Date: 8 October 2000 (Totally revised 11 October)
%Description: This is an expansion of the rgb2yub routine to "quickly" convert whole rgb
%pictures to yuv perceptionally uniform colour space.
%This incorporated a routine written in c from http://www.sys.wakayama-u.ac.jp/~chen/ucs.html
%
%Dependencies: rgb2yuv_init.m

function Pic_out = pictoyuv(Pic, print_output)

if nargin < 2, print_output = 1; end;

pictoyuv_time_keeper = cputime; %This times how long the function takes

xy2uv = rgb2yuv_init_long; %Reads the data table for the conversion later on

SizeofPic = size(Pic);

if print_output == 1
disp('Size of Pic is ')
disp(SizeofPic);
end

%Change to Universal Colour Space

R=double(Pic(:,:,1));%Read the 3 colours in to 3 lots of 2D matrix
G=double(Pic(:,:,2));
B=double(Pic(:,:,3));

%Get the CIE Y channel values
Yy = 77 .* R + 150 .* G + 29 .* B;    %/* CIE's Y * 256 */
YCHAN = floor(Yy ./ 256);           %/* CIE's Y */

finished_pixel = 0; %This is used to skip parts of the function if the result is known

%Must remove all black or it fails -
Black_Map = 1 - sign(YCHAN) .^ 2;
R = R + 255 .* Black_Map;
G = G + 255 .* Black_Map;
B = B + 255 .* Black_Map; %Replace all black with white but remember what was done!

Xx = 147 * R + 42 * G + 49 * B;    %/* CIE's X * 256 */
Xyz = 55 * R + 50 * G + 87 * B;    %/* CIE's (X + Y + Z) * 256 */
Xyzh = floor(Xyz ./ 2);
Xx = floor( (Xx * 100 + Xyzh) ./ Xyz);      %/* CIE's x * 100 = X/(X+Y+Z) * 100 */
Yy = floor( (Yy * 100 + Xyzh) ./ Xyz);      %/* CIE's y * 100 = Y/(X+Y+Z) * 100 */

%Defined numbers
XN	= 56;
XM	= 267;
YN	= 32;
YM	= 284;
		
Xx = Xx - XN;

Xx = Xx .* sign(sign(Xx)+1); %Sets all negative values to zero
Xx = Xx + (-Xx + (XM - XN)) .* sign(sign(Xx- (XM - XN))+1); %Sets any values above XM-XN to that value
%Sorry I know that is a bit of nasty code but it seems ok.

Yy = Yy - YN;

Yy = Yy .* sign(sign(Yy)+1); %Sets all negative values to zero
Yy = Yy + (-Yy + (YM - YN)) .* sign(sign(Yy- (YM - YN))+1); %Sets any values above XM-XN to that value

Picture_Data(:,1) = reshape(Xx,SizeofPic(1)*SizeofPic(2),1);
Picture_Data(:,2) = reshape(Yy,SizeofPic(1)*SizeofPic(2),1);
%Picture_Data(:,3) = 1:SizeofPic(1)*SizeofPic(2);

Uv = xy2uv( 253 * Xx + Yy + 1 );

%This may take a few works of explanation. To get the xy2uv function
%To work it _seemed_ necessary to only pass one matrix not two.
%This made it so it returned only one matrix and not some other
%weirdness. The function is passed the x and y in one number as a work
%around. Seems to work fine....

% The +1 fiddle factor is to compensate for the fact the c
% arrays start from (0,0) and the matlab matrix starts from (1,1)

VCHAN = floor(Uv ./ 256);
UCHAN = rem(Uv, 256); %The program does a similar thing - both the y and u
%channels are included in the Uv matrix and this separates them.

%Put the black back in from Black_Map
YCHAN = YCHAN .* (1 - Black_Map); %Sets intensity to zero
UCHAN = UCHAN + (44 - UCHAN) .* Black_Map; %Sets to predefined amounts.
VCHAN = VCHAN + (43 - UCHAN) .* Black_Map;

Pic_out(:,:,1) = uint8(YCHAN);
Pic_out(:,:,2) = uint8(UCHAN);
Pic_out(:,:,3) = uint8(VCHAN);

if print_output == 1
disp('Function pictoyuv Completed in:');
disp(cputime - pictoyuv_time_keeper);
end