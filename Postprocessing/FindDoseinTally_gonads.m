%%%%%%%%%%%%%%%%%%%%%%%%%
%% DESCRIPTION:
% Use this script to read USRBIN tallies that are setup to score the dose
% across a large phantom volume in a cartesian grid and if you are interested
% in finding the dose in a smaller box within the tallied volume.
% Linear interpolation is used to calculate the dose at the queried
% co-ordinate. Dose calculated is per particle - Not absolute dose
%% INPUT:
%    - .mat file containing the dose matrix generated using
%       Read_USRBIN_multiplebins.m
%    -  XYZ min and max limits for which dose should be computed
%% OUTPUT:
%    -  Interpolated FLUKA dose in cGy
%%%%%%%%%%%%%%%%%%%%%%%%%




% Load the tally parsed into .mat file
pathName = uigetdir('Select Folder');
load([pathName '\Usrbin71.mat']);
Beam = Fluence;

load([pathName '\Usrbin61.mat']);
Photons = Fluence;

Secondary = Photons - Beam;

Fluence = Secondary./Beam;
%% Display the Dimensions of the Tally
N_dims = 3;
dlg_title = 'Region Selection for Dose Calculation';
dimlabel = {'x','y','z'};
num_lines = 1;
for i = 1:N_dims
prompt{1,i} = [dimlabel{i} ' - min = ' num2str(binlimits(i,1))];
prompt{2,i} = [dimlabel{i} ' - max = '  num2str(binlimits(i,2))];
defaultans{1,i} = num2str(binlimits(i,1));
defaultans{2,i} = num2str(binlimits(i,2));
end
options = 'ON';
loop = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
for i = 1:length(loop)
    dose_lims(i) = str2num(loop{i});
end
dose_lims = reshape(dose_lims,2,3);
dose_lims = dose_lims';

% Calculate bin lengths in each dimension
 for i = 1:N_dims
 binlen(i) = (binlimits(i,2)-binlimits(i,1))/binsize(i);
 end
 XYZ = {};
 XYZ{1} = (binlimits(1,1)+binlen(1)/2):binlen(1):binlimits(1,2)-binlen(1)/2;
 XYZ{2,:} = (binlimits(2,1)+binlen(2)/2):binlen(2):binlimits(2,2)-binlen(2)/2;
 XYZ{3,:} = (binlimits(3,1)+binlen(3)/2):binlen(3):binlimits(3,2)-binlen(3)/2;
dose_bins = zeros(3,2);
for i = 1:N_dims
 vec =  abs(XYZ{i,:}-dose_lims(i,1));
 hbin = (binlen(i)/2)+1e-05;
ind = find( vec <= hbin);
if(numel(ind)>1)
    dose_bins(i,1) = ind(2);
else
    dose_bins(i,1) = ind;
end
clear ind;
vec = abs(XYZ{i,:}-dose_lims(i,2));
ind = find(vec <= hbin);
dose_bins(i,2) = ind(1);
if(dose_bins(i,2) < dose_bins(i,1))
    dose_bins(i,2) = dose_bins(i,1);
end
clear ind;    
end

%Calculate Average dose in the selected region
Tot_dose = Fluence(dose_bins(1,1):dose_bins(1,2),dose_bins(2,1):dose_bins(2,2),dose_bins(3,1):dose_bins(3,2));
Avg_dose = sum(Tot_dose(:))/numel(Tot_dose);       
         
disp('Avg S/P is ')
Avg_dose     

Fluence = Beam;
Tot_dose = Fluence(dose_bins(1,1):dose_bins(1,2),dose_bins(2,1):dose_bins(2,2),dose_bins(3,1):dose_bins(3,2));
Avg_dose = sum(Tot_dose(:))/numel(Tot_dose);    
disp('Avg Beam is ')
Avg_dose

Fluence = Photons;
Tot_dose = Fluence(dose_bins(1,1):dose_bins(1,2),dose_bins(2,1):dose_bins(2,2),dose_bins(3,1):dose_bins(3,2));
Avg_dose = sum(Tot_dose(:))/numel(Tot_dose);    
disp('Avg Photons is ')
Avg_dose