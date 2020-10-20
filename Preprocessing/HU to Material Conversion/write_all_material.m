function [fid] = write_material_C5P(fid,mean_rho,elwt,HU_rangearray)
%WRITE_MATERIAL Summary of this function goes here
%   Detailed explanation goes here

mat_list = ['HYDROGEN'; '  OXYGEN';'  CARBON';'NITROGEN';'CHLORINE';' CALCIUM';' PHOSPHO';'MAGNESIU';' SILICON'];
for i = 1:length(HU_rangearray)
fprintf(fid,'* MIXTURE : HU<%d \n',HU_rangearray(i,2));
if (elwt(i,:) >= -0.000001)
 %elwt(i,:) = -elwt(i,:);
% fprintf(fid,'MATERIAL                       %0.5e                         0.HU<%d\n',mean_rho(i),HU_rangearray(i,2));
% fprintf(fid,'COMPOUND      -%2.3f  HYDROGEN    -%2.3f    OXYGEN    -%2.3f    CARBONHU<%d\n',elwt(i,1),elwt(i,2),elwt(i,3),HU_rangearray(i,2));
% fprintf(fid,'COMPOUND      -%2.3f  NITROGEN    -%2.3f  CHLORINE    -%2.3f   CALCIUMHU<%d\n',elwt(i,4),elwt(i,5),elwt(i,6),HU_rangearray(i,2));
% fprintf(fid,'COMPOUND      -%2.3f   PHOSPHO    -%2.3f  MAGNESIU    -%2.3f   SILICONHU<%d\n',elwt(i,7),elwt(i,8),elwt(i,9),HU_rangearray(i,2));   
%%%
fprintf(fid,'MATERIAL                        %2.6f                            0.HU<%d\n',mean_rho(i),HU_rangearray(i,2));
lcount = 0;mcount = 0;
for j = 1:length(mat_list)
    if((elwt(i,j)> 0 )& (lcount==0))
      fprintf(fid,'COMPOUND    -%02.5f  %s',elwt(i,j),mat_list(j,:));
      lcount = lcount + 1;
    elseif(elwt(i,j) > 0)
      fprintf(fid,'  -%02.5f  %s',elwt(i,j),mat_list(j,:));
      lcount = lcount + 1;
    end
    if (lcount == 3)
    fprintf(fid,'HU<%d\n',HU_rangearray(i,2));
    lcount = 0;
    end
end
    if (lcount==2)
        fprintf(fid,'                    HU<%d\n',HU_rangearray(i,2));
    elseif(lcount==1)                    
        fprintf(fid,'                                        HU<%d\n',HU_rangearray(i,2));
    end
else                                                      
    disp(['elemental weights interpolated are negative - in range ' num2str(i)]);
    format long;
    disp(elwt(i,:));
    pause;
end
end 
end