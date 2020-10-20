function [SoSD] = hvlFunction(x, spectrum, measuredHVL,addedFilt, Filt_mat1, Filt_mat2)
%[HardeningF_width(i) Residual(i)]= find_hardFilt_width(unFilt_TASMICS, addedFilt(1), addedFilt(2), HardeningF_mat(i),hvl1_measured);
filters = [addedFilt(1) addedFilt(2); Filt_mat1 x(1); Filt_mat2 x(2)];
candidate_spec = spektrBeers(spectrum,filters);
HVL_sim = spektrHVLn(candidate_spec,1,13);
%HVL_sim = find_al_HVL(1,candidate_spec,spektrExposure(candidate_spec));
percDiff = (measuredHVL - HVL_sim)/(HVL_sim);
SoSD = sum(abs(percDiff));
end
