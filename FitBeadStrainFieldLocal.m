function [z_y, mean_y, std_y, sem_y] = FitBeadStrainFieldLocal( x_0, y_0, match_score, x_1, y_1, match_threshold, strain_threshold, subplotID)
    
for i = 1:length(x_0)
    if isnan(match_score(i)) || match_score(i) < match_threshold || isnan(x_0(i)) || isnan(y_0(i))
        x_0(i)= nan;
        y_0(i)= nan;
        x_1(i)= nan;
        y_1(i)= nan;
    end
end

%% Calculate distance among two bead in each image to determine the radius of the "local circle"
x = [];
y = [];
z_x = [];
z_y = [];
% mean_x = 0; std_y = 0;  sem_y = 0;
all_dist = NaN(length(x_0),1);
temp_dist = 0;
for i = 1:length(x_0)
    temp_dist = 10000000;
    for j = 1:length(x_0)
       if i ~= j
        dist = sqrt( (x_1(i)-x_1(j))*(x_1(i)-x_1(j)) + (y_1(i)-y_1(j))*(y_1(i)-y_1(j)) );
        if dist < temp_dist
            temp_dist = dist;
        end
       end
    end
    if temp_dist < 10000000
        all_dist(i) = temp_dist;
    end
end
max_dist = max(all_dist);
%% Strain mapping

for i = 1:length(x_0)
    for j = i+1:length(x_0)
        dist = sqrt( (x_1(i)-x_1(j))*(x_1(i)-x_1(j)) + (y_1(i)-y_1(j))*(y_1(i)-y_1(j)) );
        if dist <= max_dist*6
            x = [x; (x_1(i)+x_1(j))/2];
            y = [y; (y_1(i)+y_1(j))/2];
            temp_x = ((x_1(j)-x_1(i)) - (x_0(j)-x_0(i)))/(x_0(j)-x_0(i));
            temp_y = ((y_1(j)-y_1(i)) - (y_0(j)-y_0(i)))/(y_0(j)-y_0(i));
            
            if abs(temp_x)> strain_threshold
               temp_x = nan;
            end    
            if abs(temp_y)> strain_threshold
                temp_y = nan;
            end
            z_x = [z_x; temp_x];
            z_y = [z_y; temp_y];
        end
    end
end

%%
mean_x = mean(z_x, 'omitnan');
mean_y = mean(z_y, 'omitnan');
std_x = std(z_x, 'omitnan');
std_y = std(z_y, 'omitnan');
sem_x = std_x/sqrt(sum(~isnan(z_x))-1);
sem_y = std_y/sqrt(sum(~isnan(z_y))-1);

result_summarized = [mean_x, mean_y;
        std_x, std_y;
        sem_x, sem_y];
    
total_point_count = sum(~isnan(z_y))

if total_point_count <=2
    disp('Not enough data!');
    return
end

%% Draw Histogram
% if subplotID == 5 || subplotID == 6 || subplotID == 7 || subplotID == 8
%     h = histogram(100*z_y, 50);
%     h.Normalization = 'probability';
%     h.EdgeColor = 'none';
%     h.FaceAlpha = 0.5;
% %     title_enum = {'0V','1V','1.5V','2V','2.5V','3.5V','4V','5V','After load release'};
% %     title(title_enum(subplotID));
%     xlabel('Strain (%)');
%     ylabel('Frequency');
%     legend('1V', '2.5V', '4V', 'After load release', 'Location','northwest');
%     axis([-2 5 0 0.12]);
%     set(gca,'FontName', 'Arial', 'fontweight', 'bold', 'FontSize', 12, 'linewidth', 1.25);
%     hold on
% end
%% Plot all mapping in one plot

