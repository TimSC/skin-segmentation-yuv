%Title: Gaussian Approx. Transform
%Author: Timothy Sheerman-Chase
%Date: 25 Jan 2001
%Description: This maps the region described by one gaussian SCDM onto
% the region described by a second gaussian.
%I guess you could say it follows the method described in Matt Maylin's project. :)
%
%
%Dependencies: 

function Pic_out = trans(A,mask_x,mask_y,in_file_name,in_file_name2)

%Reads in parameters of one gaussian shape
%in_file_name = sprintf('C:\\My Documents\\matlab\\Workspace\\scdm%s.dat',trans1);
in_file = fopen(in_file_name,'r');
rotation1= fread(in_file, [2 2],'float32');
x_av1= fread(in_file, 1,'float32');
y_av1= fread(in_file, 1,'float32');
x_sdev1= fread(in_file, 1,'float32');
y_sdev1= fread(in_file, 1,'float32');
covar1= fread(in_file, [2 2],'float32')
fclose(in_file);

%Reads in parameters of second gaussian shape
%in_file_name2 = sprintf('C:\\My Documents\\matlab\\Workspace\\scdm%s.dat',trans2);
in_file = fopen(in_file_name2,'r');
rotation2= fread(in_file, [2 2],'float32');
x_av2= fread(in_file, 1,'float32');
y_av2= fread(in_file, 1,'float32');
x_sdev2= fread(in_file, 1,'float32');
y_sdev2= fread(in_file, 1,'float32');
covar2= fread(in_file, [2 2],'float32')
fclose(in_file);

%figure(10);subplot(2,2,1);imagesc(A);
%A(1,1,1) = 1;
%A(1,1,2) = 2;
%A(1,1,3) = 2;

%imagesc(A);

X = double(A(:,:,2));
Y = double(A(:,:,3));

%Generates matrix to say what should not be changes
if nargin>1, back_mask = (X == mask_x) .* (Y == mask_y); 
%  figure(10);subplot(2,2,3);imagesc(back_mask);
end;

x_mod = 57;%input('Move X by :-');
y_mod = 54;%input('Move Y by :-');

%Performs translation on entire picture
X = X - x_av1;
Y = Y - y_av1;

%Applies rotation matrix to entire picture.
X_new = X .* rotation1(1,1) + Y * rotation1(2,1);
Y_new = X .* rotation1(1,2) + Y * rotation1(2,2);
%X_new = X .* 0 + Y * 1;
%Y_new = X .* 1 + Y * 0;


%Uses covariance to scale the distribution correctly
	X_new = X_new .* covar2(1,1).^0.5 ./ covar1(1,1).^0.5;
	Y_new = Y_new .* covar2(2,2).^0.5 ./ covar1(2,2).^0.5;


fprintf('\nRatio X=%f Y=%f',covar2(1,1)./ covar1(1,1),covar2(2,2) ./ covar1(2,2));
fprintf('\nSQRT Ratio X=%f Y=%f',covar2(1,1).^0.5 ./ covar1(1,1).^0.5,covar2(1,1).^0.5 ./ covar1(1,1).^0.5);

rotation2 = rotation2';

%Applies rotation matrix of second gaussian to entire picture
X = X_new .* rotation2(1,1) + Y_new * rotation2(2,1);
Y = X_new .* rotation2(1,2) + Y_new * rotation2(2,2);

%Translates entire pic to position of second gaussian
X = X + x_av2;
Y = Y + y_av2;

%Checks boundaries for invalid data.
X = (X >= 0) .* X;
Y = (Y >= 0) .* Y;
X = X + (255 - X).*(X >= 255);
Y = Y + (255 - Y).*(Y >= 255);

%Use back_mask to replace some areas with original colour. Used for keeping mask colour constant.
if nargin>1
   A(:,:,2) = uint8(X + (double(A(:,:,2)) - X) .* back_mask );
	A(:,:,3) = uint8(Y + (double(A(:,:,3)) - Y) .* back_mask );
else
	A(:,:,2) = uint8(X);
	A(:,:,3) = uint8(Y);
end

Pic_out = A;
fprintf('\nTransformed Image\n');
%figure(10);subplot(2,2,2);imagesc(Pic_out);
%pause;