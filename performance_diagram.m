clear;
clc;
% close all;
%% test cal_score()
happy1 = [1,2;3,4];
happy2 = [2,3;4,1];
[a,b] = cal_score(happy1,happy2,2.5)

%% test draw_PD()
figure(1)
draw_PD()
scatter(a,b)

%% draw basic element for performance diagram
function draw_PD()
    hold on;
    % initialize grid point
    [XX, YY] = meshgrid(linspace(0.01,1,1000), linspace(0.01,1,1000));
    
    %===== Dash line: bias =====%
    contour_bias = YY ./ XX;
    lavels_bias = [0.3, 0.5, 0.8, 1.0, 1.3, 1.5, 2.0, 3.0, 5.0, 10.0];
    contour(XX, YY, contour_bias, lavels_bias,'--','EdgeColor',[0.4,0.4,0.4]);
    
    % draw dash line label
    p_biasy_fn = @(x, c) x .* c;
    p_biasx_fn = @(y, c) y ./ c;
    manual_location = [ ...
        1.03, p_biasy_fn(1, 0.3); ...
        1.03, p_biasy_fn(1, 0.5); ...
        1.03, p_biasy_fn(1, 0.8); ...
        1.03, 1.03; ...
        p_biasx_fn(1, 1.3), 1.03; ...
        p_biasx_fn(1, 1.5), 1.03; ...
        p_biasx_fn(1, 2.0), 1.03; ...
        p_biasx_fn(1, 3.0), 1.03; ...
        p_biasx_fn(1, 5.0), 1.03; ...
        p_biasx_fn(1, 10.0), 1.03 ...
    ];
    for i = 1:length(lavels_bias)
        text(manual_location(i, 1), manual_location(i, 2), num2str(lavels_bias(i)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', [0.5, 0.5, 0.5]);
    end
    hold on;

    %===== Solid line: CSI =====%
    contour_CSI = 1 ./ (1./XX + 1./YY - 1);
    contour(XX, YY, contour_CSI, 0.1:0.1:0.9,'EdgeColor',[0.7,0.7,0.7]);
    
    % draw solid line label
    p_CSI_fn = @(x, c) 1 ./ (1./c - 1./x + 1);
    manual_location = [ ...
        0.95, p_CSI_fn(0.95, 0.1); ...
        0.95, p_CSI_fn(0.95, 0.2); ...
        0.95, p_CSI_fn(0.95, 0.3); ...
        0.95, p_CSI_fn(0.95, 0.4); ...
        0.95, p_CSI_fn(0.95, 0.5); ...
        0.95, p_CSI_fn(0.95, 0.6); ...
        0.95, p_CSI_fn(0.95, 0.7); ...
        0.95, p_CSI_fn(0.95, 0.8); ...
        0.95, p_CSI_fn(0.95, 0.9); ...
    ];
    for i = 1:9
        text(manual_location(i, 1), manual_location(i, 2), num2str(0.1*i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', [0.8, 0.8, 0.8]);
    end
%     clabel(C,h,'LabelSpacing',500,'color',[0.5,0.5,0.5]);
    
    xlabel('Success Ratio (1-FAR)');
    ylabel('Probability of Detection (POD)');
    xlim([0, 1]);
    ylim([0, 1]);
    box on;
end

%% calculate [(1-FAR), POD] for performance diagram
function [FAR_,POD] = cal_score(arr_pred, arr_true, threshold)
    
    H = sum(sum(arr_pred >= threshold & arr_true >= threshold));
    M = sum(sum(arr_pred < threshold & arr_true >= threshold));
    F = sum(sum(arr_pred >= threshold & arr_true < threshold));
    cn = sum(sum(arr_pred < threshold & arr_true < threshold));
    
    % if (H+M+F+cn==0), return 0
    % C=(H+M)*(H+F)/(H+M+F+cn)
    % if (H+M+F-C==0), return 0
    % ETS=(H-C)/(H+M+F-C)
    % if (H+M==0), return 0
    POD = H / (H + M);
    FAR = F / (H + F);
    FAR_ = 1-FAR;
    % CSI = H / (H + M + F);
end
