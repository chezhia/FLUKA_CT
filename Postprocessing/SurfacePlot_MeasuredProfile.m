
%% Load Heel Effect Profile measured using Film
[fileName, pathName] = uigetfile({'*.xlsx'}, 'Select Excel file that has the heel profile');
[heel_profile,~,~] = xlsread([pathName '\' fileName],1);
% Effective Collimation for CDFs that are centered within the bins 
HBIN_size = heel_profile(2,1)-heel_profile(1,1); % heel bin size
Eff_Col = length(heel_profile)*HBIN_size*10; % cm to mm


%% Normalize Heel profile
% Find the point closes to zero and use the intensity to normalize
[~,zero_ind] = min(abs(heel_profile));
intensity_0 = heel_profile(zero_ind(1),2);
% Normalize
heel_profile(:,2) = heel_profile(:,2)/intensity_0;
% Convert cm to mm
heel_profile(:,1) = heel_profile(:,1)*10;
plot(heel_profile(:,1)/10,heel_profile(:,2),'*')


%% Load Bowtie Spectrum calculated using SPEKTR 
% Spectrum is in units photons/mm^2/mAs per 1 KeV bins from 1-150 KeV at
% 100 cm from the source
[fileName, pathName] = uigetfile({'*.mat'}, 'Select Unnormalized Bowtie spectrum');
load([pathName fileName]);
SDD = 625.6; %mm
SDD_2 = SDD^2;
% Convert cm to mm
Bowtie_profile_full(:,1) = Bowtie_profile_full(:,1)*10;

for i = 1:(length(Bowtie_profile_full)) % The 50th measurements has half the bin area
    D2 = SDD_2 + Bowtie_profile_full(i,1)^2;
    Bowtie_profile_full(i,2) = Bowtie_profile_full(i,2); %/D2; % 
end
Bowtie_profile_full(:,2) = Bowtie_profile_full(:,2)/max(Bowtie_profile_full(:,2));



Measured_profile = zeros(length(Bowtie_profile_full),length(heel_profile));
for i = 1:length(Bowtie_profile_full)
    for j = 1:length(heel_profile)
        Measured_profile(i,j) = Bowtie_profile_full(i,2)*heel_profile(j,2);
    end
end
x_profile = Bowtie_profile_full(:,1)/10; % in cm
z_profile = heel_profile(:,1)/10;   % in cm
figure;
surf(x_profile',z_profile',Measured_profile')
save('MeasuredUNI.mat','x_profile','z_profile','Measured_profile');