% x(isnan(z_y))=[];
% y(isnan(z_y))=[];
% z_y(isnan(z_y))=[];
% z_x(isnan(z_y))=[];
% title_enum = {'0V','1V','1.5V','2V','2.5V','3.5V','4V','5V','After load release'};
% 
% 
% [xi, yi] = meshgrid(1:1:1200, 1:1:1200);
% zxi = griddata(x,y,z_y, xi,yi, 'cubic');    %cubic, v4, nearest, natural
% subplot(3,3, subplotID)
% h=surf(xi,yi,zxi);
% alpha 0.7
% %     plot3(x, y, z_y, 'ro')
% hold on
% z_1 = 0.05*ones(length(x_1), 1);
% plot3(x_1, y_1, z_1, 'o','MarkerEdgeColor','none', 'MarkerFaceColor', 'black', 'MarkerSize', 4);
% xlabel('x (pixel)');%, 'FontName', 'Arial', 'fontweight', 'bold');
% ylabel('y (pixel)');%, 'FontName', 'Arial', 'fontweight', 'bold');
% set(gca,'FontName', 'Arial', 'fontweight', 'bold', 'linewidth', 1);
% title(title_enum(subplotID));
% set(h,'linestyle','none');
% grid off
% view( -0.4, 90.0 );
% pbaspect([1 1 1])
% axis([0 1200 0 1200 -0.05 0.05])
% xticks([0 300 600 900 1200])
% yticks([0 300 600 900 1200])
% colorbar;
% ccmap = [0,0,0.666666666666667;0,0,0.800000000000000;0,0,0.933333333333333;0,0,1;0,0.0666666666666667,1;0,0.133333333333333,1;0,0.200000000000000,1;0,0.266666666666667,1;0,0.333333333333333,1;0,0.400000000000000,1;0,0.466666666666667,1;0,0.533333333333333,1;0,0.600000000000000,1;0,0.666666666666667,1;0,0.733333333333333,1;0,0.800000000000000,1;0,0.866666666666667,1;0,0.933333333333333,1;0,1,1;0.0666666666666667,1,0.933333333333333;0.133333333333333,1,0.866666666666667;0.200000000000000,1,0.800000000000000;0.266666666666667,1,0.733333333333333;0.333333333333333,1,0.666666666666667;0.400000000000000,1,0.600000000000000;0.466666666666667,1,0.533333333333333;0.533333333333333,1,0.466666666666667;0.600000000000000,1,0.400000000000000;0.666666666666667,1,0.333333333333333;0.733333333333333,1,0.266666666666667;0.800000000000000,1,0.200000000000000;0.866666666666667,1,0.133333333333333;0.933333333333333,1,0.0666666666666667;1,1,0;1,0.933333333333333,0;1,0.866666666666667,0;1,0.800000000000000,0;1,0.733333333333333,0;1,0.666666666666667,0;1,0.600000000000000,0;1,0.533333333333333,0;1,0.466666666666667,0;1,0.400000000000000,0;1,0.333333333333333,0;1,0.266666666666667,0;1,0.200000000000000,0;1,0.133333333333333,0;1,0.0666666666666667,0;1,0,0;0.933333333333333,0,0;0.866666666666667,0,0;0.800000000000000,0,0;0.733333333333333,0,0;0.666666666666667,0,0;0.600000000000000,0,0;0.533333333333333,0,0];
% colormap(ccmap);
% caxis([0 0.05]);
% set(gca,'FontName', 'Arial', 'fontweight', 'bold', 'linewidth', 1.5);

%% Single plot
% 
% x(isnan(z_x))=[];
% y(isnan(z_x))=[];
% z_y(isnan(z_x))=[];
% z_x(isnan(z_x))=[];
% 
% % x(isnan(z_x))=[];
% % y(isnan(z_x))=[];
% % z_y(isnan(z_x))=[];
% % z_x(isnan(z_x))=[];
% 
% title_enum = {'0V','1V','1.5V','2V','2.5V','3.5V','4V','5V','After load release'};
% 
% [xi, yi] = meshgrid(0:1:1200, 0:1:1200);
% zxi = griddata(x,y,z_x, xi,yi, 'cubic');    %cubic, v4, nearest, natural
% ff =figure;
% h=surf(xi,yi,zxi);
% alpha 0.7
% hold on
% z_1 = 0.05*ones(length(x_1), 1);
% plot3(x_1, y_1, z_1, 'o','MarkerEdgeColor','none', 'MarkerFaceColor', 'black', 'MarkerSize', 5);
% xlabel('x (pixel)');
% ylabel('y (pixel)');
% set(gca,'FontName', 'Arial', 'fontweight', 'bold', 'FontSize', 16, 'linewidth', 1.5);
% title(title_enum(subplotID), 'FontSize', 18);
% set(h,'linestyle','none');
% grid off
% view( -0.4, 90.0 );
% pbaspect([1 1 1])
% axis([0 1200 0 1200 -0.05 0.05])
% xticks([0 300 600 900 1200])
% yticks([0 300 600 900 1200])
% box on
% ccmap = [0,0,0.666666666666667;0,0,0.800000000000000;0,0,0.933333333333333;0,0,1;0,0.0666666666666667,1;0,0.133333333333333,1;0,0.200000000000000,1;0,0.266666666666667,1;0,0.333333333333333,1;0,0.400000000000000,1;0,0.466666666666667,1;0,0.533333333333333,1;0,0.600000000000000,1;0,0.666666666666667,1;0,0.733333333333333,1;0,0.800000000000000,1;0,0.866666666666667,1;0,0.933333333333333,1;0,1,1;0.0666666666666667,1,0.933333333333333;0.133333333333333,1,0.866666666666667;0.200000000000000,1,0.800000000000000;0.266666666666667,1,0.733333333333333;0.333333333333333,1,0.666666666666667;0.400000000000000,1,0.600000000000000;0.466666666666667,1,0.533333333333333;0.533333333333333,1,0.466666666666667;0.600000000000000,1,0.400000000000000;0.666666666666667,1,0.333333333333333;0.733333333333333,1,0.266666666666667;0.800000000000000,1,0.200000000000000;0.866666666666667,1,0.133333333333333;0.933333333333333,1,0.0666666666666667;1,1,0;1,0.933333333333333,0;1,0.866666666666667,0;1,0.800000000000000,0;1,0.733333333333333,0;1,0.666666666666667,0;1,0.600000000000000,0;1,0.533333333333333,0;1,0.466666666666667,0;1,0.400000000000000,0;1,0.333333333333333,0;1,0.266666666666667,0;1,0.200000000000000,0;1,0.133333333333333,0;1,0.0666666666666667,0;1,0,0;0.933333333333333,0,0;0.866666666666667,0,0;0.800000000000000,0,0;0.733333333333333,0,0;0.666666666666667,0,0;0.600000000000000,0,0;0.533333333333333,0,0];
% colormap(ccmap);
% caxis([0 0.05]);
% cbr = colorbar;
% set(cbr, 'YTick', linspace(0, 0.05, 6));
% %print(ff,num2str(subplotID),'','-dsvg'); Save plot


end