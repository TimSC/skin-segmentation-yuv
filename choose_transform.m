%Title: Allows user to choose transform and its properties
%Author: Timothy Sheerman-Chase
%Date: 15 Feb 2001
%Description: 
%
%
%Arguments:
function [transform_type,Parameters,StrPar,inverse] = choose_transform(file_root)

   %This allows the choice of the particular lighting compensation method.
   fprintf('\n1: Gaussian Fit Transform');
   fprintf('\n2: Reference Point Morph Transform');
   fprintf('\n3: General Linear Transform');
   transform_type = input('\nChoose:');
   
   if transform_type == 1 %This approximated the histogram as a Gaussian and then transforms
      % the gaussian onto the region of the second target gaussian.
			StrPar(1).text = input('What starting hist distro (003, etc)?','s');
         StrPar(2).text = input('What target hist distro (003, etc)?','s');
         inverse = 0;
         Parameters = 0;
   end
   if transform_type == 2,
      %This is the morph style transform. Still under test.
      inverse = input('Use inverse transform? (0/1): ');
      chart_type = input('Use what type of chart? (A,B,C..): ','s');
      chart_num1 = input('What starting ref points? (eg 006) (000 to read chart from input): ','s');
      chart_num2 = input('What finish ref points? (eg 009): ','s');
      
      if chart_num1 ~= '000' %if is == 000 then it reads chart of images separatly
         
         %Using chart average for entire set
         Points1_name = sprintf('%sWorkspace\\Chart%s%s.dat',...
            file_root,chart_type,chart_num1); %Reads in chart data
         Points2_name = sprintf('%sWorkspace\\Chart%s%s.dat',...
            file_root,chart_type,chart_num2);
         
         in_file = fopen(Points1_name,'r');
         Points1 = fread(in_file, inf, 'float32'); %Reads in chart data
         fclose(in_file);
         
         in_file = fopen(Points2_name,'r');
         Points2 = fread(in_file, inf, 'float32');%Reads in chart data
         fclose(in_file);
         
         [no_of_points1,null]=size(Points1);
         [no_of_points2,null]=size(Points2);
         if no_of_points1 == no_of_points2, %Checks to see if the number of points match
            fprintf('\nRead in charts ....ok');
         else
            fprintf('\nError: No. of point in two charts must match!');
         end;
         
         Parameters(:,1)= Points1([1:no_of_points1./2]); %Arranges data into easy form
         Parameters(:,2)= Points1([(no_of_points1./2)+1:no_of_points1]);
         Parameters(:,3)= Points2([1:no_of_points1./2]);
         Parameters(:,4)= Points2([(no_of_points1./2)+1:no_of_points1])
      else
         Points2_name = sprintf('%sWorkspace\\Chart%s%s.dat',... %Sets up to read chart from input images one by one
            file_root,chart_type,chart_num2);  
         in_file = fopen(Points2_name,'r');
         Points2 = fread(in_file, inf, 'float32');
         fclose(in_file);
         [no_of_points2,null]=size(Points2);
         Parameters(:,3)= Points2([1:no_of_points2./2]);
         Parameters(:,4)= Points2([(no_of_points2./2)+1:no_of_points2])
      end

      StrPar(1).text = chart_num1;
      StrPar(2).text = chart_type;
   end
   
   if transform_type == 3,%General Linear Transform
      StrPar(1).text = input('Use what type of chart? (A,B,C..): ','s');
      StrPar(2).text = input('Which data set to work towards? (003, etc)','s');
      Parameters = 0;
      inverse = 0;
   end
   