%% Straight line interpolation of density values from HU values. 
%% Returns array of density values for min_HU, mean_HU and max_HU in each bin
function [rhos] = HA_interpolate_rhos_stline(HU,component)
% Linear Interpolation based
rho_st = @(HU,rho_min,rho_max,HU_min,HU_max) rho_min + (HU-HU_min)*(rho_max-rho_min)/(HU_max-HU_min);

rhos = rho_st(HU,component(1).rho,component(2).rho,component(1).cHU,...
                   component(2).cHU); 
               
end