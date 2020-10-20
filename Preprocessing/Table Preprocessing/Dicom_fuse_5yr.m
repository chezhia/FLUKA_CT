%DICOM Preproc
% Removes the background and writes it back to dicom
%% Load Folder Containing DICOM stack
[dcmPathDir] = uigetdir(cd, 'Select Folder Containing Phantom/Patient Dicom Images');

dicom_list = dir([dcmPathDir '\*.dcm']);

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

%% Read Phantom DICOM
ct_info_P = {};
w = waitbar(0, 'Loading CT Phantom/Patient DICOM images');   
ZP =[];
for ii = 1: numel(dicom_list)  
    %load CT images
    ct_original(:,:,ii) = dicomread([dcmPathDir '\' dicom_list(ii).name]);
    ct_info_P{ii} = dicominfo([dcmPathDir '\' dicom_list(ii).name]);
    ZP(ii) = ct_info_P{ii}.SliceLocation;
    waitbar(ii/numel(dicom_list),w);
end%for ii = 1: numel(dir_list)    for ii = 1: numel(dicom_list) 
close(w)

%% Read Full Table DICOM
[dcmPathDir] = uigetdir(cd, 'Select Folder Containing Full TABLE Dicom Images');
dicom_list = dir([dcmPathDir '\*.dcm']);
ct_info_T = {};
w = waitbar(0, 'Loading CT Table DICOM images');   
ZT =[];
ii = 1;
full_table = dicomread([dcmPathDir '\' dicom_list(ii).name]);
ct_info_T{1} = dicominfo([dcmPathDir '\' dicom_list(ii).name]);
%for ii = 1: numel(dicom_list)  
    %load CT images
%     ct_table(:,:,ii) = dicomread([dcmPathDir '\' dicom_list(ii).name]);
%     ct_info_T{ii} = dicominfo([dcmPathDir '\' dicom_list(ii).name]);
%     ZT(ii) = ct_info{ii}.SliceLocation;
%     waitbar(ii/numel(dicom_list),w);
%end%for ii = 1: numel(dir_list)    for ii = 1: numel(dicom_list) 
close(w)

 %% Assign HU range for Table Components
 %%%%% DICOM reads the image in a transposed way, so horizontal is X and
 % vertical axis is Y %%%%%%%%%%%%

 for y = 1:size(full_table,2)
 % Remove Traces of Foam top on the table
 vec = full_table(:,y);
 top = find(vec ~= -2000,1,'first');
 if ~isempty(top)
 bot = find(vec ~= -2000,1,'last');
 vec = vec(top:bot);
 if ~isempty(find(vec == -2000))
 top2 = find(vec==-2000,1,'last');
 top2 = top+top2;
 full_table(top:top2-1,y) = -2000;    
 top = top2;
 end
 end
end
     f_table = reshape(full_table,numel(full_table),1);
     f_table = double(f_table);
       [ind] = kmeans(f_table,3);
   g_mean(1) = mean(f_table(ind==1));
   g_mean(2) = mean(f_table(ind==2));
   g_mean(3) = mean(f_table(ind==3));
[~,tableind] = max(g_mean);
  [~,airind] = min(g_mean);
    foamind = find((g_mean ~= g_mean(tableind)) & (g_mean ~= g_mean(airind)));

 f_table(ind==tableind) = 2500+1024;
 f_table(ind==foamind)  = 3500;
 f_table = reshape(f_table,size(full_table,1),size(full_table,2));
 f_table = int16(f_table);
% [dcmPathDir] = uigetdir(cd, 'Select Folder to Output Rescaled Dicom images');
% dicomwrite(f_table,[dcmPathDir '\imageshifted' '.dcm'],ct_info_T{1});
 full_table = f_table;

[X Y] = find(full_table > -2000);
[uniq_Y] = unique(Y);
Ftable_cntrY = round(mean(Y));
[F_cntrX] = find(Y==Ftable_cntrY);
Ftable_topX = X(F_cntrX);
Ftable_topX = min(Ftable_topX);
imshow(full_table)

%% Read Extracted Table from SCAN for alignment
[dcmPathDir] = uigetdir(cd, 'Select Folder Containing  Dicom Images with TABLE Extracted from Patient/Phantom Scan');
dicom_list = dir([dcmPathDir '\*.dcm']);
ZT =[];
ii = round(length(dicom_list)/2);
ex_table = dicomread([dcmPathDir '\' dicom_list(ii).name]);

%% Find the Distances between Patient bottom and Table Top in the original Scan
% Find the top bright pixel in the center of the image to find table top
cntr_P = round(size(ex_table,1)/2);
min_ct = min(ex_table(:));
extab_top = find(ex_table(:,cntr_P) > min_ct,1);   % again X is the vertical axis

% Find lowest bright pixel in phantom img 
clear X Y;
[X Z] = find(ct_original(:,cntr_P,:)>min_ct);
[pt_bot indZ] = max(X);   

% Find the center patient-table distance
cntr_pt_tab_dist =  extab_top - pt_bot;

%% Find the Center Table Top Pixel in the Full Table
 Ftable_botidx  =  Ftable_topX - cntr_pt_tab_dist;
 Ftable_topidx  =  Ftable_botidx - pt_bot+1;
Ftable_leftidx  =  Ftable_cntrY - cntr_P;
Ftable_rightidx =  Ftable_leftidx + size(ex_table,2)-1;

pt_img = ct_original(1:pt_bot,:,:);
imshow(pt_img(:,:,20))
ct_fused = int16(zeros(size(full_table,1),size(full_table,2),size(pt_img,3)));

% Set range for FOAM by shifting air and setting Foam range as the minimum
 full_table(full_table==-2000) = -976;
  full_table(full_table==3500) = -2000;
  pt_img(pt_img==-2000) = -976; 

for i = 1:size(pt_img,3);
  ct_fused(:,:,i) = (full_table);
  ct_fused(Ftable_topidx:Ftable_botidx,Ftable_leftidx:Ftable_rightidx,i) = pt_img(:,:,i);
    ct_info_P{i}.Rows = ct_info_T{1}.Rows;
    ct_info_P{i}.Columns = ct_info_T{1}.Columns;
    ct_info_P{i}.Width = ct_info_T{1}.Width;
    ct_info_P{i}.Height = ct_info_T{1}.Height;
    ct_info_P{i}.PixelSpacing(1) = ct_info_T{1}.PixelSpacing(1);
    ct_info_P{i}.PixelSpacing(2) = ct_info_T{1}.PixelSpacing(2);
    ct_info_P{i}.ReconstructionDiameter = ct_info_T{1}.ReconstructionDiameter ;
end

%% Write FInal DICOM
% Get output Directory
[dcmPathDir] = uigetdir(cd, 'Select Folder to Output Fused Dicom images');
w = waitbar(0, 'Writing CT DICOM images');
for ii = 1:size(ct_fused,3) 
    %load CT images
    dicomwrite(ct_fused(:,:,ii),[dcmPathDir '\image' num2str(ii) '.dcm'],ct_info_P{ii});
    waitbar(ii/numel(dicom_list),w);
end%for ii = 1: numel(dir_list)    for ii = 1: numel(dicom_list) 
close(w);