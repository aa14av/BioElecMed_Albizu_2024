%% Code Availability for Nature Communications
% Artificial Intelligence-Optimized Non-Invasive Brain Stimulation 
% and Treatment Response Prediction for Major Depression
%----------------------------------------
% Created By Alejandro Albizu
% Center for Cognitive Aging and Memory
% University of Florida
% 8/8/2023
%
% ©Copyright 2023 University of Florida Research Foundation, Inc. 
% All Rights Reserved.
%----------------------------------------
% Last Updated: 8/8/2023 by AA
clear; clc; restoredefaultpath; 
rootDir = setup; addpath(genpath(rootDir));

% Settings
%----------------------------------------
color(:,:,1) = [.133 .545 .133]; % Green
color(:,:,2) = [0 .447 .741]; % Blue
color(:,:,3) = [.635 .078 .184]; % Red
%----------------------------------------

dtypes = {'DI','D','I'};
load(fullfile(rootDir,'SourceData.mat'));

% Plot Model Performance
[perfstats,fl,c] = plotPerf(perf,dtypes,color);
legend([fl c],{['mean DI (AUC:' num2str(round(perf.DI.aAUC,3)) ')'],...
        ['mean D (AUC:' num2str(round(perf.D.aAUC,3)) ')'],...
        ['mean I (AUC:' num2str(round(perf.I.aAUC,3)) ')'],...
        'Chance'},'Location','Southeast'); clear fl c;

% Plot Weight Interpretation 
atlas = niftiread(fullfile(rootDir,'lib','atlas.nii')); % Harvard-Oxford
lut = readtable(fullfile(rootDir,'lib','atlas.txt'),'ReadVariableNames',false);
[stats, roiRank] = interpretWeights(data,label,weights,atlas,lut,1:10);