%Title: List Files
%Author: Timothy Sheerman-Chase
%Date: 15 Feb 2001
%Description: Internals of file selection routines. Very little to do with the project
%and just matlab bits and code.
%
%Arguments:

function Output = list_files(type, dir_now, Output)

if nargin<1, error('Not enough inputs.'); end

if nargin<3
   Output(1).name = 'null';
   files_found = 1;
else
   [null,files_found]=size(Output);
   files_found = files_found +1;
end

if nargin <2
   dir_now=cd;
else
   %disp(dir_now);
end

Listing = dir(dir_now);
[no_of_files,null] = size(Listing);


for loop = 1:no_of_files
   
   [null,name_length] = size ( Listing(loop).name );
   clear Fullstops; clear last_fullstop;
   Fullstops = findstr( Listing(loop).name , '.' );
   %disp(Listing(loop).name);
   %disp(size(Fullstops));disp('----');
   %disp(Fullstops); disp('****');
   if size(Fullstops)~=0
      last_fullstop = Fullstops(size(Fullstops));
   	file_ending = Listing(loop).name(last_fullstop(2):name_length);
   
  		if strcmp(file_ending,type) == 1
      	Listing(loop).name = strcat('\',getfield(Listing,{loop},'name'));
      	Output(files_found).name = strcat(dir_now,getfield(Listing,{loop},'name'));
      	files_found = files_found + 1;
   	end
   end
end