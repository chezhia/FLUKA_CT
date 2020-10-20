close all
clear all


%% LOAD CT Volume
%Read CT data from dicom directory and view
dicompath = uigetdir('Enter the dicom folder path');
CT = readImages(dicompath);
CT_org = CT;
% Rotate CT for correct view
CT.volumes = flip(CT.volumes,3);

% Z co-ordinate, there is no cropping in z-direction between voxels and CT,
% just adjust them to be that of voxels. 

% Newborn Zmin: -230
% 5yr Zmin: -155
% Adult Zmin: -240
value = inputdlg('What is the Zmin in Voxel Geomery in MM', 'Zmin', 1,{'-320'});
Zmin = str2num(cell2mat(value));

%Normalize Z-coordinate
Zbin = abs(CT.locZ(1,1,1) - CT.locZ(1,1,2));
Zrange = abs(CT.bedRange3(1)-CT.bedRange3(2));
Zmax = Zmin+Zrange-Zbin
newZ = Zmin:Zbin:Zmax;

[X,Y,Z] = meshgrid(1:512,1:512,newZ');
CT.locZ = Z;
CT.bedRange3 = [Zmin Zmax];
CT.IPP(3,:) = newZ;

%Normalize X-coordinate
Xbin = abs(CT.locX(1,1,1) - CT.locX(2,1,1));
Xrange = abs(CT.bedRange1(1)-CT.bedRange1(2));
Xmin = -Xrange/2;
Xmax = Xmin+Xrange;
newX = Xmin:Xbin:Xmax;

[X,Y,Z] = meshgrid(newX,1:512,1:329);
CT.locX = X;
CT.bedRange1 = [Xmin Xmax];
CT.IPP(1,:) = Xmin;

%Normalize Y-coordinate
Ybin = abs(CT.locY(1,2,1) - CT.locY(1,2,1));
Yrange = abs(CT.bedRange2(1)-CT.bedRange2(2));
Ymin = -Yrange/2;
Ymax = Ymin+Yrange
newY = Ymin:Ybin:Ymax;

[X,Y,Z] = meshgrid(1:512,newY,1:329);
CT.locY = Y;
CT.bedRange2 = [Ymin Ymax];
CT.IPP(2,:) = Ymin;
%tic; VolumeViewer3D(CT); toc

%% Voxel Coordinates to CT coordinates

% XY co-ordinates, Cropping was done, so Translate center of Voxels to
% center of CT
% value = inputdlg('What is the Zmin in Voxel Geomery in CM', 'Zmin', 1,{'-32'});
% X_CT_center = str2num(cell2mat(value));
% Xmin = -X_CT_center;
% value = inputdlg('What is the Zmin in Voxel Geomery in CM', 'Zmin', 1,{'-32'});
% Y_CT_center = str2num(cell2mat(value));
% Ymin = -Y_CT_center;

X_center_CT =  0 ;                 % Displacement of the CT center with respect to Phantom center
Y_center_CT =  13;               % Displacement of the CT center with respect to Phantom center

% NB Y_disp = -13mm
% 5yr Y_disp = -7.56mm
% Adult Y_disp = -15.75mm

%Translate X-coordinate
Xmin = Xmin-X_center_CT;
Xmax = Xmin+Xrange;
newX = Xmin:Xbin:Xmax;

[X,Y,Z] = meshgrid(newX,1:512,1:329);
CT.locX = X;
CT.bedRange1 = [Xmin Xmax];
CT.IPP(1,:) = Xmin;

%Translate Y-coordinate
Ymin = Ymin - Y_center_CT
Ymax = Ymin+Yrange
newY = Ymin:Ybin:Ymax;

[X,Y,Z] = meshgrid(1:512,newY,1:329);
CT.locY = Y;
CT.bedRange2 = [Ymin Ymax];
CT.IPP(2,:) = Ymin;
CT = rmfield(CT,['locX';'locY';'locZ']);
CT = rmfield(CT,'filePath')
%tic; VolumeViewer3D(CT); toc


%Load Dose
% Get Input Folder containing .mat files
% inputpath = uigetdir('Enter the Folder containing .mat files without shield');
% 
% Get Input Folder containing .mat files
inputpath = uigetdir('Enter the Folder containing .mat files to generate plots');
load([inputpath '\Dose_Usrbin51.mat'])
FL_D = Fluence;


% % Get Input Folder containing .mat files
% inputpath = uigetdir('Enter the Folder containing .mat files with shield');
% 
% load([inputpath '\Dose_Usrbin51.mat'])
% FL_D_shield = Fluence;
% 
% Dose_diff = FL_D-FL_D_shield;
% FL_D = Dose_diff;


Dose = CT;
Dose.volumes = FL_D;
Dose.modality='DOSE';
Dose.imSz1 = binsize(1);
Dose.imSz2 = binsize(2);
Dose.imSz3 = binsize(3);

% Convert to mm
binlimits = binlimits .* 10;


Xbin = abs(binlimits(1,2)-binlimits(1,1))/binsize(1);
Ybin = abs(binlimits(2,2)-binlimits(2,1))/binsize(2);
Zbin = abs(binlimits(3,2)-binlimits(3,1))/binsize(3);

Xmin = binlimits(1,1) + Xbin/2;
Ymin = binlimits(2,1) + Ybin/2;
Zmin = binlimits(3,1) + Zbin/2;

Xmax = binlimits(1,2) - Xbin/2;
Ymax = binlimits(2,2) - Ybin/2;
Zmax = binlimits(3,2) - Zbin/2;

% Flip Y axis
temp = Ymin;
Ymin = -1*Ymax;
Ymax = -1*temp;
Dose.volumes = flip(Dose.volumes,2);

[X,Y,Z] = meshgrid([Ymin:Ybin:Ymax]',[Xmin:Xbin:Xmax]',Zmin:Zbin:Zmax);

Dose.IPP = ones(3,binsize(3));
Dose.IPP(1,:) = Xmin;
Dose.IPP(2,:) = Ymin;
Dose.IPP(3,:) = Zmin:Zbin:Zmax;

Dose.bedRange1 = [Xmin Xmax];
Dose.bedRange2 = [Ymin Ymax];
Dose.bedRange3 = [Zmin Zmax];

%%Overlay on CT Volume
Dose.modality='DosemGY'
Volout = VolumeViewer3D(CT,Dose)
%Volout = VolumeViewer3D(CT,Dose,'trim')

%Contour plot 
figure;
colormap(PET)
zlim([0.1 0.6])
contourf(FL_D(:,:,44)',[0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2]);
colorbar
caxis([0.0 0.265])
CT = CT_org;