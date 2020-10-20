function [ SoSD ] = exposureFunction(Opt_filter, spectrum, mAs, exposure, source2detector,addedFilt, scale)
%exposureFunction is used by spektrTuner to minimize the difference between
%the spectrum produced by spektrTuner and the experimental spectrum from
%the x-ray tube.
%This is a private function that will be used by spektrTuner
Tot_Filter = [Opt_filter;addedFilt];
    for i = 1:size(mAs, 1)
        q = spectrum;    
        q_corrected = spektrBeers(q, Tot_Filter);
        % qfiltered = spektrBeers(q_corrected, [Filt_mat1 x(1); Filt_mat2 x(2)]);
        expo_sim(i,1) = spektrExposure(q_corrected*scale) * mAs(i,1)* 1000^2/source2detector^2;
       %                               mR/mAs @ 1000mm      *   mAs     *    (1000^2/mm^2)
    end
percDiff = (exposure - expo_sim) ./ (expo_sim);
SoSD = sum(abs(percDiff));
end
