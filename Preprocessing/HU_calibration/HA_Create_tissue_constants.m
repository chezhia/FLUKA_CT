%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Description:
% Based on Schneider's paper, different material groupings are generated, their
% densities, elemental weights along with the HU values near the edges are
% assigned. Interpolation will be done within these groups for the
% different HU ranges.
%% INPUT:
% - Calibration constants (.mat file from HA_calibrate.m)
% - Atomic properties (.csv file)
%
%% OUTPUT:
% - Tissue constants (.mat file)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load K constants for the scanner
load('HA_k1k2_Acquilion_100.mat');
k1 = kConsts(1);
k2 = kConsts(2);

% Read Atomic Properties for Elements
Atomic_prop = csvread('HA_Atomic_prop.csv',0,1,[0 1 12 2]);

% %% AirFat
AirFat(1).rho  = 0.00123 ; % 1. Air
AirFat(1).elwt = [0, 23.7, 0.0, 76.5, 0.0,   0,    0,    0,  0,  0.0, 0.0, 1.2827, 0.0]/100; 
                %  H,   O,   C,   N,  Cl,   Ca,   P,  Mg,  Si,   S,     K,     Ar, Na

AirFat(2).rho  = 0.93 ; % 1. Adipose 3
AirFat(2).elwt = [11.6, 19.8, 68.1, 0.2, 0.1,  0,   0,    0,  0, 0.1,  0,  0,0.1]/100; 
                   %  H,   O,   C,     N,  Cl, Ca,   P,  Mg, Si,   S,  K, Ar, Na

AirFat(1).cHU =  round((HA_find_rel_attn(AirFat(1),Atomic_prop,[k1  k2]) - 1)*1000);
AirFat(2).cHU =  round((HA_find_rel_attn(AirFat(2),Atomic_prop,[k1  k2]) - 1)*1000);

%% FatWater
FatWater(1).rho  = 0.93 ; % 1. Adipose 3
FatWater(1).elwt = [11.6, 19.8, 68.1, 0.2, 0.1,  0,   0,   0,  0, 0.1,  0,  0,0.1]/100; 
                   %  H,   O,   C,     N,  Cl, Ca,   P,  Mg,  Si,   S,  K, Ar, Na

FatWater(2).rho  = 1.03 ; % 2. Adrenal gland (14)
FatWater(2).elwt = [10.6, 57.8, 28.4, 2.6, 0.2,  0, 0.1,  0,  0,   0.2, 0.1,   0, 0]/100; 
                   %  H,   O,   C,     N,  Cl,  Ca,   P,  Mg,  Si,   S,   K,  Ar, Na

FatWater(1).cHU =  round((HA_find_rel_attn(FatWater(1),Atomic_prop,[k1  k2]) - 1)*1000);
FatWater(2).cHU =  round((HA_find_rel_attn(FatWater(2),Atomic_prop,[k1  k2]) - 1)*1000);


% %% Soft Tissue
SoftTis(1).rho  = 1.03 ; % 1. Small Intestine
SoftTis(1).elwt = [10.6, 75.1, 11.5, 2.2, 0.2,  0,  0.1,  0.1,   0, 0,  0.1,   0, 0.1]/100; 
                   %  H,   O,   C,     N,  Cl, Ca,    P,   Mg,   Si, S,   K,   Ar, Na

SoftTis(2).rho  = 1.12 ; % 2. Connective Tissue
SoftTis(2).elwt = [9.4, 62.2, 20.7, 6.2,  0.3,    0,  0.0,   0.0,  0, 0.6, 0.0, 0.0, 0.6]/100; 
                   %  H,   O,   C,    N,   Cl,  Ca,   P,   Mg,  Si,     S,   K,  Ar, Na

SoftTis(1).cHU =  round((HA_find_rel_attn(SoftTis(1),Atomic_prop,[k1  k2]) - 1)*1000);
SoftTis(2).cHU =  round((HA_find_rel_attn(SoftTis(2),Atomic_prop,[k1  k2]) - 1)*1000);


%% Skeletal
%% From book: Physical Properties of Tissues: A Comprehensive Reference Book - Francis A Duck
%% RED MARROW
Red.elwt = [10.5,43.9,41.4,3.4,0.2,  0.1,   0.2,   0,  0, 0.2, 0.0,   0, 0.1]/100; 
                   %  H,   O,    C,  N, Cl, Ca,   P,  Mg,  Si,  S,   K,
                   %  Ar, Na
%% YELLOW MARROW 
Yellow.elwt = [11.5,23.1,64.4,0.7,0.1,  0,   0.0,   0,  0, 0.1, 0.0,   0, 0.1]/100; 
                   %  H,   O,    C,  N, Cl, Ca,   P,  Mg,  Si,  S,   K,  Ar, Na
%% Yellow/Red Marrow (1:1)
Red_Yellow.elwt = (Red.elwt + Yellow.elwt)/2;

Skeletal(1).rho  = 1.00 ; % 2. Yellow/red marrow (1:1) 
Skeletal(1).elwt = Red_Yellow.elwt;
                   %  H,   O,    C,  N, Cl, Ca,   P,  Mg,  Si,  S,   K,  Ar, Na

Skeletal(2).rho  = 1.92 ; % 2. Osseous tissue Cortical bone
Skeletal(2).elwt = [3.4,43.5,15.5,4.2,0.0,22.5,10.3,  0.2,  0, 0.3, 0.0,  0, 0.1]/100; 
                   %  H,   O,   C,  N,  Cl, Ca,   P,  Mg,  Si,  S,   K,  Ar, Na

Skeletal(1).cHU =  round((HA_find_rel_attn(Skeletal(1),Atomic_prop,[k1  k2]) - 1)*1000);
Skeletal(2).cHU =  round((HA_find_rel_attn(Skeletal(2),Atomic_prop,[k1  k2]) - 1)*1000);

%% 
save('HA_Tissue_range_constants_Acquilion_100.mat','AirFat','FatWater','SoftTis','Skeletal');