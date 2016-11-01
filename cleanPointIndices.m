%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                         CLEAN POINT INDEXING                            %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clean point indexing to make nicer meshes
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

function  SEG_shift_clean = cleanPointIndices(SEG_shift,RVyes)
%% Get size info
SEG_shift_clean = SEG_shift;

sizen = size(SEG_shift.EndoXnew);
K = sizen(1,1); %number of points in a segment contour
N = sizen(1,2); %number of frames
S = sizen(1,3); %number of slices

sizenEpi = size(SEG_shift.EpiXnew);
KEpi = sizenEpi(1,1); %number of points in a segment contour
NEpi = sizenEpi(1,2); %number of frames
SEpi = sizenEpi(1,3); %number of slices

LVdist21Endo = zeros(1,K);
LVdist21Epi = zeros(1,KEpi);

if RVyes == 1
    sizenRV = size(SEG_shift.RVEndoXnew);
    KRV = sizenRV(1,1); %number of points in a segment contour
    NRV = sizenRV(1,2);
    SRV = sizenRV(1,3); %number of slices
   
    sizenRVEpi = size(SEG_shift.RVEpiXnew);
    KRVEpi = sizenRVEpi(1,1); %number of points in a segment contour
    NRVEpi = sizenRVEpi(1,2);
    SRVEpi = sizenRVEpi(1,3); %number of slices 
      
    RVdist21Endo = zeros(1,KRV);
    RVdist21Epi = zeros(1,KRVEpi);
    
end

%% Compute squared distances and rearrange points

% EndoLV
refEndo = 1;

for n=1:N

    for s=S:-1:2

        for k=1:K
            LVdist21Endo(k) = (SEG_shift.EndoXnew(refEndo, n, s) - ...
                SEG_shift.EndoXnew(k, n, s - 1))^2 + ...
                (SEG_shift.EndoYnew(refEndo, n, s) - ...
                SEG_shift.EndoYnew(k, n, s - 1))^2;
        end

        [~, indEndo] = min(LVdist21Endo);
        indexEndo = indEndo;
        refEndo = indEndo;

        for l=1:K
            indexEndo = mod(indexEndo, K) + 1;
            SEG_shift_clean.EndoXnew(l, n, s-1) = ...
                SEG_shift.EndoXnew(indexEndo, n, s-1);
            SEG_shift_clean.EndoYnew(l, n, s-1) = ...
                SEG_shift.EndoYnew(indexEndo, n, s-1);
        end    
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% EpiLV
refEpi = 1;
for n=1:NEpi

    for s=SEpi:-1:2

        for k=1:KEpi
            LVdist21Epi(k) = (SEG_shift.EpiXnew(refEpi, n, s) -...
                SEG_shift.EpiXnew(k, n, s - 1))^2 + ...
                (SEG_shift.EpiYnew(refEpi, n, s) - ...
                SEG_shift.EpiYnew(k, n, s - 1))^2;
        end

        [~, indEpi] = min(LVdist21Epi);
        indexEpi = indEpi;
        refEpi = indEpi;

        for l=1:KEpi
            indexEpi = mod(indexEpi, K) + 1;
            SEG_shift_clean.EpiXnew(l, n, s-1) = ...
                SEG_shift.EpiXnew(indexEpi, n, s-1);
            SEG_shift_clean.EpiYnew(l, n, s-1) = ...
                SEG_shift.EpiYnew(indexEpi, n, s-1);
        end    
    end
end

% EndoRV 
if RVyes ==1
    refRV = 1;
    for n = 1:NRV

        for s=SRV:-1:2

            for k=1:KRV
                RVdist21Endo(k) = (SEG_shift.RVEndoXnew(refRV, n, s) - ...
                    SEG_shift.RVEndoXnew(k, n, s-1))^2 + ...
                    (SEG_shift.RVEndoYnew(refRV, n, s) - ...
                    SEG_shift.RVEndoYnew(k, n, s-1))^2;
            end

            [~, indRV] = min(RVdist21Endo);
            indexRV = indRV;
            refRV = indRV;

            for l=1:KRV
                SEG_shift_clean.RVEndoXnew(l, n, s-1) = ...
                    SEG_shift.RVEndoXnew(indexRV, n, s-1);
                SEG_shift_clean.RVEndoYnew(l, n, s-1) = ...
                    SEG_shift.RVEndoYnew(indexRV, n, s-1);
                indexRV = mod(indexRV,KRV) + 1;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % EpiRV

    refRVEpi = 1;
    for n = 1:NRVEpi

        for s=SRVEpi:-1:2

            for k=1:KRVEpi
                RVdist21Epi(k) = (SEG_shift.RVEpiXnew(refRVEpi, n, s) - ...
                    SEG_shift.RVEpiXnew(k, n, s-1))^2 + ...
                    (SEG_shift.RVEpiYnew(refRVEpi, n, s) - ...
                    SEG_shift.RVEpiYnew(k, n, s-1))^2;
            end

            [~, indRVEpi] = min(RVdist21Epi);
            indexRVEpi = indRVEpi;
            refRVEpi = indRVEpi;

            for l=1:KRVEpi
                SEG_shift_clean.RVEpiXnew(l, n, s-1) = ...
                    SEG_shift.RVEpiXnew(indexRVEpi, n, s-1);
                SEG_shift_clean.RVEpiYnew(l, n, s-1) = ...
                    SEG_shift.RVEpiYnew(indexRVEpi, n, s-1);
                indexRVEpi = mod(indexRVEpi,KRVEpi) + 1;
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
    

clear n s k j  i N S K NEpi SEpi KEpi SRV KRV SRVES KRVES YRV YEpi YEndo...
    YTestEpi YTestEndo YTestRV
end
