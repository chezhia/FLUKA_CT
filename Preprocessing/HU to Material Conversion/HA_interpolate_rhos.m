% Interpolate Density values using linear interpolation
function [rhos] = HA_interpolate_rhos(HU,component)
rho = @(h,rho1,rho2,H1,H2) (rho1*H2 - rho2*H1 + (rho2-rho1)*h)/(H2-H1);
rhos = rho(HU,component(1).rho,component(2).rho,component(1).cHU,...
                   component(2).cHU); 
end
