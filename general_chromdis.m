
%Title: general_chromdis.m
%Author: Timothy Sheerman-Chase
%Date: 9 October 2000
%Description: This files takes the SCDM colour histogram and calculated the average and covariance. There may
%be a neater way to do this but I don't know it.
%
%Dependencies: 

function [covar,rotation] = general_chromdis(in_file_name,write_data_to_file,out_file_name);

if nargin<1, in_file_name = 'scdm.png'; end
if nargin<2, write_data_to_file = 0; end
if nargin<3, out_file_name = 'C:\My Documents\matlab\Workspace\scdm.dat'; end

SCDM_data = imread(in_file_name); %reads the colour histogram
%SCDM_y_data = imread('scdm2.png','png'); %Reads the intensity histogram

size_SCDM_data = size(SCDM_data); 
Np = 0; %Total number of frequencies of all colours.
for x = 1:size_SCDM_data(1) %This loops through the intensity histogram and takes out the data for later use.
   for y = 1:size_SCDM_data(2)
		Np = Np + double(SCDM_data(x,y)); %Adds number of frequencies to running total
   end
end
fprintf('\nCounting total frequencies in colour histogram. \nTotal of frequencies=%u',Np)

%Effectively we have a histogram and this onverts it into a list with the correct 
%frequency of each thing.
pixels_written=0;
for x = 1:size_SCDM_data(1)
   for y = 1:size_SCDM_data(2)
      for loop = 1:double(SCDM_data(x,y))
         pixels_written = pixels_written + 1;
         chrmdata(pixels_written,1) = x;
         chrmdata(pixels_written,2) = y;
		end
   end
end

%Works out statistical information
covar = cov(double(chrmdata));
fprintf ('\nCovariance Matrix\n');
disp(covar);


x_av=mean(chrmdata(:,1));
fprintf('Average x (u) = %f',x_av);

y_av = mean(chrmdata(:,2));
fprintf('\nAverage y (v) = %f',y_av);

x_sdev = std(chrmdata(:,1));
fprintf('\nStandard Deviation x (u) = %f',x_sdev);

y_sdev=std(chrmdata(:,2));
fprintf('\nStandard Deviation y (v) = %f\n',y_sdev);

[rotation,null] = eig(covar);

disp('Rotation Matrix');
disp(rotation);

if write_data_to_file == 1 %Saves information to a file
	out_file_fid = fopen(out_file_name,'w');
   fwrite(out_file_fid, rotation,'float32');
   fwrite(out_file_fid, x_av,'float32');
   fwrite(out_file_fid, y_av,'float32');
   fwrite(out_file_fid, x_sdev,'float32');
   fwrite(out_file_fid, y_sdev,'float32');
   fwrite(out_file_fid, covar,'float32');
	fclose(out_file_fid);
end;
