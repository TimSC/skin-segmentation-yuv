
%Title: Check Performance
%Author: Timothy Sheerman-Chase
%Date: 08 Feb 2001
%Description:  This function compares a list of probability maps to a 
%list of masked images. The average probabilities of the face and bacground
%regions are displayed as some simple performance data
%
%Dependencies: ??
%Arguments: 
%Prob_images - list of probability images
%Mask_images - list of masked images

function check_perform(Prob_images,Mask_images)

[null,number_of_files]=size(Prob_images)
no_of_probs = 0;
total_face = 0;
total_back = 0;

%%%%%%%%%%%%%%%%%%%%%
%This is the main file open loop
for l=1:number_of_files
   fid=0;
   %s=sprintf(in_files,l); %Edit as needed
   fid=fopen(getfield(Prob_images,{l},'name'),'r');
   
   if fid>1 % This check if the file exists
      fclose(fid);
      fprintf('\nFound file: %s',getfield(Prob_images,{l},'name'));
      
      fid = 0;
      fid=fopen(getfield(Mask_images,{l},'name'),'r');
      if fid>1 % This check if the file exists
         fclose(fid);
         fprintf('\nand mask file: %s',getfield(Mask_images,{l},'name'));
         
         Prob = double( imread( getfield(Prob_images,{l},'name') ) );
         Mask = double( imread( getfield(Mask_images,{l},'name') ) );
         
         Mask_simple = (Mask(:,:,2) == 255);
         %imagesc(Mask_simple);
         
         Background = Mask_simple .* Prob;
         Face = (1-Mask_simple) .* Prob;
         
         face_average = sum(sum(Face./255)) ./ sum(sum(1-Mask_simple)); %Works out average probability in the face
         background_average = sum(sum(Background./255)) ./ sum(sum(Mask_simple)); %and av. prob. in background
         rating = ( face_average - background_average ) .* 100;
         fprintf('\nAverage face value: %f   Average background: %f   Rating: %f%%',...
            face_average,background_average,rating);
         
         no_of_probs = no_of_probs + 1;
         total_face = total_face + face_average;
         total_back = total_back + background_average;
      else
         fprintf(' but no mask found!');
      end
      
   end
   
end

if no_of_probs > 0, %Displays summary of probabilities and proformance
	fprintf('\n\nOverall Face Average: %f',total_face ./ no_of_probs);
	fprintf('\nOverall Background Average: %f',total_back ./ no_of_probs);
   rating = ((total_face-total_back) ./ no_of_probs) .* 100;
   fprintf('\nOverall Rating: %f%%',rating );
   fprintf('\nS/B Ratio: %f', total_face ./ total_back);
end;
