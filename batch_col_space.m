
%Title: batch_col_space(col_space,in_files,out_files)
%Author: Timothy Sheerman-Chase
%Date: 8 October 2000
%Description: This m file is designed to open files and feel them to the pictoyuv routine.
%This is usually the first step in building an SCDM as you need a lot of pixels.
%This outputs rgb files into the yuv perceptionally uniform colour space.
%
%Dependencies: pictoyuv.m  rgb2yuv_init.m
%Arguments:
%col_space - This defines what colour space the program works in. (1 is YUV) (2 to HSV) etc
%in_files - This is the path to the masked picture files containing faces
%out_files - This is the path to the output files - the output is pictures in the new colour space

function batch_col_space(col_space,Files_to_open,Files_yuv)

if nargin<2, error('Not enough inputs.'); end

[null,number_of_files]=size(Files_to_open);

%%%%%%%%%%%%%%%%%%%%%
%This is the main file open loop
for l=1:number_of_files
   fid=0;

   %s=sprintf(in_files,l); %Edit as needed
   fid=fopen(getfield(Files_to_open,{l},'name'),'r');
   
   if fid>1 % This check if the file exists
      fclose(fid);
      disp('Found file:');
      disp(getfield(Files_to_open,{l},'name'));
      
      %Reads in an rgb file
      
      Pic_rgb = imread(getfield(Files_to_open,{l},'name'));
      
      %The picture is read in rgb and this converts it into the selected colour space.
      if col_space == 1 %YUV
      	Pic_out = pictoyuv_opt(Pic_rgb);
      elseif col_space == 2 %HSV
         Pic_in = double(Pic_rgb) ./ 255;
			Pic_out = rgb2hsv(Pic_in);
         %imagesc(Pic_out);
      elseif col_space == 3 %Chromatic Space
         Pic_out = Pic_rgb;
         Pic_out(:,:,3) = (double(Pic_rgb(:,:,1)) + double(Pic_rgb(:,:,2)) + double(Pic_rgb(:,:,3))) ./ 3;
         %Black_Map = 1 - sign(double( Pic_rgb(:,:,3) )-0).^2;
         %Pic_out(:,:,3) = double(Pic_out(:,:,3)) + Black_Map;
         Pic_out(:,:,1) = 255 .* double(Pic_rgb(:,:,1)) ./ (3 .* double(Pic_out(:,:,3)) );
         Pic_out(:,:,2) = 255 .* double(Pic_rgb(:,:,2)) ./ (3 .* double(Pic_out(:,:,3)) );
      elseif col_space == 4

			%disp(max(max(Pic_out)));
         %disp(min(min(Pic_out)));
         Pic_in = double(Pic_rgb) ./ 255;
			Pic_out = rgb2ntsc(Pic_in);
            Pic_out(:,:,2) = Pic_in(:,:,2)+ .5;
            Pic_out(:,:,3) = Pic_in(:,:,3)+ .6;
			%disp(max(max(Pic_out)));
         %disp(min(min(Pic_out)));
         %imagesc(Pic_out);  
         %pause;
      elseif col_space == 5
         Pic_in = double(Pic_rgb) ./ 255;
			Pic_out = rgb2ycbcr(Pic_in);
         %imagesc(Pic_out);
      end
      
      %Writes data to a yuv file.
      
      imwrite(Pic_out,(Files_yuv(l).name),'png');
   	disp('Written file:');
      disp(Files_yuv(l).name);
      
   end %End if fid>1
   
end %End file opener loop
