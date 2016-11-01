%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%%%                 SAVE .MHD FILE IN PROPER FORMAT                     %%%
%                                                                         %              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please cite the paper describing these tools:

% Marciniak, M., Arevalo, H., Tfelt-Hansen, J., Jespersen, T., Jabbari, R., 
% Glinge, C., Vejlstrup, N., Engstrom, T.,Maleckar, M.M., McLeod, K.: From 
% MR image to patient-specific simulation and population-based analysis:
% Tutorial for an openly available image-processing pipeline. Proc. 
% Statistical Atlases and Computational Models ofthe Heart Workshop, Athens 
% (2016)

% This program is free software; you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the 
% Free Software Foundation; either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General 
% Public License for more details.
% You should have received a copy of the GNU General Public License along 
% with this program; if not, write to the Free Software Foundation, Inc., 
% 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SaveMhd(subjNo, filen)

global SEG % Comes from global workspace
localSEG = SEG{subjNo}; 

% For further processing purposes, values are changed to maximum 8-bit value
% Preparing binary array
pixSize = int16([localSEG.XSize, localSEG.YSize, localSEG.ZSize]);
pix=zeros(pixSize);

%Finding slices with scar pixels
temp=round(localSEG.ScarMhd/[localSEG.ResolutionX 0 0; 0 localSEG.ResolutionY 0;...
    0 0 1]);
temp(:)=temp(:);
z=max(temp(:,3));


for i=1:localSEG.ZSize
    temp1=find(temp(:,3)==z);
    [c,~]=size(temp1);
    for j=1:c
        x=temp(temp1(j),1);
        y=temp(temp1(j),2);
        
          pix(x,y,i)=255;
        
    end
    z = z-localSEG.SliceThickness;
    
end

% Information for .mhd file.
pixImage(:,:,1,:) = uint8(pix);
orig = [0 0 -localSEG.EndoPoints.Frame{1}(1,3);]';

sp = [localSEG.ResolutionX localSEG.ResolutionY localSEG.SliceGap+...
    localSEG.SliceThickness]';
orient = eye(3);
image = ImageType(size(squeeze(pixImage))', orig, sp, orient);
image.data = squeeze(pixImage);

% Saving image
[~,name,~] = fileparts(filen);
fileName=['Data/ScarImages/MetaImages/' name '.mhd'];
write_mhd(fileName, image, 'elementtype', 'uint8');