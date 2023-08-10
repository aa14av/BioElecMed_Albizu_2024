function [stats,fl,c] = plotPerf(perf,dtypes,color)
    N = 10; 
    int = 100; % # of interpolation steps
    intervals = linspace(0,1,int); % Plot Interval


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
        fl(d).Color = color(:,:,d);
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
        b2.EdgeColor = color(:,:,d);

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