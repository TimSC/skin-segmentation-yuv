
%Title: Perform Transform
%Author: Timothy Sheerman-Chase
%Date: 15 Feb 2001
%Description: Takes user selection in transform_type and Parameters and converts picture
%by passing it and specific details to another rountine. This does very little except mess
%about with arguments.
%Arguments:

function Pic_in = perform_transform(Pic_in,transform_type,Parameters,StrPar,file_root,inverse);

%%%%%%%%%%%%%%%%
% This performed the desired lighting compensation
if transform_type == 1 %Gaussian Fit
      Pic_in = trans(Pic_in,18,67,...
         sprintf('%sWorkspace\\gaussian%s.dat',file_root,StrPar(1).text) ,...
         sprintf('%sWorkspace\\gaussian%s.dat',file_root,StrPar(2).text) ); 
end;

if transform_type == 2 % Morph transform   
   fprintf('\nDoing ref point transform');
   %disp(Parameters);
   %disp(inverse);
   %pause;
   
   if StrPar(1).text ~= '000', %Using data set average for colour chart readings
   	Pic_in = reftrans(Pic_in,18,67,Parameters,inverse);
   
	else %Reading colour chart off input image.
   	Chart_rgb= imread( sprintf('%sWorkspace\\colour_chart%s.png',file_root,StrPar(2).text) );
		Mask_pic= imread( sprintf('%sWorkspace\\colour_chart_mask%s.png',file_root,StrPar(2).text) );
      
      New_points = chart_find(Pic_in,0,20,pictoyuv_opt(Chart_rgb),Mask_pic);
      Parameters(:,1) = New_points(:,1);
      Parameters(:,2) = New_points(:,2)
   end
   
   fprintf('.... done.');
end;

if transform_type == 3 % General Linear Transform

   Chart_rgb= imread( sprintf('%sWorkspace\\colour_chart%s.png',file_root,StrPar(1).text) );
   Mask_pic= imread( sprintf('%sWorkspace\\colour_chart_mask%s.png',file_root,StrPar(1).text) );
   
   in_file_name = sprintf('%sWorkspace\\Chart%s%s.dat',file_root,StrPar(1).text,StrPar(2).text);
   in_file = fopen(in_file_name,'r');
   Points_read = fread(in_file, inf, 'float32'); %Reads chart typical colours
   [file_entrys,null]=size(Points_read);
   Points_actual([1:file_entrys./2],1) = Points_read([1:file_entrys./2]);
   Points_actual([1:file_entrys./2],2) = Points_read([(file_entrys./2)+1:file_entrys]);
   
   fclose(in_file);
   
   Par = lsfit(chart_find(Pic_in,0,20,pictoyuv_opt(Chart_rgb),Mask_pic),Points_actual)
   %Par = [0.7643   -0.1704   -0.0241    0.9449   15.5927   -0.3350]
   Pic_in = lintrans(Pic_in,18,67,Par,0);
end;
