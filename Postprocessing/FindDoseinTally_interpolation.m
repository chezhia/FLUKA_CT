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


% Enter the conversion factor to go from dose in Gev/g to cGy 
CF = 8.8921e+08;

% Load the tally parsed into .mat file
if(exist('Fluence') == 0)
[fileName, pathName] = uigetfile({'*.mat'}, 'Load the tally parsed into .mat file');
load([pathName fileName]);
end

%% Display the Dimensions of the Tally
N_dims = 3;
dlg_title = 'Region Selection for Dose Calculation';
dimlabel = {'x','y','z'};
num_lines = 1;
load('Prev_FDiT.mat');
for i = 1:N_dims
prompt{1,i} = [dimlabel{i} ' - min = ' num2str(binlimits(i,1))];
prompt{2,i} = [dimlabel{i} ' - max = '  num2str(binlimits(i,2))];
defaultans{1,i} = num2str(prev(i,1));
defaultans{2,i} = num2str(prev(i,2));
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

% Version 3 using interpolation
X = (binlimits(1,1)+binlen(1)/2):binlen(1):binlimits(1,2)-binlen(1)/2;
Y = (binlimits(2,1)+binlen(2)/2):binlen(2):binlimits(2,2)-binlen(2)/2;
Z = (binlimits(3,1)+binlen(3)/2):binlen(3):binlimits(3,2)-binlen(3)/2;

if(dose_lims(1,1) < min(X))
        dose_lims(1,1) = min(X);
end
if(dose_lims(2,1) < min(Y))
        dose_lims(2,1) = min(Y);
end
if(dose_lims(3,1) < min(Z))
        dose_lims(3,1) = min(Z);
end
if(dose_lims(1,2) > max(X))
        dose_lims(1,2) = max(X);
end
if(dose_lims(2,2) > max(Y))
        dose_lims(2,2) = max(Y);
end
if(dose_lims(3,2) > max(Z))
        dose_lims(3,2) = max(Z);
end

[xq,yq,zq] = meshgrid(dose_lims(1,1):binlen(1):dose_lims(1,2), dose_lims(2,1):binlen(2):dose_lims(2,2),dose_lims(3,1):binlen(3):dose_lims(3,2));
 n_samp    = interp3(X,Y,Z,Fluence,xq,yq,zq,'linear');
Avg_dose = mean(n_samp(:))*CF;         
            
                    
disp('Avg Dose is ')
Avg_dose
prev = dose_lims;
save('Prev_FDiT.mat','prev');