
%Title: Chart statistics
%Author: Timothy Sheerman-Chase
%Date: 08 Feb 2001
%Description: This takes a list of images and passes them to the chart_find
%function to find the colour averages in the calibration chart. The program then
%thakes an average of the results and writes it into a data file.
%Dependencies: chart_find
%Arguments:
%Files_to_open - file of chart images to process
%out_file_name - location of data file to write average into
%file_root - location of file's directory
%chart_type - Type of chart in images (eg A,B,C.. etc)

function chart_stats(Files_to_open,out_file_name,file_root,chart_type)

Chart_read = pictoyuv_opt(imread(sprintf('%sWorkspace\\colour_chart%s.png',file_root,chart_type)));
Mask_read = imread(sprintf('%sWorkspace\\colour_chart_mask%s.png',file_root,chart_type));

Mask = double(Mask_read(:,:,1));
number_of_cols = max(max(Mask .* (Mask < 255)))
[size_x,size_y] = size(Chart_read);

%This looks that the chart image and works out the typical colours contained in each region
for loop = 1:number_of_cols,
   Single_col_U = double(Chart_read(:,:,2)) .* (loop == Mask);
   Single_col_V = double(Chart_read(:,:,3)) .* (loop == Mask);
   total_U = sum(sum(Single_col_U));
   total_V = sum(sum(Single_col_V));
   pixels = sum(sum(loop == Mask));   
   average_U = total_U ./ pixels;
   average_V = total_V ./ pixels;
   fprintf('\nColour %i - U: %f V: %f',loop,average_U,average_V);
   Points(loop,1) = average_U;
   Points(loop,2) = average_V;
end;

data_collected = zeros(number_of_cols,2);
files_opened = 0;

%%%%%%%%%%%%%%%%%%%%%
%This is the main file open loop
[null,number_of_files]=size(Files_to_open);
for l=1:number_of_files
   fid=0;

   %s=sprintf(in_files,l); %Edit as needed
   fid=fopen(getfield(Files_to_open,{l},'name'),'r');
   
   if fid>1 % This check if the file exists
      fclose(fid);
      fprintf('\nFound file: %s', getfield(Files_to_open,{l},'name') );

      Pic_rgb = imread(getfield(Files_to_open,{l},'name'));
      Pic_yuv = pictoyuv_opt(Pic_rgb);
      
      chart_results = chart_find(Pic_yuv,0,20,Chart_read,Mask_read);
      dist = 0;
      for loop = 1:number_of_cols, %Works out if the colours observed as like the expected colours
         dist = dist + (chart_results(loop,1)-Points(loop,1)).^2 ...
            + (chart_results(loop,2)-Points(loop,2)).^2;
         
      end
      dist = dist ./ number_of_cols;
      
      fprintf('\nMatch Distance = %f',dist);
      
      if dist < 400, %this is meant to reject bad fits but not sure if it is a good idea.

      data_collected = data_collected + chart_results;
      pause(2);
		files_opened = files_opened +1;
   	else
         fprintf('\nChart not found... probably too small (or big).');
         pause(5);
      end
      
   end;
   
   
end;
fprintf('\n');
data_collected = data_collected ./ files_opened;
disp (data_collected);

%Writes data to a file
if nargin<2,
	out_file_name = 'C:\My Documents\Matlab\chart_reading.dat';
end;
out_file_fid = fopen(out_file_name,'w');
fwrite(out_file_fid, data_collected,'float32');
fclose(out_file_fid);

