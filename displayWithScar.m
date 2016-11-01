%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                     DISPLAY SEGMENTATION WITH SCAR                      %
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
function displayWithScar(no, withEpi)

global SEG
localSEG = SEG{no};

figure
hold on
title(['Checking final result on subject ' int2str(no)]);

% Plot endo points
plot3(localSEG.EndoPoints.Frame{1}(:,1),localSEG.EndoPoints.Frame{1}(:,2),...
    localSEG.EndoPoints.Frame{1}(:,3),'r.')
plot3(localSEG.EpiPoints.Frame{1}(:,1),localSEG.EpiPoints.Frame{1}(:,2),...
    localSEG.EpiPoints.Frame{1}(:,3),'g.')

% Plot epi points if necessary
if withEpi
    plot3(localSEG.RVEndoPoints.Frame{1}(:,1),localSEG.RVEndoPoints.Frame{1}(:,2),...
        localSEG.RVEndoPoints.Frame{1}(:,3), '.','Color', [0.5 0 0.5])
    plot3(localSEG.RVEpiPoints.Frame{1}(:,1),localSEG.RVEpiPoints.Frame{1}(:,2),...
        localSEG.RVEpiPoints.Frame{1}(:,3),'c.')
end

% Plot scar points
plot3(localSEG.ScarMhd(:,1),localSEG.ScarMhd(:,2),localSEG.ScarMhd(:,3),'.',...
    'Color',[1, 0.8, 0])
hold off