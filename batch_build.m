
%Title: Face Batch Runner
%Author: Timothy Sheerman-Chase
%Date: 25 Jan 2001
%Description: This runs the routines to build a histogram and then attempt to detect
% facial regions. A nice GUI might replace this program one day.
%Dependencies: Most of the routines (sorry can't list all!)
%Arguments: None

fprintf('\nWelcome to Face Batch Runner\n');

	col_space = 1;
   continue = 1;
   data_set='001';
   file_root = which('batch_build.m');
   [null,size_file_root] = size(file_root);
   file_root = file_root(1:size_file_root-13);
   scdm_files = sprintf('%sWorkspace\scdm',file_root);
   found_some_files = 0;
   found_raw_files = 0;
   model_uv_hist = 0;
   clear Files_to_open; clear Files_colspace;
   clear RAWFiles_to_open; clear RAWFiles_probmaps;
   
   %Main program loop. While the program is running it is always inside this continue loop
   while continue == 1,
      %Display Main Menu
      fprintf('\n1. Set colour space (currently %i).',col_space);
      fprintf('\n2. Choose data set (currently %s).', data_set);
      fprintf('\n3. Find Images to Process');
      fprintf('\n   3a Display Files');
      fprintf('\n   3b Clear File List');
      fprintf('\n4. Convert Masked Images to Alternate Colour Space');
      fprintf('\n5. Generate Histogram');
      fprintf('\n6. View/Change Histogram');
      fprintf('\n   6a. Write Gaussian Info to File');
      fprintf('\n7. Find Files for Face Detect');
      fprintf('\n   7a Display Files');
      fprintf('\n   7b Clear File List');
      fprintf('\n8. Detect Faces');
      fprintf('\n9. Get Colour Chart Stats');
      fprintf('\nA. Get performance details');
      fprintf('\n0. Quit.');
      fprintf('\nNote: 1 = Yes and 0 = No');
      in = input('\nEnter Choice:','s');
      
      switch in
      case '1' %Choose colour space (only YUV is fully done)
         fprintf('\nWhat Colour Space To Use?');
         fprintf('\nNOTE: Only parts of this are implimented so far..');
			fprintf('\n1. YUV');
			fprintf('\n2. HSV');
			fprintf('\n3. Chromatic Space');
			fprintf('\n4. NTSC/YIQ');
			fprintf('\n5. YCBCR color space');
			col_space=input('\nEnter selection:');
      case '2' %Chosee which data set to operate on
         data_set = input('\nWhich Data Set?','s');
         if found_some_files + found_raw_files > 0, %Allows deleting file lists
            wipe_file_list = input('\nForget files selected? (0/1)');
            if wipe_file_list == 1,
   				found_some_files = 0;
   				found_raw_files = 0;
   				clear Files_to_open; clear Files_colspace;
               clear RAWFiles_to_open; clear RAWFiles_probmaps; 
            end;
         end;
         
      case '3' %Do a search for files to operate on
         if found_some_files == 0,
            Files_to_open(1).name = 'null';
            Files_colspace(1).name = 'null';
            
            [Files_to_open,Files_colspace] = data_list_ver2('B',data_set,'E',Files_to_open,Files_colspace,file_root,'F');
            %[Files_to_open,Files_colspace] = data_list_ver2('B',data_set,'E',Files_to_open,Files_colspace);
         	found_some_files = 1;
      	else
            [Files_to_open,Files_colspace] = data_list_ver2('B',data_set,'E',Files_to_open,Files_colspace,file_root,'F');            
         end   
      case '3a'%Display file list
         if found_some_files == 1,
         	[null,number_files] = size(Files_to_open);
         	for loop =1:number_files,
         	fprintf('\nFound file: %s', getfield(Files_to_open,{loop},'name') );   
         	end
         else
            fprintf('\nNo file list generated yet!');
         end
      case '3b' %Clear File list
         found_some_files = 0;
         clear Files_to_open;
         clear Files_colspace;
      case '4' %Convert images to chosen colour space
         if found_some_files == 0,
            Files_to_open(1).name = 'null';
            Files_colspace(1).name = 'null';
         	[Files_to_open,Files_colspace] = data_list_ver2('B',data_set,'E',Files_to_open,Files_colspace,file_root,'F');
            found_some_files = 1;
         end;
         batch_col_space(col_space,Files_to_open,Files_colspace);
      case '5' %Generate histogram from images
         if found_some_files == 0,
            Files_to_open(1).name = 'null';
            Files_colspace(1).name = 'null';
         	[Files_to_open,Files_colspace] = data_list_ver2('B',data_set,'E',Files_to_open,Files_colspace,file_root,'F');
            found_some_files = 1;
         end;        
      	write_all_hists = input('Write all histograms to disk? (1/0)?');
      	transform = input('Apply transforms to histogram build? ');
      	batch_histogram(col_space,Files_colspace,scdm_files,write_all_hists,transform,file_root);         
      case '6' %Display stat info about scdm
         which_scdm = input('\nWhich scdm to consider (eg 002)?','s');
         general_chromdis(sprintf('%sWorkspace\\scdm%s.png',file_root,which_scdm), 0);
         model_uv_hist = input('(Broken atm...) Shall I model the uv space histogram? (1/0)?');
   		display_hist = input('Display Histogram Zoomed (1/0)?');
         %analyse_hists = input('Analyse Histograms? (1/0)?');
         %if analyse_hists == 1
         %     Hists(1).name = 'null';
         %     null(1).name = 'null';
      	% 	  [Hists,null] = data_list_ver2('C',data_set,'X',Hists,null,file_root);
       	%	  analyse_histograms(Hists);
         %end
   		if model_uv_hist == 1
      		fit_curve(sprintf('%s.png',scdm_files),1,sprintf('%s_model.png',scdm_files));
      		if display_hist_surface == 1
					view_scdm(sprintf('%s_model.png',scdm_files));
				end  
         end
         if display_hist == 1,
            view_scdm(sprintf('%sWorkspace\\scdm%s.png',file_root,which_scdm));
         end
      case '6a' %Write scdm info to file from gaussian approximation
         which_scdm = input('\nWhich scdm to consider (eg 002)?','s');
         general_chromdis(sprintf('%sWorkspace\\scdm%s.png',file_root,which_scdm), 1,...
            sprintf('%sWorkspace\\gaussian%s.dat',file_root,which_scdm));
      case '7' %Find files for detection
         if found_raw_files == 0,
            RAWFiles_to_open(1).name = 'null';
            RAWFiles_probmaps(1).name = 'null';
            
            [RAWFiles_to_open,RAWFiles_probmaps] = data_list_ver2('A',data_set,'D',RAWFiles_to_open,RAWFiles_probmaps,file_root);
         	found_raw_files = 1;
      	else
            [RAWFiles_to_open,RAWFiles_probmaps] = data_list_ver2('A',data_set,'D',RAWFiles_to_open,RAWFiles_probmaps,file_root);            
         end   
     case '7a' %Display files found for face detection
         if found_raw_files == 1,
         	[null,number_files] = size(RAWFiles_to_open);
         	for loop =1:number_files,
         	fprintf('\nFound file: %s', getfield(RAWFiles_to_open,{loop},'name') );   
         	end
         else
            fprintf('\nNo file list generated yet!');
         end
      case '7b' %Clear list of files
         found_raw_files = 0;
         clear RAWFiles_to_open;
         clear RAWFiles_probmaps;
      case '8' %Detect faces
         if found_raw_files == 0;
            RAWFiles_to_open(1).name = 'null';
            RAWFiles_probmaps(1).name = 'null';
         	[RAWFiles_to_open,RAWFiles_probmaps] = data_list_ver2('A',data_set,'D',RAWFiles_to_open,RAWFiles_probmaps,file_root);
         	found_raw_files = 1;         	   
         end
         
   			display_progress = input('Output faces to 1) Screen or 0) File?');  
      		use_intensity_hist = input('Use Intensity Histogram (1/0)?');
      		transform_face = input('Apply transforms to face detect (1/0)? ');
   
   		if (model_uv_hist == 0) %Do recognition with non approxiamted scdm
            batch_getface(col_space,display_progress,use_intensity_hist,scdm_files,...
               RAWFiles_to_open,RAWFiles_probmaps,transform_face,file_root); 
   		elseif (model_uv_hist == 1) %I am not even sure this works.. its so long since i ran this bit!
      		in_file = fopen(sprintf('%s2.dat',scdm_files),'r');
				temp_read = fread(in_file, inf, 'float32');
      		fclose(in_file);
      		out_file_fid = fopen(sprintf('%s_model2.dat',scdm_files),'w');
				fwrite(out_file_fid, temp_read,'float32');
      		fclose(out_file_fid);
            batch_getface(col_space,display_progress,use_intensity_hist,...
               sprintf('%s_model',scdm_files),RAWFiles_to_open,RAWFiles_probmaps,...
               transform_face,file_root);
         end
      case '9' %Scan files for finding average chart values
         chart_type = input('Chart type (A,B,C,etc)?','s');
         if found_raw_files == 0;
            RAWFiles_to_open(1).name = 'null';
            RAWFiles_probmaps(1).name = 'null';
         	[RAWFiles_to_open,RAWFiles_probmaps] = data_list_ver2('A',data_set,'D',RAWFiles_to_open,RAWFiles_probmaps,file_root);
         	found_raw_files = 1;         	   
         end
         chart_stats(RAWFiles_to_open,sprintf('%sWorkspace/Chart%s%s.dat',file_root,chart_type,data_set),file_root,chart_type );
      case 'A' %Check performance of method by comparing probability images to mask files
         if found_raw_files == 0;
            RAWFiles_to_open(1).name = 'null';
            RAWFiles_probmaps(1).name = 'null';
         	[RAWFiles_to_open,RAWFiles_probmaps] = data_list_ver2('A',data_set,'D',RAWFiles_to_open,RAWFiles_probmaps,file_root);
         	found_raw_files = 1;         	   
         end
         Mask_files = RAWFiles_probmaps;
         [null,number_files] = size(Mask_files);
         
         for loop =1:number_files,
            [null,strlen] = size (getfield(Mask_files,{loop},'name'));
            if strlen > 13,
           		Mask_files(loop).name(strlen-12) = 'F';
            end
         end
         	
         
         check_perform(RAWFiles_probmaps,Mask_files);
      case '0' %Quits the program by stopping the while loop
         continue =0;
      end
      
      
   end%End of while loop
   

   fprintf('\nAll done!\n');
