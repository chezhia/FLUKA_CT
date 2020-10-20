%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Description:
% This script generates the files required for  HU-material conversion mapping for FLUKA/FLAIR. 
%% INPUT:
%  - Tissue constants (.mat file from HA_Create_tissue_constants.m)
%  - Range file (.csv file containing HU groups,
%    HU_range_file_Table_foam.csv, this file is defined such that Foam and
%    Table are represented in the lowest and highest groups of HU outside of
%    the typical HU range in the scan. )
% 
%% OUTPUT:
%   - Material composition file [Mat_rev.txt] - extension should be renamed
%     to .inp for use in FLAIR.
%   - HU range definition and density scaling with respect to mean density
%     in the range.[Body_rev.txt]. Extension should be renamed to .mat for 
%     use in FLAIR. [Refer to FLAIR/DICOM Manuals for more clarity]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load Tissue range constants (structs containing, HUs, Rhos and elwt)
load('HA_tissue_range_constants_Acquilion_100.mat');

% Read Range File
HU_rangearray = csvread('HA_range_file_Table_foam.csv',0,0);
 
% Open Material and Body files
fid_mat = fopen('HA_FOAM_Mat_Acquilion_100.txt','w');
fid_bod = fopen('HA_FOAM_Body_Acquilion_100.txt','w');

  elwt = zeros(length(HU_rangearray),13);
meanHU = zeros(length(HU_rangearray),1);
%% Calculate Elemental weights
for i = 1:length(HU_rangearray)
meanHU(i,:) = round(mean(HU_rangearray(i,:)));
range_min = HU_rangearray(i,1);
range_max = HU_rangearray(i,2);

if (range_max < -2000)
%%%%% RANGE 7 FOAM
elwt(i,:) = [7.8, 19.1, 64.7, 8.4, 0.0,  0,  0,   0,  0, 0.0, 0.0, 0.0, 0.0]/100; % Foam % From TG195-Case5
            %H,    O,   C,    N,    Cl, Ca,  P,  Mg, Si,   S,   K,  Ar, Na
elseif ((range_max <= -950) & (range_min >= -2000))
%%%%% RANGE 0 fully air    
elwt(i,:) = [0, 23.7, 0.0, 76.5, 0.0,   0,    0,    0,  0,  0.0, 0.0, 1.2827, 0.0]/100; % air
         %   H,    O,   C,    N,  Cl,  Ca,    P,   Mg,  Si,   S,   K,  Ar   , Na

elseif ((range_min > -950) & (range_max <= -122))
%%%%% RANGE 1 (AirFat) %%%%%%%%%%%%  Assigned to LUNG composition
rarray = HU_rangearray(i,:);
elwt(i,:) = [ 10.3, 74.9, 10.5,  3.1, 0.3,  0.0,   0.2,  0.2,  0, 0.3, 0.2, 0.0, 0.0]/100; % Lung
            % H,       O,    C,    N,   Cl,  Ca,   P,    Mg,  Si,  S,   K,    Ar, Na

elseif( (range_min > -122) & (range_max <= 19))
%%%%% RANGE 2 (FatWater) %%%%%%%%%%%%
% For Fat/Water Tissues+ : 1. Adipose (-98), 2. Adrenal gland (14) (Original paper)
rarray = HU_rangearray(i,:);
elwt(i,:) = HA_interpolate_elwt(rarray,FatWater);

elseif( (range_min > 19) & (range_max <= 81))
%%%%% RANGE 3 %%%%%%%%%%%
% Mean Value of all tissues in the range, due to poor correlation with HU number
elwt(i,:) = [10.3, 72.3, 13.4, 3.0, 0.2,  0,  0.2,  0.0,  0, 0.2, 0.2, 0.0, 0.2]/100; %[Average of all tissues in this range]
             %  H,   O,   C,    N,   Cl,  Ca,   P,   Mg,  Si,  S,   K,    Ar, Na

elseif( (range_min > 81) & (range_max <= 120))
%%%% RANGE 4 %%%%% Connective Tissue
elwt(i,:) = [9.4, 62.2, 20.7, 6.2,  0.3,    0,  0.0,   0.0,  0, 0.6, 0.0, 0.0, 0.6]/100;  % Connective Tissue
          %    H,    O,    C,   N,   Cl,   Ca,    P,    Mg,  Si   S,   K,    Ar, Na

