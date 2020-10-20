%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Created by  Elan Somasundaram - 8/21/2017 %%
%% Generates a Equivalent Spectrum by optimizing on Exposure and HVL Measurements
%% Uses both spektrTuner (Exposure) and Adam Turner's HVL optimization method
%% INPUT:
% - Input Current (mA) vs Exposure (mR) Measurement (.csv)
% - HVL in mm [input dlg]
%% OUTPUT:
% - Carbon+Aluminimum Filtered Spectra (.mat)
% - Carbon+Al Filter Thickness (.mat)
% - Carboon Filtered Spectra (.mat) - this is for reference only
% - Carbon Thickness (.mat) - for reference only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Initial X-ray spectrum was generated using two options in Spektr:
%% TASMICS and TASMICS_normalized spectrums - Check Spektr Documentation for details.
%% Both unormalized and normalized spectrum produced the same final spectrum after optimizing, so should be fine to use either. 
% 1 - Unnormalized Spectrum, 2 - Normalized Spectrum;
unFilt_TASMICS = zeros(150,2);
unFilt_TASMICS(:,1) = spektrSpectrum(120,[0 0],'TASMICS',0);
unFilt_TASMICS(:,2) = spektrSpectrum(120,[0 0],'TASMICS',1);

%% Plot initial spectra
figure(1);
plot(unFilt_TASMICS(:,1),'r');
hold on;
plot(unFilt_TASMICS(:,2),'o');
names = {['TASMICS |' ' I = ' num2str(sum(unFilt_TASMICS(:,1)))];['TASMICS Norm |' ' I = ' num2str(sum(unFilt_TASMICS(:,2)))]};
legend(names);
hold off;


%% Filter Material Definition - Carbon 06, Aluminum 13.
Filt_mat1 = 06;
Filt_mat2 = 13;

%% Load Measured Variables
hvl1_measured = 7.6 ; % @120kv for large body given by GE
hvl1_measured = inputdlg('Enter the HVL for the Tube Potential and Filter Configuration','Half Value Layer in mm',1,{'7.6'});
hvl1_measured = str2num(hvl1_measured{1});

SDD = 625.6; % GE Revolution - Tube 2 ISO Center distance 
SDD = inputdlg('Enter the Tube to Isocenter Distance for the Scanner','Tube to Iso Distance in mm',1,{'625.6'});
SDD = str2num(SDD{1});


mat = [13 0]; % Additional Filter thickness set to 0.
[fileName, pathName] = uigetfile({'*.csv'}, 'Load the Current vs Exposure Table');
cur_exp = csvread([pathName fileName]); %% Select the cur-exposure.csv file here.

%% Optimize the spectrum to match the HVL and Exposure values of the Tube
for (i = 1:2)
%Calculate HALF VALUE LAYER of Al for the UnFiltered Spectrum
hvl_unfilt = spektrHVLn(unFilt_TASMICS(:,i),1,13);
% Optimization - Outputs the filter thickness for Al and C, and the Scaling Factor required to match the HVL and Exposure measurements
[Final{i}.filters Final{i}.scale] = HVL_EXP_Tuner(unFilt_TASMICS(:,i),cur_exp(:,1),cur_exp(:,2),SDD,mat,hvl1_measured,[Filt_mat1 3 ;Filt_mat2 5]);
% Calculate the final spectrum by applying the calculated filter and scale parameters
Final{i}.spec = spektrBeers(unFilt_TASMICS(:,i),Final{i}.filters)*Final{i}.scale;
% Plot the final spectra 
if i == 1
plot(Final{i}.spec,'b');
else
plot(Final{i}.spec,'y');
end
% Calculate the HVL and Exposure @ 300mAs of the final Spectra at
% Iso-center for verification purposes
Final{i}.hvl = spektrHVLn(Final{i}.spec,1,13);
Final{i}.exp_300MaS = spektrExposure(Final{i}.spec)*300* (1000/625.6)^2;
end

%% For Modeling the Aluminum Bowtie Filter Explicitly, we just need the Carbon Filtered Spectrum
% Find the Spectrum with Carbon Filtration alone
Carb_spec(:,1)= spektrBeers(unFilt_TASMICS(:,1),[Final{1}.filters(2,:)])*Final{1}.scale;
Carb_spec(:,2)= spektrBeers(unFilt_TASMICS(:,2),[Final{2}.filters(2,:)])*Final{2}.scale;



%% Save the ouput for the unfiltered TASMICS spectrum:
% Final spectrum with Al and C filtering.
spec = Final{1}.spec;
save('C_AL_Central_Spectrum.mat','spec');
% Final Spectrum with only Carbon filtering - Use only if Bowtie Filter is
% modeled explicitly in the geoemtry
spec = Carb_spec(:,1);
save('C_Central_Spectrum.mat','spec');
% Save Filter thickness for Bowtie optimization
filters = Final{1}.filters;
save('C_AL_Filters.mat','filters');
% Optional: Save normalized Carbon spectra
Norm_spec = spektrNormalize(Carb_spec(:,1));
save('Norm_C_Spectra.mat','Norm_spec');