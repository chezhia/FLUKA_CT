% Interpolation using schneider's equations
function [elwts] = HA_interpolate_elwt(rarray,component)
elwt = @(h,rho1,rho2,H1,H2,w1,w2) (rho1*(H2 - h) * (w1-w2)...
            /((rho1*H2-rho2*H1) + (rho2-rho1)*h)) +w2;
for i = 1:size(rarray,1)

HU = round((rarray(i,1) + rarray(i,2))/2);
for j = 1:13
elwts(i,j) = elwt(HU,component(1).rho,component(2).rho,component(1).cHU,...
                   component(2).cHU,component(1).elwt(j),component(2).elwt(j)) ;
if(elwts(i,j) < 0.0)
   elwts(i,j) = 0;
end

end

end
end
