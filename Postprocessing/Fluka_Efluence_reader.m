%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Created by Elan Somasundaram 08/23/2017
%% Description: 
% This file will read the Cumulative Energy Fluence Values from FLUKA's USRTRACK
% output, calculates the actual fluence in each bin and saves in user
% defined .mat file
%% INPUT: 
%       -  Select the ".sum.lis" file containing the cumulative fluence
%          values for each energy bin
%% OUTPUT:
%       - .mat file containing the Fluence and Simulation Error.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
%% Read Text File Containing Cumulative Fluence from FLUKA output
[fileName, pathName] = uigetfile({'*.lis'}, 'Select text file containing the Cumulative Values from FLUKA');
fid = fopen([pathName fileName], 'r+');

%% Define an arbitrary Vector of size 200
Fluence = zeros(200,1);
  Error = zeros(200,1);
i = 0;

% Look for the start of the cumulative Flux values
start = 0;
while (start == 0)
tline = fgetl(fid);
p = regexp(tline,'Cumul.');
if p > 0
    start = 1;
end
end

% get the blank line after Cumul. 
fgetl(fid);

% Parse the Fluence values =
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end;
    p = regexp(tline,'+/-'); 
    q = regexp(tline,'%'); 
    for j = 1:length(p)    
    i = i+1;
    if j==1
    Fluence(i) = str2num(tline(1:p(j)-1));
    Error(i) = str2num(tline(p(j)+3:q(j)-1));
    else
    Fluence(i) = str2num(tline(q(j-1)+1:p(j)-1));
       Error(i) = str2num(tline(p(j)+3:q(j)-1));
    end
    end
end
fclose(fid);
Fluence = Fluence(1:i);
  Error = Error(1:i);

%% Find the Actual fluence from CDF
Cum_Fluence = Fluence;
for i = 2:length(Fluence)
   Fluence(i) = Cum_Fluence(i) - Cum_Fluence(i-1);   
end

%% Reverse the Spectrum to ascending (1 to 150 KeV)
% j = length(Fluence);
% Fluence_temp = Fluence;
% Cum_Fluence_temp = Cum_Fluence;
% for i = 1:length(Fluence)
%    Fluence(j) = Fluence_temp(i);   
%    Cum_Fluence(j) = Cum_Fluence_temp(i);   
%    j = j - 1;
% end
% clear Cum_Fluence_temp Fluence_temp p q fid;

%% Enter Filename to save the fluence
prompt = {'Enter the filename to save the fluence values:'};
dlg_title = 'Filename';
num_lines = 1;
defaultans = {'_Fluence.mat'};
filename = inputdlg(prompt,dlg_title,num_lines,defaultans);
save([pathName '\' filename{1}],'Fluence','Error');