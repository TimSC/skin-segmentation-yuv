%Title: Directory Tree
%Author: Timothy Sheerman-Chase
%Date: 15 Feb 2001
%Description: Internals of file selection routines
%
%
%Arguments:

function Output = dir_tree(dir_current,Output)

if nargin == 0, dir_current = cd; end
if nargin<2, Output(1).name = 'null'; end

if exist(dir_current,'dir') == 0
   error('Directory does not exist.')   
end

New_dirs = list_dirs(dir_current);

[null,size_New_dirs] = size(New_dirs);
[null,size_Output] = size(Output);

if (strcmp(New_dirs(1).name,'null') == 0 | size_New_dirs > 1)
   for loop = 1: size_New_dirs
		%disp(New_dirs(loop).name);

      is_this_in_list = 0;
      for loop2 = 1:size_Output
         %disp('Compare');
         %disp(New_dirs(loop).name);
         %disp(Output(loop2).name);
         if strcmp(New_dirs(loop).name,Output(loop2).name) == 1
            is_this_in_list = 1;
            disp('Rejected');
         end
      end
      
      if is_this_in_list == 0
         %disp('Added')
         %disp(getfield(New_dirs,{loop},'name'));
         [null,size_Output] = size(Output);
         Output(size_Output+1).name = getfield(New_dirs,{loop},'name');
         %disp(Output(size_Output+1).name);
         %disp(size_Output);
         [null,size_Output] = size(Output);
         %disp(size_Output);
         Output = dir_tree(getfield(New_dirs,{loop},'name'),Output);
         [null,size_Output] = size(Output);
      end
   end
end
