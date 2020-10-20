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
clear all;

title = 'CU_kvp87_hvl_5_29'
kvp = 87;
hvl = 5.29
exposure = 3.8398
mAs = 1
source2distance = 1000

TASMICS = spektrSpectrum(kvp,[0 0],'TASMICS',1);

%% Plot initial spectra
figure(1);
plot(TASMICS(:,1),'r');
hold on;

hvl_unfilt = spektrHVLn(TASMICS(:,1),1,13);

% Optimize for HVL
measuredHVL = hvl
spectrum = TASMICS;

% Cu Filtration
addedFilt  = [29 0.1];
% Zero Filtration
%addedFilt  = [29 0];

Filt_mat1 = 13;
Filt_mat2 = 13;

optim_func = @(x) hvlFunction(x, spectrum, measuredHVL,addedFilt, Filt_mat1, Filt_mat2) ;%+...
    %exposureFunction(x, spectrum, mAs, exposure, source2distance, addedFilt, Filt_mat1, Filt_mat2);
options = optimset('Display','iter');
[filters,FVAL,EXITFLAG,OUTPUT] = fminsearch(optim_func, [1 1],options);      
HVLerr = hvlFunction(filters,spectrum, measuredHVL, addedFilt, Filt_mat1, Filt_mat2)

Al_opt = sum(filters)

TASMICS_Al = spektrBeers(TASMICS,[addedFilt(1) addedFilt(2);Filt_mat1 filters(1);Filt_mat2 filters(2)]);

plot(TASMICS_Al,'g');

% Optimize spectra for exposure
exp_meas = spektrExposure(TASMICS_Al) % mR/mAs at 100cm or 1000mm


Opt_filter = [Filt_mat1,filters(1);Filt_mat2,filters(2)];
optim_func2 = @(y) exposureFunction(Opt_filter,spectrum,mAs, exposure, source2distance,addedFilt,y);
[scale,FVAL,EXITFLAG,OUTPUT] = fminsearch(optim_func2,[10],options);      
%EXPerr = exposureFunction(filters,spectrum,mAs, exposure, source2distance, addedFilt, Filt_mat1, Filt_mat2);
EXPerr = exposureFunction(Opt_filter,spectrum,mAs, exposure, source2distance,addedFilt,scale)
%EXITFLAG
%OUTPUT

 TASMICS_Al_scale = TASMICS_Al*scale;

plot(TASMICS_Al_scale,'m');
%set(gca, 'YScale', 'log')

exp_opt = spektrExposure(TASMICS_Al_scale)
hvl_opt = spektrHVLn(TASMICS_Al_scale,1,13)

% Save the ouput for the unfiltered TASMICS spectrum:
% Final spectrum with Al and C filtering.
spec = TASMICS_Al_scale;
save(['Spectra_' title '.mat'],'spec');

Norm_spec = spektrNormalize(spec);

fileID = fopen(['CDF_' title '.txt'],'w');
for i = 1:length(Norm_spec)
if i==1
fprintf(fileID,'%2.0f %2.5e\n',i,Norm_spec(i));
else
fprintf(fileID,'%2.0f %2.5e\n',i,sum(Norm_spec(1:i)));
end
end
fclose(fileID);