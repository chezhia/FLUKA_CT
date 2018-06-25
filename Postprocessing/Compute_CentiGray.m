% Load Fluence MAT file
[fileName, pathName] = uigetfile({'*.mat'}, 'Load Fluence and Error MAT file');
load([pathName '\' fileName]);

% Mass Attenuation Coefficients (Cm^2/g)
Mass_attn_coeff = [2.48916E-02
2.47206E-02
2.45496E-02
2.43786E-02
2.42076E-02
2.40366E-02
2.38656E-02
2.36946E-02
2.35236E-02
2.33526E-02
2.33320E-02
2.35370E-02
2.37420E-02
2.39470E-02
2.47040E-02
2.62890E-02
2.78740E-02
2.94590E-02
3.25240E-02
3.78090E-02
4.64500E-02
6.01250E-02
8.54040E-02
1.28089E-01
2.30740E-01
4.23340E-01
8.56940E-01
2.69720E+00
9.44600E+00
1.61400E+02];


% Conversion factor from GeV/G to mGy
CF1 = 1.60218E-04;
% Conversion factor from mGy to cGy
CF2 = 1/10;
% Energy Fluence * Mass Attn Coeff *CF1 *CF2
Erg_Exposure_R = Fluence .* Mass_attn_coeff*CF1*CF2;
Error_Exposure_R = Error .* Erg_Exposure_R/100;

Total_Error = sqrt(sum(Error_Exposure_R.^2));
Total_Exposure = sum(Erg_Exposure_R);

% Get the Source Strength
% [1]   80mm Col, 300mAs    |  160mm Col, 300mAs    |    80mm Col, 264mAs   |   160mm Col, 264mAs   |                         
%     2.843847620210007e+13 | 5.326076911770835e+13 | 2.504660018649156e+13 | 4.690832167785994e+13 | 
src_strength = inputdlg('What is the Source Strength?', 'Source Strength', 1,{'2.843847620210007e+13'}); % 
% NEW STRENGTH
% [2]   80mm Col, 300mAs    |  160mm Col, 300mAs    |    80mm Col, 264mAs   |   160mm Col, 264mAs   |                         
%     2.839659175027657e+13 | 5.297638695793696e+13|  2.500971132116001e+13| 4.665785796787241e+13 | 
%     2.839563625595290e+13 | 5.296994472901926e+13 |
src_strength = str2num(src_strength{1});
Total_Error = Total_Error * src_strength;
Total_Exposure = Total_Exposure*src_strength;
Final = ['Exposure is ' num2str(Total_Exposure) ' +/- ' num2str(Total_Error)];
disp(Final)
save('Final Kerma.mat','Total_Exposure','Total_Error');