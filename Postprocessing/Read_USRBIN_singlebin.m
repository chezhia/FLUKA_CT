%%%%%%%%%%%%%%%%%%%%%%%%%
%% DESCRIPTION:
% This file will read the USRBIN file and saves the output Fluence/Dose and
% Error in a .mat file named after the current folder
% The output file can contain multiple tallies, but each tally should have
% only one bin or one value.
%% INPUT:
% - .lis file with one bin, but one or more tallies - for MOSFET detectors
%% OUTPUT:
%  - .mat file containing the fluence/dose and its error
%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
%% Read Text File Containing Cumulative Fluence from FLUKA output
[fileName, pathName] =uigetfile({'*.lis'}, 'Select file containing the USRBIN Tally Results');
fid = fopen([pathName fileName], 'r+');
%% Get the number of tallies in the file
n_tallies = inputdlg('Enter the number of tallies in the file', '# of Tallies', 1,{'5'}); %ppi
n_tallies = str2num(n_tallies{1});

%% Define an arbitrary Vector of size 200
Fluence = zeros(n_tallies,200);
Error   = Fluence;
n = 0;

%% Loop to acquire values from all the n_tallies 
while n < n_tallies

% Find the line before start of Fluence data
tline = fgetl(fid);
p = regexp(tline,'this');
if (p > 0)
n = n+1;i = 0;j = 0;
tline = fgetl(fid);

% Loop to get all fluence values for tally n
while(length(tline) > 0) % Stop when line read is blank!
      q = regexp(tline,'\W+ [^\.] \s[-+]?[0-9]*\.[0-9]+([eE][-+]?[0-9]+)?','match');
      i = i+1;
      Fluence(n,i) = str2num(q{1});
      if(length(q{1}) ~= length(tline))
      tline = tline(length(q{1})+1:length(tline));
      tline = ['   ' tline];
      else 
       tline = fgetl(fid);
      end
end

% Loop till the line containing error values for tally n
tline = fgetl(fid); % Remove 'The Percentage errors...' line
tline = fgetl(fid); % Remove  blank line

% Loop to get the error values for tally n
tline = fgetl(fid);  % Start reading error values
j = 0;
while(j < i)
      q = regexp(tline,'\W+ [^\.] \s[-+]?[0-9]*\.[0-9]+([eE][-+]?[0-9]+)?','match');
      j = j+1;
      Error(n,j) = str2num(q{1});
      if(length(q{1}) ~= length(tline))
      tline = tline(length(q{1})+1:length(tline));
      tline = ['   ' tline];
      else 
       tline = fgetl(fid);
      end
end 
end
end
fclose(fid);
Fluence = Fluence(1:n,1:i);
Error  =  Error(1:n,1:j);

% Read folder name
currentDirectory = pwd
[upperPath, deepestFolder, ~] = fileparts(currentDirectory)
save([deepestFolder '.mat'],'Fluence','Error');