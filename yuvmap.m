
%Title: yuvmap.m
%Author: Timothy Sheerman-Chase
%Date: 8 October 2000
%Description: This program generates a colour space map to see the
%actual relationships between the colours in rgb to yuv space.
%It is good for checking the pictoyuv routine (the output is linear in the colour domain)
%Warning: takes over 3 hours to run - it is not very efficient! (Try write in c next time!)
%Dependencies: rgb2yuv_init.m

clear Pic2;
Pic2(1:255,1:255,1:3)=uint8(0);
disp('Cleared Matrix');

xy2uv = rgb2yuv_init;

      max = [0,0,0];
      min = [256,256,256];
      
%Change to Universal Colour Space
pixel_writes=0;

for r = 1:255



   for g = 1:255
          %if rem(r,10)==0 %This gives you an idea of progress.
      disp('Processing Line:');
      disp(r);
      disp(g);
      disp('Pixel Writes:');
      disp(pixel_writes);
      disp('Max Values py - pvf - puf');
		disp(max);
		disp('Min Values py - pvf - puf');
		disp(min);
   %end  
      for b = 1:255
      %b=256 - 0.5*(r + g);
      


		%Perceptually Uniform Color Space (UCS)
		%and Its Use for Face Detection
		%Here, we give a color convertion program to convert a color from NTSC
		%RGB to the uniform color system proposed by Farnsworth.
		%(See COLOR SCIENCE, written by Gunter Wyszecki and W. S. Stiles,
		%John Wiley & Sons, Inc, 1967.)
		
		%Although the widely used L*u*v*, L*a*b* color spaces are simple and
		%easy to use, both of them are just rough approximations of UCS.
		%A better uniform color system was proposed by Farthworth in 1957. In
		%this color system, the two colors with an equal distance as perceived
		%by human viewers, will project with an equal distance here.
		
		
		%--------------------------------------------------------------------------------
		
		%C source program to convert (r,g,b) to (y,uf,vf)
		
		%--------------------------------------------------------------------------------
		
		
		%/* This function convert (R,G,B) in NTSC's RGB to Farthworth's UCS
		% * (Y, uf, vf).
		% * Usage: rgb2yuv(r, g, b, &y, &uf, &vf);
		% */
		
		%static const unsigned short xy2uv[253][212];
		
		%INPUT r g b
		%OUTPUT py puf pvf
      
      

      
      
		%int i, n, r, g, b, yy, xx, xyz, xyzh, hairy, u, v, y, skin;
		%  float fu, fv;
		%  unsigned int lrgb;
		
		%  /* RGB -> CIE's XYZ */
		  yy = floor(77 * r + 150 * g + 29 * b);    %/* CIE's Y * 256 */
        py = floor(yy / 256);                      %/* CIE's Y */ 
        
        
        finished_pixel = 0;
		  if py == 0
				UGRAY	= 43;
				VGRAY	= 44;
		    	puf = UGRAY;                    %/* (UGRAY, VGRAY) is "white" */
		    	pvf = VGRAY;
             
             finished_pixel = 1;
             %return;
		  end
		    
		  if(finished_pixel == 0)
		  		xx = floor(147 * r + 42 * g + 49 * b);    %/* CIE's X * 256 */
		  		xyz = floor(55 * r + 50 * g + 87 * b);    %/* CIE's (X + Y + Z) * 256 */
		  		xyzh = floor(xyz / 2);
		  		xx = floor( (xx * 100 + xyzh) / xyz);      %/* CIE's x * 100 = X/(X+Y+Z) * 100 */
		  		yy = floor( (yy * 100 + xyzh) / xyz);      %/* CIE's y * 100 = Y/(X+Y+Z) * 100 */
		
		  %/* For all visible color,
		  % * XN <= x <= XM
		  % * YN <= y <= YM
		  % */
		  
		  %Defined numbers
				XN	= 56;
				XM	= 267;
				YN	= 32;
				YM	= 284;
		
		  		xx = xx - XN;
		  		if xx < 0
		   		 xx = 0;
		  		elseif xx > XM - XN
		           xx = XM - XN;
		      end
		           
		  		yy = yy - YN;
		  		if yy < 0
		    		yy = 0;
		  		else if yy > YM - YN
		              yy = YM - YN;
		      end
		
		  %/* Use a table look up to convert (x,y) to Farthworth's
		  % * (uf,vf) 
		  % */ Size [253][212]
		
      % Size [253][212]
      if((xx<1)|(xx>212))
         disp(xx);disp('Error in array call in yuv tables');
         xx=1;
      end
      if((yy<1)|(yy>253)) 
         disp(yy);disp('Error in array call in yuv tables');
         yy=1;
      end
         
      
		  uv = xy2uv(xx,yy);
		  pvf = floor(uv / 256);
		  puf = rem(uv, 256);
        end % End of if(finished_pixel == 0)
   end
   
   
   if r+g+b > double(Pic2(pvf,puf,1))+double(Pic2(pvf,puf,2))+double(Pic2(pvf,puf,2))
      Pic2(pvf,puf,1)=uint8(r);
      Pic2(pvf,puf,2)=uint8(g);
      Pic2(pvf,puf,3)=uint8(b);
      pixel_writes=pixel_writes+1;
   end
   
        if(uint8(py)<min(1))
           min(1) = uint8(py);
        end
        if(uint8(pvf)<min(2))
           min(2) = uint8(pvf);
        end        
        if(uint8(puf)<min(3))
           min(3) = uint8(puf);
        end    
        if(uint8(py)>max(1))
           max(1) = uint8(py);
        end
        if(uint8(pvf)>max(2))
           max(2) = uint8(pvf);
        end        
        if(uint8(puf)>max(3))
           max(3) = uint8(puf);
        end    
        
       
        
end % End blue loop
end % Green

%imagesc(Pic2);

end % red

disp('Max Values py - pvf - puf');
disp(max);
disp('Min Values py - pvf - puf');
disp(min);

imagesc(Pic2);
