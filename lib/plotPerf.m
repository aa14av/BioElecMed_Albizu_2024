% Plot SVM Performance
%----------------------------------------
% Description:
% This function visualizes the SVM performance for AI-optimized non-invasive 
% brain stimulation dosing and treatment response prediction for major depression.
% It provides plots for ROC curves, AUC comparisons, and confusion matrices.
%
% Input Arguments:
% - perf: Struct containing performance metrics for each data type, 
%         including FPR, TPR, AUC, scores, and target labels.
% - dtypes: Cell array containing the names of the data types to be processed and plotted.
% - color: 3D matrix specifying color mapping for different data types.
%
% Output:
% - stats: Statistical information on the AUC differences across data types.
% - fl: Handles to the ROC curve plots.
% - c: Handle to the diagonal reference line in the ROC plot.
%
% Usage:
% [stats,fl,c] = plotPerf(perf, dtypes, color);
%
% Note:
% Ensure that all input structures, cell arrays, and matrices are correctly aligned.
%
%----------------------------------------
% Created By: Alejandro Albizu
% Center for Cognitive Aging and Memory
% University of Florida
% Creation Date: 8/8/2023
%----------------------------------------
% Last Updated: 8/14/2023 by AA
function [stats,fl,c] = plotPerf(perf,dtypes,color)
    N = 10; 
    int = 100; % # of interpolation steps
    intervals = linspace(0,1,int); % Plot Interval
    sc = [1 3 2];

    % Plot Data Type ROC Curve Comparison
    figure;        
    for d = 1:length(dtypes)
        FPR = perf.(dtypes{d}).FPR;
        TPR = perf.(dtypes{d}).TPR;
        for n = 1:N
            
            % Perturb data
            xadj = zeros(1,length(FPR(:,n)));
            aux = 0.0001;
            for i = 1:length(FPR(:,n))
                if i ~= 1
                    xadj(i) = FPR(i,n)+aux; 
                    aux=aux+0.0001;
                end
            end
            
            % Interpolate and Average across iterations
            if n == 1
                mean_curve = interp1(xadj,TPR(:,n)',intervals);
            else
                mean_curve = mean_curve + interp1(xadj,TPR(:,n),intervals);
            end
        end
        mean_curve = mean_curve./N;
        fl(d) = plot(intervals',mean_curve');
        fl(d).Color = color(:,:,sc(d));
        fl(d).LineWidth = 3;
        hold on
    end
    c=line([0 1],[0 1],'Color','k','LineStyle','--','LineWidth',1);
    xlabel('False positives','FontWeight','bold')
    ylabel('True positives','FontWeight','bold')
    xlim([0 1])
    ylim([0 1])
    set(gcf,'Color',[1,1,1])
    xlabel('1 - Specificity')
    ylabel('Sensitivity')
    title('Receiver Operator Curves');


    % Plot Data Type Bar Plot Comparison
    figure; data = zeros(N,length(dtypes));
    for d = 1:length(dtypes)
        data(:,d) = perf.(dtypes{d}).AUC;
        b2 = bar(d,mean(data(:,d)),'FaceColor','none','LineWidth',3,'FaceAlpha',0,'EdgeAlpha',.6);
        hold on;
        b2.EdgeColor = color(:,:,sc(d));

    end
    hold on
    ylim([.5 1])
    plotSpread(data, ...
        'distributionColors','k','distributionMarkers',{'o', 's', '^'},'showMM',0, ...
        'xNames',{'Combined','Direction','Intensity'},'yLabel','AUC')
    set(gca,'FontSize',12)
    title('Area Under the ROC Curve');
    [~,stats] = anova1(data,[],'off');
    fprintf(['Data Type AUC Difference: ' ...
        'F[%d,%d] = %.2f, p = %.5f\n'], stats{2,3}, ...
        stats{4,3}, stats{2,5}, stats{2,6})
    
    % Plot Confusion Matrix
    hold off; figure;
    for d = 1:length(dtypes)
        confusionchart(sign(perf.(dtypes{d}).allscores), ...
            perf.(dtypes{d}).alltargs,'Title',dtypes{d},'RowSummary', ...
            'row-normalized','ColumnSummary','column-normalized')
    end