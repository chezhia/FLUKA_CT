% Load Measured Profile
[fileName, pathName] = uigetfile({'*.mat'}, 'Select Measured Surface');
load([pathName fileName]);

[fileName, pathName] = uigetfile({'*.mat'}, 'Select Simulated Surface');
load([pathName fileName]);
x_ax = x_ax';
z_ax = z_ax';

% Find X and Z range for both surfaces
OUT_X = -24.5:1:24.5;
OUT_Z = -4:1:4;


[X_M,Z_M] = meshgrid(x_profile,z_profile);
[X_S,Z_S] = meshgrid(x_ax,z_ax);

[X_Q,Z_Q] = meshgrid(OUT_X',OUT_Z');
OUT_Measured = interp2(X_M,Z_M,Measured_profile',X_Q,Z_Q);
OUT_Simulated = interp2(X_S,Z_S,FL_P',X_Q,Z_Q);
figure;
surf(OUT_X,OUT_Z,OUT_Measured)
figure;
surf(OUT_X,OUT_Z,OUT_Simulated)
figure;
surf(OUT_X,OUT_Z,OUT_Measured-OUT_Simulated);