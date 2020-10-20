%%%%%%%%%%%%%%%%%%%%%%%%
%% Created by Elan Somasundaram
% Description: Rescales the Patient/phantom scan to match the resolution of
% the table scan
%% INPUT:
%   -  Preprocessed DICOM for patient/phantom
%   -  Enter the mm per pixel value of the output image/Table scan.
%% OUTPUT:
%    - Rescaled DICOM series
%%%%%%%%%%%%%%%%%%%%%%%

%DICOM RESCALE
%% Load Folder Containing DICOM stack
[dcmPathDir] = uigetdir(cd, 'Select Folder Containing Dicom Images');

dicom_list = dir([dcmPathDir '\*.dcm']);

%% Check for dummy names
% i=1;
% while(i <= numel(dicom_list))
% if(isempty(dicom_list(i).name))
% dicom_list(i) = [];
% end
% i=i+1;
% end    

%% Sort the dicom_list by InstanceNumber. Default order of the files read by
% 'dir' is not correct. 
i = 1;
while(i <= numel(dicom_list))
header = dicominfo([dcmPathDir '\' dicom_list(i).name]);% capture Instance number
instanceNum(i) = header.InstanceNumber;
sorted_dicom_list(instanceNum(i)).name = dicom_list(i).name;    
sorted_dicom_list(instanceNum(i)).date = dicom_list(i).date;
sorted_dicom_list(instanceNum(i)).bytes = dicom_list(i).bytes;
sorted_dicom_list(instanceNum(i)).isdir = dicom_list(i).isdir;
sorted_dicom_list(instanceNum(i)).datenum = dicom_list(i).datenum;
i=i+1; 
end
dicom_list = sorted_dicom_list;
clear sorted_dicom_list i;

%% Read DICOM
ct_info = {};
w = waitbar(0, 'Loading CT DICOM images');   
Z =[];
for ii = 1: numel(dicom_list)  
    %load CT images
    ct_original(:,:,ii) = dicomread([dcmPathDir '\' dicom_list(ii).name]);
    ct_info{ii} = dicominfo([dcmPathDir '\' dicom_list(ii).name]);
    Z(ii) = ct_info{ii}.SliceLocation;
    waitbar(ii/numel(dicom_list),w);
end%for ii = 1: numel(dir_list)    for ii = 1: numel(dicom_list) 
close(w)


%% Get Output DICOM image size
out_mmperpix = inputdlg('Enter the mm per pixel in the output image','mm per pixel', 1,{'0.9766'});
out_mmperpix = str2num(out_mmperpix{1});

%% Rescale
in_mmperpix = ct_info{1}.PixelSpacing(1);
in_imgdim = in_mmperpix * double(ct_info{1}.Width);

out_imgdim = out_mmperpix * double(ct_info{1}.Width); 
out_imgsize = in_imgdim/out_mmperpix; % Pixel size of the output image

half_pixlen = (in_mmperpix/2);
X = half_pixlen:in_mmperpix:(in_imgdim-half_pixlen);
Y = X;
[Xq,Yq,Zq] = meshgrid(half_pixlen:out_mmperpix:(in_imgdim-half_pixlen),half_pixlen:out_mmperpix:(in_imgdim-half_pixlen),Z);
ct_original=double(ct_original);
ct_scaled = interp3(X',Y',Z',ct_original,Xq,Yq,Zq);
ct_scaled = round(ct_scaled);
ct_scaled = int16(ct_scaled);

%% Write DICOM
% Get output Directory
[dcmPathDir] = uigetdir(cd, 'Select Folder to Output Rescaled Dicom images');
w = waitbar(0, 'Writing CT DICOM images');
for ii = 1: numel(dicom_list)  
    %load CT images
    ct_info{ii}.Rows = out_imgsize;
    ct_info{ii}.Columns = out_imgsize;
    ct_info{ii}.Width = out_imgsize;
    ct_info{ii}.Height = out_imgsize;
    ct_info{ii}.PixelSpacing(1) = out_mmperpix;
    ct_info{ii}.PixelSpacing(2) = out_mmperpix;
    ct_info{ii}.ReconstructionDiameter = out_imgdim;
    
    dicomwrite(ct_scaled(:,:,ii),[dcmPathDir '\image' num2str(ii) '.dcm'],ct_info{ii});
    waitbar(ii/numel(dicom_list),w);
end%for ii = 1: numel(dir_list)    for ii = 1: numel(dicom_list) 
close(w);