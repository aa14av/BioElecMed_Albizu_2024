% Plot Precision Dosing
%----------------------------------------
% Description:
% This function visualizes and analyzes AI-optimized non-invasive brain
% stimulation dosing for major depression.
%
% Input Arguments:
% - J_R: Response data matrix
% - J_NR: Non-response data matrix
% - J_P: Precision dosing data matrix
% - mask: Mask for removing non-brain regions
% - w: Weighting vector
% - dims: Dimensions of the data 
% - color: Color scheme for visualization
%
% Output:
% - stats: Contains statistical information about the dosing data.
%
% Usage:
% stats = plotGroupDosing(J_R, J_NR, J_P, umask, w, dims, color);
%
% Note:
% Ensure that the input data matrices (J_R, J_NR, J_P) have the same dimensions.
%
%----------------------------------------
% Created By: Alejandro Albizu
% Center for Cognitive Aging and Memory
% University of Florida
% Creation Date: 8/8/2023
%----------------------------------------
% Last Updated: 8/14/2023 by AA
function stats = plotGroupDosing(J_R,J_NR,J_P,mask,w,dims,color)
    Nvox = prod(dims); % Number of Voxels
    nd = size(J_R,2)/Nvox; % # Dimensions
    title_font = 14;
    sub_font = 12;
    
    % Concat Data
    J_raw = [J_R;J_NR;J_P];
    J_raw(:,~mask) = NaN;

    % PCA
    J_R(isnan(J_R)) = 0; % Remove NaN for PCAcolor(:,:,2) = [0 .447 .741]; % Blue
    J_NR(isnan(J_NR)) = 0; % Remove NaN for PCA
    J_P(isnan(J_P)) = 0; % Remove NaN for PCA
    [coeff,score,~,~,expl,MU] = pca(J_R(:,mask));
    J_all = [score;
        (J_NR(:,mask)-MU)*coeff;
        (J_P(:,mask)-MU)*coeff];
    J_R(J_R == 0) = NaN; % Remove Missing
    J_NR(J_NR == 0) = NaN; % Remove Missing 
    J_P(J_P == 0) = NaN; % Remove Missing

    cidx = [zeros(size(J_R,1),1);
        ones(size(J_NR,1),1);
        ones(size(J_P,1),1)+1];

    J_mag = nan(size(J_raw,1),Nvox);
    for s = 1:size(J_raw,1)
        J_mag(s,:) = sqrt(sum(reshape(J_raw(s,:),[Nvox nd]).^2,2,'omitnan'));
    end; J_mag(J_mag == 0) = NaN;
    J_z = mean(sqrt(((J_raw(:,w~=0)-mean(J_R(:,w~=0),'omitnan')).*w(w~=0)').^2),2,'omitnan');
    
    dose_change = reshape(J_z(cidx~=0),[size(J_NR,1) 2]);

    % Create Figure
    f1 = figure('units','normalized','position',[0 0 1 1]); 
    cm = redbluecmap;

    % Clustering
    clab = [repelem({'Responder Doses'},size(J_R,1),1);
        repelem({'Non-Responder Doses'},size(J_NR,1),1);
        repelem({'Optimized Doses'},size(J_P,1),1)];
    s2=subplot(3,3,3); s2pos = s2.Position; 
    gs1 = scatterhist(J_all(:,1),J_all(:,2),'Group',clab,...
        'kernel','on','Location','Southwest','Direction','out','Color', ...
        [color(:,:,1);color(:,:,2);color(:,:,3)],'parent',...
        f1,'LineStyle','-','LineWidth',2,'legend','off'); 
    alpha(gs1(1),0); hold on;
    u = uipanel(f1,'title','Whole Brain Dose Clustering',...
        'Position',[s2pos(1:2)-0.065 s2pos(3:4)+0.065], ...
        'bordertype','none','BackgroundColor',[1 1 1]); 
    set(gs1,'Parent',u); gax = get(gs1(1),'Children');
    for i = 1:length(unique(clab))
        gax(i).MarkerFaceColor = 'none';  
        gax(i).MarkerEdgeColor = 'none'; 
    end
    
    GMM = fitgmdist(J_all(cidx==0,1:2),2,...
        'CovarianceType','diagonal','SharedCovariance',true);
    gmPDF = @(x,y) arrayfun(@(x0,y0) pdf(GMM,[x0 y0]),x,y); 
    fcontour(gmPDF,[gs1(1).XLim gs1(1).YLim]); hold on;
    gs2 = scatter(J_all(cidx==0,1),...
        J_all(cidx==0,2),100,repmat(color(:,:,1),size(J_R,1),1),...
        'filled','MarkerEdgeColor','k'); alpha(gs2,0.7);
    gs3 = scatter(J_all(cidx==1,1),...
        J_all(cidx==1,2),100,repmat(color(:,:,2),size(J_NR,1),1),...
        'filled','MarkerEdgeColor','k'); alpha(gs3,0.7);
    gs4 = scatter(J_all(cidx==2,1),...
        J_all(cidx==2,2),100,repmat(color(:,:,3),size(J_P,1),1),...
        'filled','MarkerEdgeColor','k'); alpha(gs4,0.7);
    xlabel(gs1(1),['PC1(',num2str(expl(1),'%.02f'),'%)'],'fontname','arial',...
        'fontsize',sub_font,'fontweight','bold');
    ylabel(gs1(1),['PC2(',num2str(expl(2),'%.02f'),'%)'],'fontname','arial',...
        'fontsize',sub_font,'fontweight','bold');
    legend([gs2 gs3 gs4],...
        {'Responder Doses','Non-Responder Doses','Optimized Doses'},...
        'Location','Southwest')

    % Bar Plot
    subplot(3,3,[1 2 4 5],'Parent',f1); 
    for d = 1:2
        b2 = bar(d,mean(dose_change(:,d)),'barwidth',0.4,...
            'FaceColor','none','LineWidth',3,...
            'FaceAlpha',0,'EdgeAlpha',0.6); 
        hold on; b2.EdgeColor = color(:,:,d+1);
    end; hold on;

    % Plot Histograms
    dp1 = distributionPlot(dose_change(:,1),'distwidth',0.2,...
        'histOpt',0,'globalNorm',2,'color', ...
        color(:,:,2),'showMM',0,'histOri','left',...
        'xValues',0.5); alpha(dp1{3},0.4)
    dp2 = distributionPlot(dose_change(:,2),'distwidth',0.2,...
        'histOpt',0,'globalNorm',2,'color', ...
        color(:,:,3),'showMM',0,'histOri','right',...
        'xValues',2.5); alpha(dp2{3},0.4)

    % Plot Beeswarm
    ps = plotSpread(dose_change, ...
        'distributionColors',{color(:,:,2),color(:,:,3)},...
        'distributionMarkers',{'o', 's'},'showMM',0, ...
        'xNames',{'Fixed Doses','Optimized Doses'},...
        'yLabel','Weighted Difference (Am^{-2})');
    ylim([min(dose_change(:)-std(dose_change(:))),...
        max(dose_change(:)+std(dose_change(:)))])
    hold on; set(gca,'FontSize',title_font,...
        'Fontname','arial','FontWeight','bold'); 
    title('Dosing Variability');

    % Plot Spaghetti Lines
    plot([ps{3}.Children(2).XData' ...
        ps{3}.Children(1).XData']',...
        dose_change','Color',...
        [0,0,0,0.4],'LineWidth',2);

    % Plot Beeswarm
    plotSpread(dose_change, ...
        'distributionColors',{color(:,:,2),color(:,:,3)},...
        'distributionMarkers',{'o', 's'},'showMM',0, ...
        'xNames',{'Fixed Doses','Optimized Doses'},...
        'yLabel','Weighted RMSE');

    % Plot Means
    scatter([0.6 2.4],[mean(dose_change(:,1)) ...
        mean(dose_change(:,2))],100,'k','filled') % mean
    
    % 95%CI Lines
    plot([0.6 0.6],[mean(dose_change(:,1))-std(dose_change(:,1)) ...
        mean(dose_change(:,1))+std(dose_change(:,1))],'-k','LineWidth',2) 
    plot([2.4 2.4],[mean(dose_change(:,2))-std(dose_change(:,2)) ...
        mean(dose_change(:,2))+std(dose_change(:,2))],'-k','LineWidth',2) 
    
    % Add Hedges G
    stats = mes(dose_change(:,2),dose_change(:,1),...
        'hedgesg','isDep',1,'nBoot',1000);
    annotation('textbox',[.31 .8 .1 .1],...
        'String',sprintf('Hedges'' g = %.02f',...
        round(stats.hedgesg,2)),'FaceAlpha',0,...
        'LineStyle','none','FontWeight',...
        'bold','FontSize',title_font)
    
    [~,anv_tab] = anova1(dose_change,[],'off');
    stats.anova = cell2table(anv_tab);
    fprintf(['Pre vs Post Optimization Weighted RMSE: ' ...
        'F[%d,%d] = %.2f, p = %.5f, g = %.2f\n'], anv_tab{2,3}, ...
        anv_tab{4,3}, anv_tab{2,5}, anv_tab{2,6}, ...
        stats.hedgesg)

    % Optimized Dose
    diff1 = dot(reshape(mean(J_raw(cidx==0,:),'omitnan'),[Nvox 3]), ...
        reshape(mean(J_raw(cidx==2,:),'omitnan'),[Nvox nd]),2)./mean(J_mag(cidx==0,:),'omitnan')';
    diff1 = (diff1-min(diff1))+0.001; 
    rsp = reshape(diff1,dims);  clear tmp;
    s1=subplot(3,3,8); imagesc(rsp(:,:,round(dims(3)/1.6)),[0 0.105]); 
    axis off; axis tight; 
    title(sprintf('Optimized Responder Similary\n(Average = %s)', ...
        num2str(mean(diff1(:),'omitnan'),'%.04f')),'fontname','arial', ...
        'fontsize',title_font,'fontweight','bold');
    colormap(s1,cm); alpha(s1,0.5); cb1 = colorbar;
    ylabel(cb1,'Dot Product','fontname','arial','fontsize',...
        sub_font,'fontweight','bold');

    % Fixed Dose
    diff2 = dot(reshape(mean(J_raw(cidx==0,:),'omitnan'),[Nvox 3]), ...
        reshape(mean(J_raw(cidx==1,:),'omitnan'),[Nvox nd]),2)./mean(J_mag(cidx==0,:),'omitnan')';
    diff2=(diff2-min(diff2))+0.001; 
    rsn = reshape(diff2,dims); clear tmp;
    s3=subplot(3,3,7); imagesc(rsn(:,:,round(dims(3)/1.6)),[0 0.105]); 
    axis off; axis tight; 
    title(sprintf('Fixed Responder Similary\n(Average = %s)', ...
        num2str(mean(diff2(:),'omitnan'),'%.04f')),'fontname','arial', ...
        'fontsize',title_font,'fontweight','bold');
    colormap(s3,cm); alpha(s3,0.5); cb2 = colorbar; 
    ylabel(cb2,'Dot Product','fontname','arial',...
        'fontsize',sub_font,'fontweight','bold');

    % Scatter
    s9=subplot(3,3,9); 
    scolor = sqrt(sum(reshape(w',[Nvox nd])'.^2,'omitnan'));
    rmu = median(J_mag(cidx==0,scolor~=0),'omitnan'); rmu(rmu==0) = NaN;
    nmu = median(J_mag(cidx==1,scolor~=0),'omitnan'); nmu(nmu==0) = NaN;
    pmu = median(J_mag(cidx==2,scolor~=0),'omitnan'); pmu(pmu==0) = NaN;
    scatter(rmu,pmu,10,scolor(scolor~=0),'filled');
    colormap(s9,'turbo'); alpha(s9,0.4);
    xlim([0 0.1]); ylim([0 0.1]); 
    ls1 = lsline; ls1.LineWidth = 2;
    xlabel('Responder Mean','fontname','arial',...
        'fontsize',sub_font,'fontweight','bold');
    ylabel('Optimized Mean','fontname','arial',...
        'fontsize',sub_font,'fontweight','bold');
    par = mean(corr(rmu',pmu','rows','complete'));
    annotation('textbox',[.7 .22 .1 .1],'String',...
        sprintf('R^2 = %.3f',par^2),'FaceAlpha',0,'LineStyle',...
        'none','FontWeight','bold','FontSize',sub_font)
    title('Optimized vs Responder Mean','fontname','arial',...
        'fontsize',title_font,'fontweight','bold');
    colormap(s9,'turbo'); cb3 = colorbar;
    ylabel(cb3,'Weight (%)','fontname','arial','fontsize',...
        sub_font,'fontweight','bold');

    % Histogram
    s4=subplot(3,3,6);

    d1 = rmu; d1d = median(d1,'omitnan'); 
    h1 = histfit(d1,400,'kernel'); alpha(h1,0.01); hold(s4,'on');
    d2 = nmu; d2d = median(d2,'omitnan'); 
    h2 = histfit(d2,400,'kernel'); alpha(h2,0.01);
    d3 = pmu; d3d = median(d3,'omitnan'); 
    h3 = histfit(d3,400,'kernel'); alpha(h3,0.01);

    h1(1).FaceColor = color(:,:,1); h1(2).Color = h1(1).FaceColor;
    [~,lid1] = min(pdist2(h1(2).XData',d1d));
    scatter(d1d,h1(2).YData(lid1),100,...
        'MarkerFaceColor',color(:,:,1),'MarkerEdgeColor','k');

    h2(1).FaceColor = color(:,:,2); h2(2).Color = h2(1).FaceColor;
    [~,lid2] = min(pdist2(h2(2).XData',d2d));
    scatter(d2d,h2(2).YData(lid2),100,...
        'MarkerFaceColor',color(:,:,2),'MarkerEdgeColor','k');

    h3(1).FaceColor = color(:,:,3); h3(2).Color = h3(1).FaceColor;
    [~,lid3] = min(pdist2(h3(2).XData',d3d));
    scatter(d3d,h3(2).YData(lid3),100,...
        'MarkerFaceColor',color(:,:,3),'MarkerEdgeColor','k');

    yt = get(s4,'YTick'); ylim(s4,[0 max(yt)]); 
    set(s4,'YTick',yt,'YTickLabels',round(yt/numel(rmu),4)*100);
    xlim([0 0.1]); xlabel('Current Density (Am^{-2})',...
        'fontname','arial','fontsize',sub_font,'fontweight','bold'); 
    ylabel('Percent of Voxels','fontname','arial',...
        'fontsize',sub_font,'fontweight','bold')
    title(s4,'Electric Field Distribution','fontname',...
        'arial','fontsize',title_font,'fontweight','bold');
    legend([h1(2),h2(2),h3(2)],{'Responder Mean',...
        'Non-Responder Mean','Optimized Mean'},'fontname',...
        'arial','fontsize',12,'fontweight','bold')
    [MI,NMI]=mi(d1,d3,10000);
    annotation('textbox',[.7 .37 .1 .1],'String',...
        sprintf(['Average Normalized Mutual\n', ...
        'Information = %s%% (%s bits)'],...
        num2str(round(mean(NMI),3)*100),num2str(round(mean(MI),1))),...
        'FaceAlpha',0,'LineStyle','none',...
        'FontWeight','bold','FontSize',title_font)