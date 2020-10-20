%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Created by  Elan Somasundaram - 8/21/2017 %%
%% Description:
%   This script is used to calculate the photon source strength (intensity)
%   for a particular scan. The value calculated by this script should be
%   used in the postprocessing stage to calculate actual dose from 
%   per particle dose calculated in FLUKA simulation.
%
%% INPUT:
%      - Scan Parameters - Collimation, Average Tube Current - mAs
%      - Normalized Heel (Beam) profile in (.xlsx) [processed file]
%      - Unnormalized Bowtie Spectra for all 50 Bowtie Bins (.mat file)
%% OUTPUT:
%      - Bowtie Profile CDF in text file for use in FLUKA
%        CDF is listed from -25cm to +25cm for 50cm SFOV
%
%      - Energy CDF for each Bowtie bin from -25 to 0 for use in FLUKA
%        150 energy bins and 25 Bowtie bins are present in this file
%        The Source Model in FLUKA knows how to read this file
%
%      - Unnormalized Bowtie Profile is saved in .mat file for 
%        source strength calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load Scan Parameters
clear all;
SFOV = 500; %mm
col = inputdlg('What is the collimation?', 'Collimation', 1,{'80'});
mAs = inputdlg('What is the Average Tube Current in mAs ', 'Tube Current (mAs)', 1,{'264.2188'});  % Large Filter, 120Kvp, TCM NI=4.0
mAs = str2num(cell2mat(mAs));
%mAs = 300; % Large Filter, 120KVP, FIxed Ma scans
SDD = 625.6; %mm

% Effective Collimation cm to mm
Eff_Col = str2num(cell2mat(col));
%
HCA = atan(Eff_Col/2/SDD);  % Half Cone Angle
HFA = atan(SFOV/2/SDD);       % Half Fan Angle
Beam_area_iso = (tan(HCA)*2*SDD) * (tan(HFA)*2*SDD); % Beam Area at Isocenter (mm^2)
%                        Z       *   X
Beam_area_100cm = (tan(HCA)*2*1000) * (tan(HFA)*2*1000); % Beam Area at 100 cm from Tube (mm^2)


%% Load Bowtie Spectrum calculated using SPEKTR 
% Spectrum is in units photons/mm^2/mAs per 1 KeV bins from 1-150 KeV at
% 100 cm from the source
[fileName, pathName] = uigetfile({'*.mat'}, 'Select Unnormalized Bowtie spectrum');
load([pathName fileName]);
SDD_2 = SDD^2;
% Scale it back from 100 cm from tube to SDD (Tube to isocenter distance)
Bowtie_profile_full(:,2) = Bowtie_profile_full(:,2)*1000000/SDD_2; % 
% Convert cm to mm
Bowtie_profile_full(:,1) = Bowtie_profile_full(:,1)*10;

%% Normalize Heel profile
heel_profile(:,1) = -(Eff_Col/2):(Eff_Col/50):(Eff_Col/2);
heel_profile(:,2) = 1;
plot(heel_profile(:,1),heel_profile(:,2))

%% Find source Stregth
%% The heel bins and bowtie bins are multiplied to split the beam area into multiple bins
%% The source strength in each bin is then calculated and added together.
%Tot_bins = length(heel_profile)*(length(Bowtie_profile_full)-1);
heel_bin_length = abs(heel_profile(2,1)-heel_profile(1,1));
% Centralize heel bins such that there is equal number of bins to get the
% correct area
if(heel_bin_length*length(heel_profile) > Eff_Col)
new_prof = zeros(length(heel_profile)-1,2);    
for i = 1:(length(heel_profile)-1)    
new_prof(i,1) = (heel_profile(i,1) + heel_profile(i+1,1))/2;
new_prof(i,2) = (heel_profile(i,2) + heel_profile(i+1,2))/2;
end
heel_profile = new_prof;
end

bowtie_bin_length = SFOV/(length(Bowtie_profile_full)-1);
% Bin area with Bowtie and HEEL bins
bin_area_BH = heel_bin_length*bowtie_bin_length; 
% Bin area for only Bowtie Bins
bin_area_B = Beam_area_iso/(length(Bowtie_profile_full)-1);
% Make sure binarea*tot_bins adds up to the over_coverage+ beam_area_iso
%over_coverage_area = SFOV*(-70-min(heel_profile(:,1))+max(heel_profile(:,1))-70)
Src_BOW_HEEL = 0;
Src_BOW = 0;
Tot_area = 0;

for i = 1:(length(Bowtie_profile_full)-1) % The 50th measurements has half the bin area
  % Source Strength without the Heel Effect
  D1 = Bowtie_profile_full(i,1)^2;
  D2 = D1 +  SDD_2;   
  Src_BOW =  Src_BOW + Bowtie_profile_full(i,2) * bin_area_B * mAs * SDD_2/D2;     
for z = 1:length(heel_profile)
% Restrict to only the collimation width,   
%if ((heel_profile(z,1) > -Eff_Col/2) & (heel_profile(z,1) < Eff_Col/2) )   
  D1 = heel_profile(z,1)^2 + Bowtie_profile_full(i,1)^2;
  D2 = D1 +  SDD_2;   
  % Source Strength with Bowtie and Heel effect
  Src_BOW_HEEL = Src_BOW_HEEL + Bowtie_profile_full(i,2) * bin_area_BH * heel_profile(z,2) * mAs * SDD_2/D2;
  Tot_area = bin_area_BH + Tot_area;
%end
end
end
fprintf('Beam_iso_center_area is %d \n',Beam_area_iso);
fprintf('Total area calculated  is %d \n',Tot_area);

%% Save Output for use in postprocessing stage
save([col{1} '_Src_strength_80noHEEL.mat'],'Src_BOW_HEEL','Src_BOW');