%Title: batch_histogram(col_space,in_files,out_files)
%Author: Timothy Sheerman-Chase
%Date: 8 October 2000
%Description: This generates a SCDM histograms from source yuv files. The routine outputs
%the data in picture files for easy viewing. The routine also filters green for masking 
%purposes.
%
%Dependencies: 
%Arguments:
%col_space - This defines what colour space the program works in. (1 is YUV) (2 to HSV)
%in_files - This is the path to the picture files containing faces in the desired colour space
%out_files - This is the path to the output files - the scdm is written here.
%write_all_hists - Writes every histogram as a separate image.
%transform - if 1 then allows selection and use of a transform
%file_root - needed so routine knows location of files to process.

function batch_histogram(col_space,Files_to_open,out_files,write_all_hists,transform,file_root)

if nargin<1, error('Not enough inputs.'); end
if nargin==1
   out_files = 'C:/My Documents/matlab/pic_out/scdm';
end
if nargin<4, write_all_hists = 0; end;
if nargin<5, transform = 0; end;

SCDMy=zeros(1,256);

fprintf('\nCleared SCDM Matrix');

max_scdm_col=0; %Maximum value of frequency of a particular colour (for normalisation)
max_scdm_bri=0; %Maximum value of frequency of a particular intensity (for normalisation)

[null,number_of_files]=size(Files_to_open);

%This allows selection if lighting compensation (and what type) is applied to histogram build
if transform > 0,
	[transform_type,Parameters,StrPar,inverse] = choose_transform(file_root);
end

if col_space == 1 %Pic is yuv
	histogram_max=140;
else
	histogram_max=256;
end;

SCDMufvf=zeros(histogram_max,histogram_max); %This clears the memory ready for data to be written straight in

