%%%%%%%%%%%%%%%%%%%%%%%%
% Description: This code has most of it dervied from Polan's preprocessing
% for auto segmentation project. Helps to get rid of the background and
% table in the scans.
%% INPUT:
%   - DICOM scan volume
%% OUTPUT:
%    - Preprocessed DICOM scan volume
%%%%%%%%%%%%%%%%%%%%%%%


%DICOM Preproc
% Removes the background and writes it back to dicom
%% Load Folder Containing DICOM stack
[dcmPathDir] = uigetdir(cd, 'Select Folder Containing Dicom Images');

dicom_list = dir([dcmPathDir '\*.dcm']);

% Sort the dicom_list by InstanceNumber. Default order of the files read by
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
ct_info = {};
w = waitbar(0, 'Loading CT DICOM images');   
for ii = 1: numel(dicom_list)  
    %load CT images
    ct_original(:,:,ii) = dicomread([dcmPathDir '\' dicom_list(ii).name]);
    ct_info{ii} = dicominfo([dcmPathDir '\' dicom_list(ii).name]);
    waitbar(ii/numel(dicom_list),w);
end%for ii = 1: numel(dir_list)    for ii = 1: numel(dicom_list) 
close(w)

% CT number shifting
min_ct = min(ct_original(:));
ct_uint16 = uint16(ct_original - min_ct); 
%ct_uint16 = uint16(ct_original);
BW = logical(ct_uint16);

% CT table extraction from DICOM
ct_table = ones(size(ct_uint16));
ct_table = int16(ct_table)*min_ct;
%% Contour Image leaving only the body (Not Perfect!!!)
%  Note: there is a known issue when the body is not one segment on the
%  image (ie. legs), consider setting threshold for size of object to keep
for slice = 1:size(ct_uint16,3)    
    % Creates a logical image BW based on intensity threshold
    % WARNING: Threshold levels may not work for all patients
    % Axial = 0.0415
    % Coronal/Sagittal = 0.013
    % Try using function graythresh to automatically find the LEVEL
    BW(:,:,slice) = im2bw(ct_uint16(:,:,slice),0.0415);
    
    % Finds linear pixel indices of connected objects
    CC = bwconncomp(BW(:,:,slice));
    
    % Finds largest object in list of connected objects
    % NOTE: Instead of just using largest object, it may be better to set
    %       limit based on size of the object
    [~, maxIndex] = max(cellfun('size', CC.PixelIdxList, 1));
    
    % Sets logical array values inside largest object to 1
    if isempty(maxIndex)
        disp(['WARNING: Slice ' num2str(slice) ' contains no components']);
    else
    BW((CC.ImageSize(1)*CC.ImageSize(2)*(slice - 1) + 1):(CC.ImageSize(1)*CC.ImageSize(2)*slice)) = ismember(1:CC.ImageSize(1)*CC.ImageSize(2),CC.PixelIdxList{1, maxIndex});
    end
    
    % Fills voids within object (i.e. lung) 
    BW(:,:,slice) = imfill(BW(:,:,slice),'holes');
    
    % Using the logical BW array, pixels outside object are set to minimum value
    for j = 1:CC.ImageSize(1)
        for k = 1:CC.ImageSize(2)
            if BW(j,k,slice) == 0
                ct_uint16(j,k,slice) = 0;
                ct_table(j,k,slice) = ct_original(j,k,slice);
            end
        end
    end   
end 
ct_uint16 = (int16(ct_uint16)+(min_ct));

% min_cttab = min(ct_table(:));
% ct_table = ct_original(ct_table ~=min_cttab);

%% Write DICOM
% Get output Directory
[dcmPathDir] = uigetdir(cd, 'Select Folder to Output Preprocessed Dicom images');
w = waitbar(0, 'Writing CT DICOM images');
for ii = 1: numel(dicom_list)  
    %load CT images
    dicomwrite(ct_uint16(:,:,ii),[dcmPathDir '\image' num2str(ii) '.dcm'],ct_info{ii});
    waitbar(ii/numel(dicom_list),w);
end%for ii = 1: numel(dir_list)    for ii = 1: numel(dicom_list) 
close(w);

writeTable = inputdlg('Write the dicom with the PHANTOM for Table Extraction ?','Yes (Y) or No (N)', 1,{'Y'});
writeTable = writeTable{1};
if (writeTable == 'Y')
[dcmPathDir] = uigetdir(cd, 'Select Folder to Output Preprocessed TABLE images');
w = waitbar(0, 'Writing CT DICOM images');
for ii = 1: numel(dicom_list)  
    %load CT images
    dicomwrite(ct_table(:,:,ii),[dcmPathDir '\image' num2str(ii) '.dcm'],ct_info{ii});
    waitbar(ii/numel(dicom_list),w);
end%for ii = 1: numel(dir_list)    for ii = 1: numel(dicom_list) 
close(w);
end
