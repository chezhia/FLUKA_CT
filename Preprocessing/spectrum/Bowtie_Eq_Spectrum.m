%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Created by  Elan Somasundaram - 8/21/2017 %%
%% INPUT:
%     - Measured Bowtie Profile - Select Bowtie_measured.csv
%     - Optimized Al/C filtered spectrum from Equivalent_spec_HVL_EXP.m
%     - Optimized filter thickness from Equivalent_spec_HVL_EXP.m
%
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

clear;
%% Load the Measured Bowtie Profile
[fileName, pathName] = uigetfile({'*.csv'}, 'Load the measured Bowtie Profile');
M = csvread([pathName fileName]); % 1st col - distance from isocenter, 2nd col - corresponding exposure
L = 625.6; % Focal Spot to Isocenter Distance
theta(:) = radtodeg(atan(M(:,1)/L));
Dist = zeros(length(M),1);
Dist(:) = (L^2 + (M(:,1)*10).^2);

%% Measured exposure ratio along the radial axis:
for i = 1:length(M)
ExR_measured(i) = M(i,2)/M(1,2); % M(1,2) is the exposure at the center.
end

%% Load Input Spectra Parameters
% Load the Optimized Spectrum with C and Al filtration - C_Al_Central_Sepctrum.mat
[fileName, pathName] = uigetfile({'*.mat'}, 'Load the Optimized ray spectrum with Al and C filtering .mat');
load([pathName fileName]);
% Load the Corresponding Filter - C_AL_Filters.mat
[fileName, pathName] = uigetfile({'*.mat'}, 'Load the Filters for the Spectrum .mat');
load([pathName fileName]);


%% Optimize the Spectrum for all Bowtie Bins
Exp_central = spektrExposure(spec);
Bowtie_thick(1) = filters(3,2); % Al thickness
Residual(1) = 0;
Bowtie_spec{1} = spec;
for i = 2:length(M)
Filt_spectrum = @(x) spektrBeers(spec,[13 x]);
ExR_calculated = @(x) spektrExposure(Filt_spectrum(x))*Dist(1)/Exp_central/Dist(i);    
optfun = @(x) abs((ExR_measured(i) - ExR_calculated(x))/ExR_measured(i));
options2 = optimset('Display','iter','DiffMinChange',0.2);
[Addl_width RESIDUAL] = lsqnonlin(optfun,2,0,50,options2);
Bowtie_thick(i) = Addl_width + Bowtie_thick(1);
Residual(i) = RESIDUAL ;
Bowtie_spec{i} = Filt_spectrum(Addl_width);
end

%% Reverse the Bowtie profile (0 to 25) to (-25 to 0)
j = length(M);
Temp_thickness = zeros(size(Bowtie_thick));
Temp_spec = {};
for i = 1:length(M)
    Temp_spec{i} = Bowtie_spec{j};
    Temp_thickness(i) = Bowtie_thick(j);
    j = j -1;
end
Bowtie_spec = Temp_spec;
Bowtie_thick = Temp_thickness;
clear Temp_spec Temp_thickness
% For plotting later
% save('Bowtie_Filter_Thickness.mat','Bowtie_thick');
% save('Bowtie_AlC_spec.mat','Bowtie_spec');

% Normalized Bowtie Profile
Norm_Bowtie_spec = zeros(150,length(M));
Bowtie_profile = zeros(length(M),1);
figure;
hold on;
for i = 1:length(M)
Norm_Bowtie_spec(:,i) = spektrNormalize(Bowtie_spec{i});
Bowtie_profile(i) = sum(Bowtie_spec{i});
if (mod(i,5) == 0)
plot(Norm_Bowtie_spec(i,:),'color',rand(1,3));
end
end

% For plotting
% hold off;
% figure;
% plot(M(:,1),Bowtie_profile,'o');
%  save('Norm_Bowtie_spec.mat', 'Norm_Bowtie_spec');
%  save('Bowtie_profile.mat', 'Bowtie_profile');

%% Write CDF of  Spectrum to Text File
fileID = fopen('CDF_Spectrum_1mm.txt','w');
for i = 1:150
fprintf(fileID, '%3.0f',i);    
if i == 1
%src_CDF(i)=Norm_Bowtie_spec(1,1);    
fprintf(fileID,' %2.5e',(Norm_Bowtie_spec(1,:)));
else
%src_CDF(i) = sum(Norm_Bowtie_spec(1:i,1));
fprintf(fileID,' %2.5e',sum(Norm_Bowtie_spec(1:i,:)));
end
if i<150
fprintf(fileID,'\n'); 
end
end
fclose(fileID);


%% Create Bowtie profile from -25 to 25
%Bowtie_profile = M(:,2);
Bowtie_profile_full = zeros(2*length(Bowtie_profile)-1,2);
j = length(Bowtie_profile);
k = 0;
for i = 1:length(Bowtie_profile)
k = k+1;
Bowtie_profile_full(k,1) = -(j-1);
Bowtie_profile_full(k,2) = Bowtie_profile(i);
j = j - 1;
end
j = length(Bowtie_profile);
for i = 2:length(Bowtie_profile)
k = k + 1;
Bowtie_profile_full(k,1) = i-1;
Bowtie_profile_full(k,2) = Bowtie_profile(j-1);
j = j-1;
end

%% Save unnormalized Bowtie profile for source strength calculations
save('Unnormalized_Bowtie_profile.mat','Bowtie_profile_full');

%% Normalize Bowtie profile
Bowtie_profile_full(:,2) = Bowtie_profile_full(:,2) / sum(Bowtie_profile_full(:,2));

%% Write CDF of Bowtie profile to Text File
fileID = fopen('CDF_Bowtie_1mm.txt','w');
for i = 1:length(Bowtie_profile_full)
if i==1
fprintf(fileID,'%2.0f %2.5e\n',Bowtie_profile_full(i,1),Bowtie_profile_full(i,2));
else
fprintf(fileID,'%2.0f %2.5e\n',Bowtie_profile_full(i,1),sum(Bowtie_profile_full(1:i,2)));
end
end
fclose(fileID);


%% For testing purposes
% % Calculated Exposure Ratio
% j = length(Bowtie_spec);
% for i = 1:length(Bowtie_spec)
%     calc_spec_ratio (i,1) = -j+1;
%     calc_spec_ratio(i,2) = spektrExposure(Bowtie_spec{i})/spektrExposure(Bowtie_spec{length(Bowtie_spec)});
%     j = j-1;
% end
