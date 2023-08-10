% Interpret SVM Weights
% Artificial Intelligence-Optimized Non-Invasive Brain Stimulation 
% and Treatment Response Prediction for Major Depression
%----------------------------------------
% Created By Alejandro Albizu
% Center for Cognitive Aging and Memory
% University of Florida
% 8/8/2023
%----------------------------------------
% Last Updated: 8/8/2023 by AA
function [stats, roiRank] = interpretWeights(data,label,weights,atlas,lut,rk)
    N = size(data,1);

    % Compute Responder v Nonresponder
    respJ = data(label == 1,:); % Responders
    nonrJ = data(label == -1,:); % Non-Responders
    rmed = median(respJ,1,'omitnan'); nmed = median(nonrJ,1,'omitnan'); 
        
    % Median Current
    med_data = zeros(N,1);
    for s = 1:N; med_data(s) = median(data(s,data(s,:)~=0),'omitnan'); end
    x = med_data;
    y = label==1;
    
    %--------------------------------------------
    % Scatter Intensity + Spread vs PctChange
    %--------------------------------------------
    figure;
    sp1=subplot(2,2,1);
    histogram(nmed(nmed ~= 0),100,'Normalization','probability','FaceColor',[0.6350 0.0780 0.1840],'EdgeColor','k')
    hold on
    histogram(rmed(rmed ~= 0),100,'Normalization','probability','FaceColor',[0 0.4470 0.7410],'EdgeColor','k')
    xlabel('Current Intensity','FontSize',10)
    ylabel('Percent of Voxels','FontSize',10)
    legend({'Non-Responders','Responders'})
    xlim([0 .1])
    ylim([0 .14])
    title(sp1,'Current Intensity Histogram')
    subplot(2,2,2);
    histogram(nmed(nmed ~= 0),100,'Normalization','cdf','EdgeColor',[0.6350 0.0780 0.1840],'DisplayStyle','stairs')%,'probability')
    hold on
    histogram(rmed(rmed ~= 0),100,'Normalization','cdf','EdgeColor',[0 0.4470 0.7410],'DisplayStyle','stairs')%,'probability')
    xlabel('Current Intensity','FontSize',10)
    ylabel('Cum. % of Voxels','FontSize',10)
    legend({'Non-Responders','Responders'},'Location','Southeast')
    xlim([0 .1]); ylim([0 1])
    title('Cumulative Intensity Histogram')
    subplot(2,2,3);
    mdl = fitglm(x, y, "Distribution", "binomial");
    xnew = linspace(min(x(~y)),max(x(y)),1000)'; % test data
    ynew = predict(mdl, xnew);
    plot(xnew, ynew,'k','LineWidth',3); hold on;
    scatter(x(y==1), y(y==1), 50,'MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor','k'); hold on;
    scatter(x(y==0), y(y==0), 50,'MarkerFaceColor',[0.6350 0.0780 0.1840],'MarkerEdgeColor','k'); hold on;
    text(0.017,0.8,['R^2 = ' num2str(mdl.Rsquared.Ordinary,'%.3f') ', p < 0.001'])
    title 'Median Current Intensity'
    sp4 = subplot(2,2,4);
    gardnerAltmanPlot(x(y),x(~y),'Effect','cohen');
    title(sp4,'')
    xticklabels({['Responders (n=' num2str(sum(y)) ')'] ...
        ,['Non-Responders (n=' num2str(sum(~y)) ')'], 'Mean Difference'})
    %--------------------------------------------
    
    % Perform Statistics
    stats = mes(x(y),x(~y),'hedgesg','isDep',0,'nBoot',1000);
    [~,anv_tab] = anova1(x,y,'off');
    stats.anova = cell2table(anv_tab); stats.logistic = mdl;
    fprintf(['Responder v Non-Responder Median Current Density: ' ...
        'F[%d,%d] = %.2f, p = %.5f, g = %.2f\n'], anv_tab{2,3}, ...
        anv_tab{4,3}, anv_tab{2,5}, anv_tab{2,6}, ...
        stats.hedgesg)

    %--------------------------------------------
    % Rank Regions of Interest
    %--------------------------------------------
    rois = unique(atlas(atlas ~= 0));
    rrois = zeros(length(rois),1);
    for r = 1:length(rois)
        rrois(r) = mean(weights(atlas == rois(r)));
    end
    
    [sroi,rank] = sort(rrois,'descend');
    figure;
    for i = 1:length(sroi)
        b(i)=barh(i,sroi(i)); hold on;
        axis ij
        if ismember(i,rk)
            b(i).FaceColor = [1 0 0];
        else
            b(i).FaceColor = [0 0 1];
        end
    end
    xlim([0 max(sroi)])
    set(gca,'YTick',0:10:120)
    xlabel('Mean Contribution per Voxel (%)','FontWeight','Bold')
    ylabel('ROI Rank','FontWeight','Bold')
    
    roiRank = table(lut{rank,1}, sroi);