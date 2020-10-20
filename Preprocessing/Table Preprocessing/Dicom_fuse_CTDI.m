clear all;
% DICOM FUSE
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
% Removes Traces of Foam from the table
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
% [dcmPathDir] = uigetdir(cd, 'Select Folder to Output Cleaned Table Image');
% dicomwrite(f_table,[dcmPathDir '\imageshifted' '.dcm'],ct_info_T{1});
 full_table = f_table;

 
% Get table indices and shift table to the bottom of the image 
[X Y] = find(full_table > -2000);
[uniq_Y] = unique(Y);
Ftable_cntrY = round(mean(Y));
[F_cntrX] = find(Y==Ftable_cntrY);

% Get the bottom most pixel of the table
Ftable_botX = max(X(F_cntrX));

X_max = size(full_table,2);
full_table_new = int16(ones(size(full_table,1),size(full_table,2)))*full_table(1,1);
full_table_new((X_max-9-Ftable_botX):(X_max-10),:) = full_table(1:Ftable_botX,:);
full_table = full_table_new;
clear X Y uniq_Y Ftable_cntrY F_cntrX;
clear full_table_new f_table;
% Recalculate the table indices after the table is shifted to the bottom of
% the image
[X Y] = find(full_table > -2000);
[uniq_Y] = unique(Y);
Ftable_cntrY = round(mean(Y));
[F_cntrX] = find(Y==Ftable_cntrY);
% Find Top most pixel of the table at the center
Ftable_topX = X(F_cntrX);
Ftable_topX = min(Ftable_topX);

imshow(full_table)

%% Read Extracted Table from SCAN for alignment
% [dcmPathDir] = uigetdir(cd, 'Select Folder Containing  Dicom Images with TABLE Extracted from Patient/Phantom Scan');
% dicom_list = dir([dcmPathDir '\*.dcm']);
% ZT =[];
% ii = round(length(dicom_list)/2);
% ex_table = dicomread([dcmPathDir '\' dicom_list(ii).name]);
% 
% %% Find the Distances between Patient bottom and Table Top in the original Scan
% % Find the top bright pixel in the center of the image to find table top
% cntr_P = round(size(ex_table,1)/2);
% min_ct = min(ex_table(:));
% extab_top = find(ex_table(:,cntr_P) > min_ct,1);   % again X is the vertical axis

% The preprocessing script does not work well for CTDI Phantom table
% extraction. So manually calculate the Phantom Table Gap and enter here:
extab_top = inputdlg('Enter the gap distance in mm between CTDI phantom and Table Top','Value', 1,{'13.00'});
extab_top = str2num(extab_top{1});
% Convert dist in mm to pixels
extab_top = round(extab_top / ct_info_P{1}.PixelSpacing(1));
% Find the center patient-table distance
cntr_pt_tab_dist =  extab_top ;

min_ct = min(ct_original(:));
cntr_P = round(size(ct_original(:,:,1),1)/2);
% Find lowest bright pixel in phantom img 
clear X Y;
[X Z] = find(ct_original(:,cntr_P,:)>min_ct);
[pt_bot indZ] = max(X);   

% Find left most and right most bright pixel in phantom img 
clear X Y;
% reshape to a matrix

cntr_mat = ct_original(cntr_P,:,:);
cntr_mat = reshape(cntr_mat,size(ct_original,2),size(ct_original,3));
[X Y] = find(cntr_mat>min_ct);
[pt_right indRight] = max(X);   
[pt_left indLeft] = min(X);   



%% Find the Center Table Top Pixel in the Full Table
 Ftable_botidx  =  Ftable_topX - cntr_pt_tab_dist;
 Ftable_topidx  =  Ftable_botidx - pt_bot+1;
Ftable_leftidx  =  Ftable_cntrY - cntr_P + pt_left;
Ftable_rightidx =  Ftable_leftidx + pt_right-pt_left;
 
 
% Ftable_leftidx  =  Ftable_cntrY - cntr_P;
% Ftable_rightidx =  Ftable_leftidx + size(ct_original(:,:,1),2)-1;

pt_img = ct_original(1:pt_bot,pt_left:pt_right,:);
imshow(pt_img(:,:,20))

ct_fused = int16(zeros(size(full_table,1),size(full_table,2),size(pt_img,3)));

% Set range for FOAM by shifting air and setting Foam range as the minimum
 full_table(full_table==-2000) = 0;
 full_table(full_table==3500) = -2000;
 pt_img(pt_img==-2000) = 0; 
 pt_img(pt_img < 1024-100) = 0;  % Assign Holes to Air material as well
 pt_img(pt_img > 1024-100) = 100+1024; % CTDI Phantom Material
 
% Change Air within Phantom to Different HU, for easy tallying
for i = 1:size(pt_img,3)
    cur_img = pt_img(:,:,i);
for y = 1:size(cur_img,2)
 vec = cur_img(:,y);
 top = find(vec ~= 0,1,'first');
 if ~isempty(top)
 bot = find(vec ~= 0,1,'last');
 vec = vec(top:bot);
 vec(vec==0) = 1024; % Sets the tally regions to 0 HU
 cur_img(top:bot,y) = vec;    
 end
end
pt_img(:,:,i) = cur_img;
end
 
for i = 1:size(pt_img,3);
  ct_fused(:,:,i) = zeros(size(full_table,1),size(full_table,2));
      % Write the first and last slices of the CTDI phantom from adjacent
    % slices as they are not reconstructed properly
    if (i<=5)
      ct_fused(Ftable_topidx:Ftable_botidx,Ftable_leftidx:Ftable_rightidx,i) = pt_img(:,:,6);
    elseif(i>=34)
     ct_fused(Ftable_topidx:Ftable_botidx,Ftable_leftidx:Ftable_rightidx,i) = pt_img(:,:,33);   
    else
     ct_fused(Ftable_topidx:Ftable_botidx,Ftable_leftidx:Ftable_rightidx,i) = pt_img(:,:,i);
    end
  ct_fused(:,:,i) = ct_fused(:,:,i) + full_table;
  ct_fused(ct_fused==0)=-976;
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

    dicomwrite(ct_fused(:,:,ii),[dcmPathDir '\image' num2str(ii) '.dcm'],ct_info_P{ii});
    waitbar(ii/numel(dicom_list),w);
end%for ii = 1: numel(dir_list)    for ii = 1: numel(dicom_list) 
close(w);