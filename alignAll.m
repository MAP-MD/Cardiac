%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                  PRE-PROCESS AND ALIGN ALL TO REFERENCE                 %
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

% Manual inputs
noSubjects = 40;    % Total number of subjects 
RVyes = 1;          % Is the RV segmented too? 1=yes, 0=no
IsFullTemporal = 0; % Is there full 4D segmentation or not? 1=yes, 0=no
database='Prefix_'; % Prefix for current cohort

filename = cell(noSubjects,1);
SEGold = cell(noSubjects,1);
SEG_shift = cell(noSubjects,1);
SEG_shift_clean = cell(noSubjects,1);
SEG_shift_resampled = cell(noSubjects,1);

global SEG;
SEG = cell(noSubjects,1);

%% First give filenames for all subjects and load them
% Find existing files
Subjects = [];
for i = 1:noSubjects
    if exist([database num2str(i) '.mat'], 'file')
    filename{i} = [database num2str(i) '.mat'];
    Subjects = [Subjects i];
    end
end

% Load files
for i = Subjects
    tmp = load(filename{i},'-mat','setstruct');
    SEGold{i} = tmp.setstruct; 
end
clear tmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run sliceAlignment.m to remove slice mis-alignments
for i = Subjects
    SEG_shift{i} = sliceAlignment(SEGold{i},RVyes);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Run cleanPointIndices.m to fix the point indexing
for i = Subjects
    SEG_shift_clean{i} = cleanPointIndices(SEG_shift{i},RVyes);
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run temporalResampling.m to resample all to have the same no. of frames
% No resampling performed for static segmentation
for i = Subjects
    SEG_shift_resampled{i} = notTemporalResampleAlignment...
        (SEG_shift_clean{i},RVyes);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run pairwiseAlignment.m to resample all to a common space
% Assume subject 1 is the reference and iterate over all others
for i = Subjects(2:end)
    SEG{i} = pairwiseAlignment(SEG_shift_resampled{1},...
        SEG_shift_resampled{i},IsFullTemporal);
end
% Finally, change resolution for the reference subject
SEG{1} = ChangeRes(SEG_shift_resampled{1});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save all to new files
% Aligned models
for i = Subjects
    [pathstr,name,ext] = fileparts(filename{i});
    suffix = '_aligned';
    outname = [name suffix ext];
    SEGsave = SEG{i};
    save(outname, 'SEGsave');
end

% Scar images
for i = Subjects
    SaveMhd(i, filename{i});
end

% Text files to be called in make_surface.py
ext1 = '.txt';
for i = Subjects
    [pathstr,name,ext] = fileparts(filename{i});
    for frame = 1
        suffix1 = ['-LVEndo-Frame_' int2str(frame)];
        suffix2 = ['-LVEpi-Frame_' int2str(frame)];
        suffix3 = ['-RVEndo-Frame_' int2str(frame)];
        suffix4 = ['-RVEpi-Frame_' int2str(frame)];
        outname1 = fullfile(['Data/Texts/' name suffix1 ext1]);
        outname2 = fullfile(['Data/Texts/' name suffix2 ext1]);
        outname3 = fullfile(['Data/Texts/' name suffix3 ext1]);
        outname4 = fullfile(['Data/Texts/' name suffix4 ext1]);
        dlmwrite(outname1, SEG{i}.EndoPoints.Frame{frame}, 'delimiter',' ');
        dlmwrite(outname2, SEG{i}.EpiPoints.Frame{frame}, 'delimiter',' ');
        dlmwrite(outname3, SEG{i}.RVEndoPoints.Frame{frame}, 'delimiter',' ');
        dlmwrite(outname4, SEG{i}.RVEpiPoints.Frame{frame}, 'delimiter',' ');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Visualisation
displayWithScar(3, 1);
