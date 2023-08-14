%% Code Availability for Nature Communications
% Artificial Intelligence-Optimized Non-Invasive Brain Stimulation 
% and Treatment Response Prediction for Major Depression
%----------------------------------------
% Created By Alejandro Albizu
% Center for Cognitive Aging and Memory
% University of Florida
% 8/8/2023
%----------------------------------------
% Last Updated: 8/14/2023 by AA
clear; clc; restoredefaultpath; 
rootDir = setup; addpath(genpath(rootDir));

% Settings
%----------------------------------------
color(:,:,1) = [.133 .545 .133]; % Green
color(:,:,2) = [.635 .078 .184]; % Red
color(:,:,3) = [0 .447 .741]; % Blue
dims = [182 218 182]; % Normalized Image Dimensions
dtypes = {'DI','D','I'}; % Three Data Types
local_filename = fullfile(rootDir,'SourceData_Large.mat'); % Local filename to save the downloaded data
%----------------------------------------

% Figshare File URL
url = 'https://figshare.com/ndownloader/files/41997918';

% Download the file (this will take a few minutes)
if ~exist(local_filename,'file'); websave(local_filename, url); end

% Load Source Data
load(fullfile(rootDir,'SourceData.mat'));
load(local_filename);

% Plot Model Performance
[perfstats,fl,c] = plotPerf(perf,dtypes,color);
legend([fl c],{['mean DI (AUC:' num2str(round(perf.DI.aAUC,3)) ')'],...
        ['mean D (AUC:' num2str(round(perf.D.aAUC,3)) ')'],...
        ['mean I (AUC:' num2str(round(perf.I.aAUC,3)) ')'],...
        'Chance'},'Location','Southeast'); clear fl c;

% Plot Weight Interpretation 
atlas = niftiread(fullfile(rootDir,'lib','atlas.nii')); % Harvard-Oxford
lut = readtable(fullfile(rootDir,'lib','atlas.txt'),'ReadVariableNames',false);
[weightstats, roiRank] = interpretWeights(data,label,weights,atlas,lut,1:10);

% Plot Precision Dose Results
precisionstats = plotGroupDosing(doses(find(label==1)+6,:), ...
    doses(find(label==-1)+6,:),doses(1:6,:),doses(end-1,:)==1,doses(end,:)',dims,color);
disp 'All Done !'