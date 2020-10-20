close all
clear all

% Get Input Folder containing .mat files

inputpath = uigetdir('Enter the Folder containing .mat files to generate plots');


%Load Dose
load([inputpath '\Dose_Usrbin51.mat'])
FL_D = Fluence;
ER_D = Error;


%Center axial Slice [Testes]
% Display the Dimensions of the Tally
N_dims = 3;
dlg_title = 'Region Selection for Dose Calculation';
dimlabel = {'x','y','z'};
num_lines = 1;

prev_lim = [inputpath '\Testis_loc.mat'];
if exist(prev_lim,'file')
load(prev_lim);
end

for i = 1:N_dims
prompt{1,i} = [dimlabel{i} ' - min = ' num2str(binlimits(i,1))];
prompt{2,i} = [dimlabel{i} ' - max = '  num2str(binlimits(i,2))];
if exist('prev','var')
    defaultans{1,i} = num2str(prev(i,1));
    defaultans{2,i} = num2str(prev(i,2));
else
    defaultans{1,i} = '0';
    defaultans{2,i} = '1';
end
end
options = 'ON';
loop = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
for i = 1:length(loop)
    dose_lims(i) = str2num(loop{i});
end
dose_lims = reshape(dose_lims,2,3);
dose_lims = dose_lims';


prev = dose_lims;
save(prev_lim,'prev');

%Calculate bin lengths in each dimension
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

FL_D_T = FL_D(dose_bins(1,1):dose_bins(1,2),dose_bins(2,1):dose_bins(2,2),dose_bins(3,1):dose_bins(3,2));

ER_D_T = ER_D(dose_bins(1,1):dose_bins(1,2),dose_bins(2,1):dose_bins(2,2),dose_bins(3,1):dose_bins(3,2));


FL_D_T    = mean(FL_D_T,2);
ER_D_T    = sum(ER_D_T,2);

%% Plot 3D Surface Plots
figure;
x_ax = dose_lims(1,1)+binlen(1)/2:binlen(1):dose_lims(1,2)-binlen(1)/2;
z_ax = dose_lims(3,1)+binlen(3)/2:binlen(3):dose_lims(3,2)-binlen(3)/2;
FL_D_T = reshape(FL_D_T,length(x_ax),length(z_ax));
surf(z_ax,x_ax,FL_D_T)
%axis([-25 25 -8.0 8.0 0.0 1.2])
title('Dose for Adult Phantom without Shield');
xlabel('Z-axis');
ylabel('X-axis');
zlabel('Dose in mGY');
zlim([0.4 0.6])
caxis([0.4 0.6])
hold on;

%% Plot Contour Plots
figure;
colormap(hot)
%zlim([0.1 0.6])
[X,Y] = meshgrid(x_ax,z_ax);
contour(X',Y',FL_D_T,[0.1,0.2,0.3,0.4,0.5,0.6,1],'ShowText','on');
colorbar
title('Dose for Adult Phantom without Shield');
xlabel('Z-axis');
ylabel('X-axis');
zlabel('Dose in mGY');