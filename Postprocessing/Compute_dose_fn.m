function [] = Compute_dose_fn(SFOV,Eff_Col,mAs,ssd,spec,pathName,fileName)
load([pathName '/' fileName]);

%% Conversion factor from GeV/G to mGy
CF1 = 1.60218E-04;

%% Compute Absolute Dose
%Energy Fluence * Mass Attn Coeff *CF1 *CF2
Erg_Exposure_R = Fluence.*CF1;
Error_Exposure_R = Error.* Erg_Exposure_R/100;

% Get the Source Strength
% src_strength =  Photons/mm^2/mAs * mAs  * mm^2

src_strength =  sum(spec(:)) * mAs * SFOV * Eff_Col *1000^2/ssd^2;


Final_Dose = Erg_Exposure_R .* src_strength;
Final_Error = Error_Exposure_R .* src_strength;

if size(Fluence,2)==1
Dosenames = {'Left Ovary','Right Ovary','Left Testis','Right Testis'};
for i = 1:length(Final_Dose)
    Final = [Dosenames(i) 'dose (mGy) is ' num2str(Final_Dose(i)) ' +/- ' num2str(Final_Error(i))];
    disp(Final);
end
end

Fluence = Final_Dose;
Error = Final_Error;
save([pathName 'Dose_' fileName],'Fluence','Error','binsize','binlimits');
end