elseif( range_min > 2000)
%%%% RANGE 6 %%%%% Carbon  Table
elwt(i,:) = [0,    0, 100.,   0,    0,    0,   0,    0,   0,  0,  0,  0, 0]/100;  % Carbon Table % From TG195-Case5
           % H,    O,    C,   N,   Cl,   Ca,   P,   Mg,  Si,  S,  K, Ar, Na
             
else      %if( (range_min > 120) & (range_max <= 1600))
%%%%% RANGE 5 %%%%%%%%%%%
% For skeletal issues : 1. Bone Marrow (-22), 2. Osseous tissue (1524) (Original paper)
rarray = HU_rangearray(i,:);
elwt(i,:) = HA_interpolate_elwt(rarray,Skeletal);
end

end

%% Calculate Densities
rho = zeros(length(HU_rangearray),3);
mean_rho = zeros(length(HU_rangearray),1);
c1_rho = zeros(length(HU_rangearray),1);
c2_rho = zeros(length(HU_rangearray),1);
for j = 1:length(HU_rangearray)
HU = [meanHU(j),HU_rangearray(j,1),HU_rangearray(j,2)];
for i = 1:length(HU)
% % Foam
if(HU(i) < -2000)
rho(j,i) = 0.105; % Provided by Dominic GE
% % Air
elseif((HU(i) >= -2000) & (HU(i) <= -998))
rho(j,i) = 0.00123000000000000;

% % Air/FAT
elseif((HU(i) > -998) & (HU(i) < -100))
rho(j,i) = HA_interpolate_rhos_stline(HU(i),AirFat);

% % Fat/Water
elseif(( HU(i) >= -100) & (HU(i) < 15))
rho(j,i) = HA_interpolate_rhos(HU(i),FatWater); 

% % GAP
elseif(( HU(i) >= 15) & (HU(i) < 24))
rho(j,i) = 1.03;  % rho for the GAP

% % Soft Tissue
elseif(( HU(i) >= 24) & (HU(i) < 100))
rho(j,i) = HA_interpolate_rhos(HU(i),SoftTis); 

% % Carbon Table
elseif(HU(i) > 2000)
rho(j,i) = 1.5;  % Provided by Dominic GE  
    
% % Skeletal
else   
rho(j,i) = HA_interpolate_rhos(HU(i),Skeletal);
end

end
mean_rho(j) = rho(j,1);      % mean density for the range
c1_rho(j) = rho(j,2)/rho(j,1); % correction factor for minimum density in range
c2_rho(j) = rho(j,3)/rho(j,1); % correction factor for maximum density in range
end

%% Write Fluka Input Files

% %Write values
 fid_mat = write_all_material(fid_mat,mean_rho,elwt,HU_rangearray);
 fclose(fid_mat);
 for i = 1:length(HU_rangearray)
 fprintf(fid_bod,'%d HU<%d %2.9f %2.9f\n',HU_rangearray(i,2), HU_rangearray(i,2), c1_rho(i), c2_rho(i));
 end
 fclose(fid_bod);
 
 %% Optional,Plot Calibration Curve
 % Plot Density vs HU
 figure;

 plot(meanHU,mean_rho,'--ko');
 set(gca,'fontname','times') 
 grid on;
 xlim([-1000 1800])
 title('Density calibration curve for GE Revolution at 120 kVp Tube Voltage');
 ylabel('Density g/cm^{3}');
 xlabel('CT Hounsefiled Values (HU)');
 saveas(gcf,'HU_density_Acquistion.png')
 
 % Create Table for  Material Compositions
T = table(int16(meanHU),elwt(:,1),elwt(:,2),elwt(:,3),elwt(:,4),elwt(:,5),elwt(:,6),elwt(:,7),elwt(:,8));
col_titles = {'HU','HYDROGEN','OXYGEN','CARBON','NITROGEN','CHLORINE',' CALCIUM',' PHOSPHOROUS','MAGNESIUM'};
T.Properties.VariableNames = col_titles;
writetable(T,'HU_elwt_Acquisiton.csv');
