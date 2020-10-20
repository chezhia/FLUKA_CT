%% Find relative attenuation with respect to H20
function [opt_fun1] = HA_find_rel_attn(Tissue_prop,Atomic_prop,k)
% H2O Constants
    rho_H2O = 0.9982; % g/cc @ 20 deg C
    w_H = 11.19/100;;
    w_O = (100-11.19)/100;
    A_H = 1.008;
    A_O = 15.999;

% Other Constants
rho_ratio = Tissue_prop.rho/rho_H2O;
H_ratio  = w_H/A_H;
O_ratio = w_O/A_O;
c1 = 8;
c2 = 8^(2.86);
c3 = 8^(4.62);

% Aliases
Z = Atomic_prop(:,2);
A = Atomic_prop(:,1);
w = Tissue_prop.elwt';

num = @(x1) (w./A) .* (Z + (Z.^2.86)*x1(1) + (Z.^4.62)*x1(2));
denom = @(x1) (H_ratio)*(1+x1(1)+x1(2)) + O_ratio*(c1+c2*x1(1)+c3*x1(2));
opt_fun1 =  rho_ratio * sum(num(k))/denom(k); 
end
