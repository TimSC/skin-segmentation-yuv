
%Title: List Directories
%Author: Timothy Sheerman-Chase
%Date: 15 Feb 2001
%Description: Internals of file selection routines
%
%
%Arguments:

function Output = list_dirs(dir_current)

if nargin == 0, dir_current = cd; end

if exist(dir_current,'dir') == 0
   error('Directory does not exist.')   
end
	Output(1).name = 'null';

Listing = dir(dir_current);
[no_of_files,null] = size(Listing);

dirs_found = 1;

for loop = 1:no_of_files
   if Listing(loop).isdir == 1
      if (strcmp(Listing(loop).name,'.')==0) & (strcmp(Listing(loop).name,'..')==0)
     		Listing(loop).name = strcat( '\' , getfield(Listing,{loop},'name') );
      	Output(dirs_found).name = strcat( dir_current, getfield(Listing,{loop},'name'));
         dirs_found = dirs_found +1;
   	end
   end
end
