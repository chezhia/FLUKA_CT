%%%%%%%%%%%%%%%%%%%%%%%%%
%% DESCRIPTION:
% This file will read the USRBIN file and saves the output Fluence/Dose and
% Error in a .mat file named after the current folder
% Cartesian XYZ Grids are assumed. Only one tally is allowed, but can have
% multiple bins [XYZ volume]
%% INPUT:
%   - .lis file containing multiple bins in a single tally
%% OUTPUT:
%  -  .mat file containing the dose,error and bin limits
%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
%% Read Text File Containing Fluence/Dose from FLUKA output
[fileName, pathName] = uigetfile({'*.lis'}, 'Select file containing the USRBIN Tally Results');
fid = fopen([pathName fileName], 'r+');

%% Define an arbitrary Vector of size 200
Fluence = zeros(1,200);
Error   = Fluence;
n = 0;
i = 0;
%% Loop to acquire values from one tally with multiple bins
while n < 1
%% Get the bin sizes
while(i < 3)
tline = fgetl(fid);
b = regexp(tline,'bins');
if(b > 0)
  i = i+1;
  binsize(i) = str2num(tline(b-7:b-1));
  binlimits(i,1) = str2num(tline(b-37:b-27));
  binlimits(i,2) = str2num(tline(b-22:b-12));
end
end

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
Fluence = reshape(Fluence,binsize(1),binsize(2),binsize(3));
Error = reshape(Error,binsize(1),binsize(2),binsize(3));

% Read folder name
currentDirectory = pwd
[upperPath, deepestFolder, ~] = fileparts(currentDirectory)
save([pathName deepestFolder  '-Usrbin-plot.mat'],'Fluence','Error','binsize','binlimits');