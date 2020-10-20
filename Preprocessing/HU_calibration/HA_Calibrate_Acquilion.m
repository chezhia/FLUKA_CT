%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Desccription:
% This Script follows the procedure in Schneider et al (2000) to find the
% calibration constants to calculate HU values for a particular scanner for
% any tissue. Requires measured HU values for a phantom with various
% tissues.
%% INPUT:
%  - Measurement values of HU for different known materials (.csv)
%  - Atomic properties (.csv)
%
%% OUTPUT:
% - Calibration constants (.mat file)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read Tissue Properties [
%[fileName, pathName] = uigetfile({'*.csv'}, 'Select the CSV file containing the Tissue properties for your Phantom');
Tissue_data = csvread('HA_PhantomMeasurements_Aquilion.csv',2,2,[2 2 2+4 2+14]); % Phantom Measurements for 22 tissues types.
for i = 1:size(Tissue_data,1)
Tissue_prop(i).mHU = Tissue_data(i,1);      % Measured HU
Tissue_prop(i).rho = Tissue_data(i,2);     % Density
Tissue_prop(i).elwt = Tissue_data(i,3:size(Tissue_data,2))/100; % Elemental weights for 9 elements                                                % convert from percentages to fractions
end
 
% Read Atomic Properties for Elements
Atomic_prop = csvread('HA_Atomic_prop.csv',0,1,[0 1 12 2]); % Read A and Z values for 9 elements

% Calibrate to find constants K1 and K2 using Eq 10 and 11 in Schneider et
% al (2000)
diff_sq = @(x,k) (HA_find_rel_attn(x,Atomic_prop,k) - (x.mHU/1000 + 1))^2;
dummy = @(x,k) sum(x.elwt)*k(1)*k(2);
% for i = 1:size(Tissue_data,1)
% 
% end
final_fun = @(k) diff_sq(Tissue_prop(01),k) +... % 1
                 diff_sq(Tissue_prop(02),k) +... % 2
                 diff_sq(Tissue_prop(03),k) +... % 3
                 diff_sq(Tissue_prop(04),k) +... % 4
                 diff_sq(Tissue_prop(05),k) ;%+... % 5
%                  diff_sq(Tissue_prop(06),k) +... % 6
%                  diff_sq(Tissue_prop(07),k) +... % 7
%                  diff_sq(Tissue_prop(08),k) +... % 8
%                  diff_sq(Tissue_prop(09),k) +... % 9
%                  diff_sq(Tissue_prop(10),k) +... % 10
%                  diff_sq(Tissue_prop(11),k) +... % 11
%                  diff_sq(Tissue_prop(12),k) +... % 12
%                  diff_sq(Tissue_prop(13),k) +... % 13
%                  diff_sq(Tissue_prop(14),k) +... % 14
%                  diff_sq(Tissue_prop(15),k) +... % 15
%                  diff_sq(Tissue_prop(16),k) +... % 16
%                  diff_sq(Tissue_prop(17),k) +... % 17
%                  diff_sq(Tissue_prop(18),k) +... % 18
%                  diff_sq(Tissue_prop(19),k) +... % 19
%                  diff_sq(Tissue_prop(20),k) +... % 20
%                  diff_sq(Tissue_prop(21),k) +... % 21
%                  diff_sq(Tissue_prop(22),k) ;    % 22
                 
options = optimset('Display','iter');
options.TolX = 1e-06;
options.TolFun = 1e-08;
[kConsts,FVAL,EXITFLAG,OUTPUT] = fminsearch(final_fun, [1.24e-2 3.06e-2],options);  % Initial guesses = values from schneider et al   
save('HA_k1k2_Acquilion_100.mat','kConsts');
