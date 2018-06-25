%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Created by Elan Somasundaram 08/23/2017
%% Description: 
% Script to find the absolute dose values for 25 MOSFET detectors 
% in Phantom simulations from USRBIN Dose tally. It also compares the 
% simulation to the  measurement values and generates a plot
%% INPUT: 
%       -  The ".lis" file containing the dose values and errors
%       -  The photon source strength calculated in the preprocessing stage
%       -  Z-axis location of the MOSFET detectors (Z-locations.csv)
%       -  Measured Dose and Error values (Measured_dose.csv)
%       -  Change the Mosfet_order variable in the script for the specific
%          simulation/Mosfet-loading
%% OUTPUT:
%       - .mat file containing the Absolute Dose and Error.
%       - .png plot comparing FLUKA and Measured dose 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Script to process the simulation output and create plots
%% Select Folder containing Fluka output

[out_files, OutfileDir] = uigetfile({'*.lis'}, 'Select the file containing the FLUKA dose values');


% %% Load Bowtie Spectrum
% [fileName, pathName] = uigetfile({'*.mat'}, 'Select Bowtie_Profile_full from -25cm to 25cm');
% load([pathName fileName]);
Tot_source_strength = 0;
%% Parse File to Get Dose and Error
fid = fopen([OutfileDir out_files], 'r+');
Dose = zeros(200,1);
Error = zeros(200,1);
i = 0;
error = 'F';
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end;
    p = regexp(tline,'\W+ [^\.] \s[-+]?[0-9]*\.[00.-9]+([eE][-+]?[0-9]+)?','match');
    if(~isempty(p))
    if(strcmp(error,'F'))
        i = i+1;
        Dose(i) = str2num(p{1});
        error = 'T';
    else
         Error(i) =str2num(p{1});
         error = 'F';
    end
    end
end
fclose(fid);
Dose = Dose(1:i);
Error = Error(1:i); 

%% Calculates Absolute Dose for the Scan
% Required parameters
% Conversion factor 1(Gev/g to cGy)
CF1 = 0.00000016021764*100;
%% Scan MA
mA = 300;

%% hack
%% Predicted Source strength at 160 mm with HEEL Effect Measured Using:
%% Old Film
%Tot_source_strength = 55542419359940.6; % Predicted Source strength at 160 mm
Tot_source_strength = inputdlg('Enter the photon source strength for this scan', 'Photon Strength', 1,{'55542419359940.6'});

%% Calculate Total Dose in CGy
AbsDose = Dose*Tot_source_strength*CF1;
Tot_dose = zeros(size(AbsDose));
Tot_error = Tot_dose;
Tot_dose = Tot_dose + AbsDose;   
Tot_error = Tot_error + (Error.*AbsDose/100).^2;

 
Tot_error = sqrt(Tot_error);

%% Save TotDose
save([OutfileDir '\TotDose.mat'],'Tot_dose','Tot_error');

%% Prepare Measurement Values
zax = csvread('Z-locations.csv');

% Load Measured Values from Mosfets
[fileName, pathName] = uigetfile({'*.csv'}, 'Select the file containing the measured dose values');
Meas_dose = csvread([pathName '\' fileName]); % centi-gy

%% Original Measurement Order
Mosfet_order = {'Lung-81',...
                'Lung-84',...
                'Lung-77',...
                'Lung-79',...
                'ST-85',...
                'Lung-68',...
                'Lung-72',...
                'Bone-63',...
                'Bone-65',...
                'Bone-76',...
                'ST-58',...
                'ST-59',...
                'ST-60',...
                'ST/Bone-51',...
                'ST-50',...
                'Bone-39',...
                'Bone-37',...
                'Bone-38',...
                'ST/Bone-44',...
                'Lung-48',...
                'BOne-30',...
                'Bone-33',...
                'ST-34',...
                'ST-35',...
                'Lung-28'};
               

Mosfet_order = Mosfet_order';
zax = num2cell(zax);
Meas_dose = num2cell(Meas_dose);
[table1_cell{1:length(zax),1}] = zax{:};
[table1_cell{1:length(Meas_dose),2}] = Meas_dose{:,1};
[table1_cell{1:length(Mosfet_order),3}] = Mosfet_order{:};
[table1_cell{1:length(Mosfet_order),4}] = Meas_dose{:,2}; % Standarad Deviation in measured dose
table1_cell = sortrows(table1_cell,[1]);
table1 = [cell2mat(table1_cell(:,1)),cell2mat(table1_cell(:,2)),cell2mat(table1_cell(:,4))];

%% Prepare Simulation values
zax = cell2mat(zax);
table2 = [zax,Tot_dose,Tot_error];
table2 = sortrows(table2,[1]);

%% Plot
figure;
errorbar(table1(:,2),table1(:,3),'o');
hold on;
errorbar(table2(:,2),table2(:,3),'*');

ax = gca;
ax.XTick = (1:length(table1_cell(:,3)));
ax.XTickLabel = (table1_cell(:,3));
ax.XTickLabelRotation = (45);
legend('Measurement','Simulation-cyl-tally','Simulation-xyz-tally');
ylabel('Dose in Centi Gray');
xlabel('Organ-hole locations');
title('Comparison of Measured Dose with FLUKA');
hold off;
screenSize=get(0,'Screensize');
screenSize(1) = screenSize(1) + round(screenSize(3)/2);
screenSize(2) = screenSize(2) + round(screenSize(4)/2);
screenSize(3) = round(screenSize(3)/4);
screenSize(4) = round(screenSize(4)/4);
set(gcf,'Position',screenSize);
saveas(gcf,[OutfileDir 'Dose_comparison.png']);