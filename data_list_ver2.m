%Title: Data Files List Ver 2
%Author: Timothy Sheerman-Chase
%Date: 15 Feb 2001
%Description: This searches through the Workspace foler for images to transform
%
%
%Arguments:

function [Files_to_open,Files_colspace] = data_list_ver2(file_type,data_set,out_ex,Files_to_open,Files_colspace,file_root,file_type2)

if nargin<1, file_type = 'B'; end%Sets defaults
if nargin<2, data_set = '006'; end
if nargin<3, out_ex = 'D'; end
if nargin<4, 
   files_so_far = 1;
   Files_to_open(1).name = 'null';
else
   [null,files_so_far] = size(Files_to_open);
   files_so_far = files_so_far +1;
end

disp(file_root);
Data_dirs = dir_tree(sprintf('%sWorkspace',file_root));

[null,no_of_dirs] = size(Data_dirs);
clear Filelist;Filelist = list_files('.png');

fprintf('\n Searching for files.....');

for loop = 1 : no_of_dirs %Gets sub folders to check out recursively
   if strcmp(getfield(Data_dirs,{loop},'name'),'null') == 0
		Filelist = list_files('.png', getfield(Data_dirs,{loop},'name'), Filelist);   
   end
end

string_match = sprintf('%s%s-',file_type,data_set);

fprintf('\n Found some files. Now sorting... \n%s',string_match);

%%%%%%%%%%%%%%%%%%%
% How we have some files we sort though to find the desired type

[null,number_files] = size(Filelist);
for loop = 1: number_files,
   [null,strl] = size(Filelist(loop).name);
   if strl > 14,
      if( strcmp(Filelist(loop).name(strl-12:strl-8),string_match) == 1),
         Files_to_open(files_so_far).name = Filelist(loop).name;
         %fprintf('\n%s',Filelist(loop).name);
         files_so_far = files_so_far + 1;
      end;
      
      if nargin>6,
         string_match2 = sprintf('%s%s-',file_type2,data_set);
      	if( strcmp(Filelist(loop).name(strl-12:strl-8),string_match2) == 1),
      	   Files_to_open(files_so_far).name = Filelist(loop).name;
      	   %fprintf('\n%s',Filelist(loop).name);
      	   files_so_far = files_so_far + 1;
      	end; 
      end
   end;

end

%Desired files now selected
%%%%%%%%%%%%%%%%

[null,number_files] = size(Files_to_open);
fprintf('\nFound %i files\n',number_files);

Files_colspace = Files_to_open;
for loop = 1:number_files, %Works out file names for after the images have been transformed
   [null,strl] = size(Files_colspace(loop).name);
   if(strl > 13)
   	Files_colspace(loop).name(strl-12) = out_ex;
   	%fprintf('\n%s',Files_colspace(loop).name);
   else
      Files_colspace(loop).name = 'null';
	end

end;

fprintf('\n');