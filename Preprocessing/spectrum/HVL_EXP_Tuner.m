function [ filtration,scale ] = HVL_EXP_Tuner( spectrum, mAs, exposure, source2distance, addedFilt, measuredHVL, varargin )
display('Calculating Tuning Filtration....');
if size(varargin, 2) == 0
    estim_mat1 = 0;
    estim_mat2 = 0;
    Filt_mat1 = 13;% Default 1 [only if no filter mat defined]
    Filt_mat2 = 74;% Default 2 [only if no filter mat defined]
else
    estimates = varargin{:};
    estim1 = estimates(1,:);
    estim2 = estimates(2,:);
    estim_mat1 = estimates(1,2);
    estim_mat2 = estimates(2,2);
    Filt_mat1 = estimates(1,1)  ;
    Filt_mat2 = estimates(2,1) ;
end

%% Optimize for HVL
optim_func = @(x) hvlFunction(x, spectrum, measuredHVL,addedFilt, Filt_mat1, Filt_mat2) ;%+...
    %exposureFunction(x, spectrum, mAs, exposure, source2distance, addedFilt, Filt_mat1, Filt_mat2);
options = optimset('Display','iter');
[filters,FVAL,EXITFLAG,OUTPUT] = fminsearch(optim_func, [estim_mat1 estim_mat2],options);      
HVLerr = hvlFunction(filters,spectrum, measuredHVL, addedFilt, Filt_mat1, Filt_mat2)

%% Optimize for EXP
Opt_filter = [Filt_mat1,filters(1);Filt_mat2,filters(2)];
optim_func2 = @(y) exposureFunction2(Opt_filter,spectrum,mAs, exposure, source2distance,addedFilt,y);
[scale,FVAL,EXITFLAG,OUTPUT] = fminsearch(optim_func2,[10],options);      
%EXPerr = exposureFunction(filters,spectrum,mAs, exposure, source2distance, addedFilt, Filt_mat1, Filt_mat2);
EXPerr = exposureFunction2(Opt_filter,spectrum,mAs, exposure, source2distance,addedFilt,scale)
%EXITFLAG
%OUTPUT
[filtration] = [addedFilt(1) addedFilt(2); Filt_mat1 filters(1); Filt_mat2 filters(2)];
end

function [ SoSD ] = exposureFunction2(Opt_filter, spectrum, mAs, exposure, source2detector,addedFilt, scale)
%exposureFunction is used by spektrTuner to minimize the difference between
%the spectrum produced by spektrTuner and the experimental spectrum from
%the x-ray tube.
%This is a private function that will be used by spektrTuner
Tot_Filter = [Opt_filter;addedFilt];
    for i = 1:size(mAs, 1)
        q = spectrum;    
        q_corrected = spektrBeers(q, Tot_Filter);
        % qfiltered = spektrBeers(q_corrected, [Filt_mat1 x(1); Filt_mat2 x(2)]);
        expo_sim(i,1) = spektrExposure(q_corrected*scale) * mAs(i,1)* (1000/source2detector)^2;
       %                               mR/mAs @ 1000mm      *   mAs     *    (1000^2/mm^2)
    end
percDiff = (exposure - expo_sim) ./ (expo_sim);
SoSD = sum(abs(percDiff));
end

% Do not use!
% function [ SoSD ] = exposureFunction(x, spectrum, mAs, exposure, source2detector, addedFilt, Filt_mat1, Filt_mat2)
% %exposureFunction is used by spektrTuner to minimize the difference between
% %the spectrum produced by spektrTuner and the experimental spectrum from
% %the x-ray tube.
% %This is a private function that will be used by spektrTuner
%     for i = 1:size(mAs, 1)
%         q = spectrum;    
%         q_corrected = spektrBeers(q, addedFilt);
%         qfiltered = spektrBeers(q_corrected, [Filt_mat1 x(1); Filt_mat2 x(2)]);
%         expo_sim(i,1) = spektrExposure(qfiltered) * mAs(i,1)* (1000/source2detector)^2;
%        %                               mR/mAs @ 1000mm      *   mAs     *    (1000^2/mm^2)
%     end
% percDiff = (exposure - expo_sim) ./ (expo_sim);
% SoSD = sum(abs(percDiff));
% end

function [SoSD] = hvlFunction(x, spectrum, measuredHVL,addedFilt, Filt_mat1, Filt_mat2)
%[HardeningF_width(i) Residual(i)]= find_hardFilt_width(unFilt_TASMICS, addedFilt(1), addedFilt(2), HardeningF_mat(i),hvl1_measured);
filters = [addedFilt(1) addedFilt(2); Filt_mat1 x(1); Filt_mat2 x(2)];
candidate_spec = spektrBeers(spectrum,filters);
HVL_sim = spektrHVLn(candidate_spec,1,13);
%HVL_sim = find_al_HVL(1,candidate_spec,spektrExposure(candidate_spec));
percDiff = (measuredHVL - HVL_sim)/(HVL_sim);
SoSD = sum(abs(percDiff));
end