%%%%%%%%%%%%%%%%%%%%%
%This is the main file open loop
for l=1:number_of_files
   fid=0;

   %s=sprintf(in_files,l); %Edit as needed
   fid=fopen(getfield(Files_to_open,{l},'name'),'r');
   
   if fid>1 % This check if the file exists
      fclose(fid);
      fprintf('\nFound file: %s',getfield(Files_to_open,{l},'name'));
      
      Pic_in = imread((getfield(Files_to_open,{l},'name')),'png'); %Reads in yuv file
      size_Pic= size(Pic_in); 
      
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %The next section splits the three component colour space into a two
         % component colour array and an intensity array. This makes the later
         % parts of the program similar. For example YUV has the first component
         % as intensity while HSV has the last component as intensity. This just
         % makes all things equal.
         
   if col_space == 1 %Pic is yuv
            if transform > 0,
               Pic_in=perform_transform(Pic_in,transform_type,...
                  Parameters,StrPar,file_root,inverse);
            end
         col_data=zeros(size_Pic(1),size_Pic(2),2);
         col_data(:,:,1)= Pic_in(:,:,2);
         col_data(:,:,2)= Pic_in(:,:,3);
         intensity_data=zeros(size_Pic(1),size_Pic(2));
         intensity_data(:,:)= Pic_in(:,:,1);
         
      elseif (col_space == 2) | (col_space == 3)%Pic is hsv
         col_data=zeros(size_Pic(1),size_Pic(2),2);
         col_data(:,:,1)= Pic_in(:,:,1);
         col_data(:,:,2)= Pic_in(:,:,2);
         intensity_data=zeros(size_Pic(1),size_Pic(2));
         intensity_data(:,:)= Pic_in(:,:,3);
         
      elseif (col_space == 4) | (col_space == 5) %Others.
         col_data=zeros(size_Pic(1),size_Pic(2),2);
         col_data(:,:,1)= Pic_in(:,:,2);
         col_data(:,:,2)= Pic_in(:,:,3);
         intensity_data=zeros(size_Pic(1),size_Pic(2));
         intensity_data(:,:)= Pic_in(:,:,1);
         histogram_max=256;
      end
      
      %Done sorting out colours and intensities
      %%%%%%%%%%%%%%%%%%%%
      
		fprintf('\nUpdating SCDM');
      
      time_keeper = cputime; %This times the routine
      
      Colour_data = double(col_data(:,:,1))+ 1 + histogram_max .* double(col_data(:,:,2));
      %This is a work around I found. I need to pass one matrix to a function (hist)
      %but I have two numbers. I use a trick to combine the two numbers into one
      %and this can be passed fine. (Trust me)
      
      size_Colour_data = size(Colour_data);
      Reshaped_Colour_data = reshape(Colour_data,[1,(size_Colour_data(1).*size_Colour_data(2))]);
      %The histogram only likes 1D matrix inputs (I think). This arranges it.
      
      Histo_Colour = hist(Reshaped_Colour_data,1:histogram_max*histogram_max);
      %This does the actually work of building the histogram
      
      if col_space == 1 %Pic is yuv
      	Histo_Colour(histogram_max*67+18+1)= 0 ; %Mask green
         %This sets green (converted yuv space) to zero. Assume that there is no green.
      elseif col_space == 2
         [mask_x,mask_y,mask_z]=rgb2hsv(0,1,0);
      	Histo_Colour(histogram_max.*mask_y.*255+mask_x.*255+1)= 0 ; %Mask green
         %This sets green (converted hsv space) to zero. Assume that there is no green.
      elseif col_space == 3
      	Histo_Colour(histogram_max*255+0+1)= 0 ; %Mask green
         %This sets green (converted chromiticity space) to zero. Assume that there is no green. 
      elseif col_space == 4  
      	 Histo_Colour(histogram_max.*20+58+1)= 0 ; %Mask green        
      elseif col_space == 5  
      	 Histo_Colour(histogram_max.*54+34+1)= 0 ; %Mask green          
      end
      
      SCDMufvf = SCDMufvf + reshape(Histo_Colour,histogram_max,histogram_max);
      %This is a cumulative matrix for storing the progress.
      
      if write_all_hists == 1
         file_name_in = getfield(Files_to_open,{l},'name');
         [null,strl] = size(file_name_in);
			file_name_out = file_name_in;
         file_name_out(strl-12) = 'C';
         imwrite(uint8(reshape(Histo_Colour,histogram_max,histogram_max)),(file_name_out),'png');
         %Writes colour histogram
      end
      
      if col_space == 1 %Pic is yuv
      	Green_Map = 1 - ( sign(double(col_data(:,:,1))-18).^2 .* sign(double(col_data(:,:,2))-67).^2 );
      	%This generates a matrix with 1 where-ever there is a green pixel
      	%so it can be ignored in the intensity histogram.
      	%I can't think of doing it any other way.
      elseif col_space == 2
         Green_Map = 1 - ( sign(double(col_data(:,:,1))-85).^2 .* sign(double(col_data(:,:,2))-255).^2 );
      elseif col_space == 3 
         Green_Map = 1 - ( sign(double(col_data(:,:,1))-0).^2 .* sign(double(col_data(:,:,2))-255).^2 );
      elseif col_space == 4
         Green_Map = 1 - ( sign(double(col_data(:,:,1))-58).^2 .* sign(double(col_data(:,:,2))-20).^2 );
      elseif col_space == 5
         Green_Map = 1 - ( sign(double(col_data(:,:,1))-54).^2 .* sign(double(col_data(:,:,2))-34).^2 );
      end
         
      Intensity_data = double(intensity_data(:,:))+ 1 + 300 .* Green_Map;
      %Ok this copies the data to a new matrix and sets the green 
      %Pixels intensity to 300 (which is too high normally - but it stands out
      %imagesc(Intensity_data); colorbar; pause;
      
      size_Intensity_data = size(Intensity_data); 
      Reshaped_Intensity_data = reshape(Intensity_data,[1,(size_Intensity_data(1).*size_Intensity_data(2))]);
      %Same as before - hist only likes 1D input
      
      Histo_Intensity = hist(Reshaped_Intensity_data,1:300);
      Histo_Intensity = Histo_Intensity(1:256);
      %This just takes the range from 1-256 so ignores 300 entries and
      %therefore the green pixels
      
      SCDMy = SCDMy + Histo_Intensity;
      %This builds up the overall histogram
      
      %max_val=max(max(SCDMufvf))
      %imagesc(SCDMufvf./max_val);
      %pause;
      
      % #This shows that the program is actually doing something
      fprintf('\nHave processed the file: %s',getfield(Files_to_open,{l},'name'));
      
    fprintf('\nTime taken in picture processing: %f',cputime - time_keeper);

end %End of file exist loop
end %End of file opener loop

if transform > 0
   figure(1); imagesc(SCDMufvf);
   smooth = input('Do you want to smooth histogram? (0/1)');
   if smooth == 1
      filt = [0.5 1 0.5; 1 2 1; 0.5 1 0.5;];
      SCDMufvf = filter2(filt,SCDMufvf);
   end
end

max_scdm_bri =max(SCDMy);%Checks max values for normalisation
max_scdm_col = max(max(SCDMufvf));

fprintf('\nCreating SCDM image. Scdm max frequency: %f',max_scdm_col);


      SCDMpic(:,:,1)= uint8(SCDMufvf(:,:) * 255 ./ max_scdm_col); %Writes histogram to file as red
      %SCDMpic(:,:,2)= uint8(0);
      %SCDMpic(:,:,3)= uint8(0); %No green or blue
      
fprintf('Scdm intensity max frequency: %f',max_scdm_bri);

%clear SCDMpic2; SCDMpic2 = zeros (256,256,3);

SCDMy = SCDMy .* 255 ./ max_scdm_bri;

SCDM_number = input('What number to save as? (usually save as data set!)','s');
out_file_name = sprintf('%sWorkspace\\intensity%s.dat',file_root,SCDM_number);
out_file_fid = fopen(out_file_name,'w');
fwrite(out_file_fid, SCDMy(:),'float32');
fclose(out_file_fid);

out_file_name = sprintf('%sWorkspace\\scdm%s.png',file_root,SCDM_number)
imwrite(SCDMpic,(out_file_name),'png'); %Writes colour histogram

figure(1); imagesc(SCDMpic); colorbar;
figure(2); plot(SCDMy);

%disp('Hit any key');
pause(1);
