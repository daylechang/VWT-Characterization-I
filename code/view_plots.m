clc; clear all;

data_file = fullfile('post_fixed','LS-RT_Reduced Average.txt');

% these are the fields to read into matlab, prevents irrelevant data from
% being read
col_file = 'columns.txt';
tag_file = 'tags.txt';
offset_file = 'zero_offset.txt';
point_file = 'points.txt';

% initialize
obj = VWT_Rake_Data(data_file, col_file, tag_file, offset_file, point_file);

% read in files
obj = obj.read_cols();
obj = obj.read_data();
obj = obj.read_windoff();
obj = obj.read_tags();

ind.day = 1;
ind.tpn = 2;
ind.station = 3;
ind.orient = 4;
ind.vel = 5;

run_matrix

%tag = 'total';
fold_name = 'reruns';

tags = {'static', 'total'};

%for i = 2:length(run)

%points = strsplit(run{i,ind.tpn},'-');
%points = [str2double(points{1}):str2double(points{2})];

% points = [242:246, 262:267, 280:285, 298:301];
% points = [262:267, 280:285, 298:301];
% points = [280:285, 298:301];
% %fig_title = 'Day 4 & 5 Comparison, 95 fps, Station 0, Orientation 0 deg';
% %fig_title = 'Day 5 Comparison, 95 fps, Station 0, Orientation 0 deg';
% %fig_title = 'Day 5 180 Comparison, 95 fps, Station 0, Orientation 0 deg';
% 
% 
% points = [7,8,10, 27:30,32:37, 53:58];
points = [18,19,43:49,65:68,164:168,205:211,247:252];
%points = [19, 49, 68, 168, 211, 252];
%points = [81:87, 286:290, 113:118, 302:306];
%points = [87, 290, 118, 306];
%points = [87, 118, 290, 306];
%points = [262:267, 280:285, 298:301];
%points = [280:285, 298:301];

points = [153:157];
%points = [158:162];
%points = [164:168];

% plotted this one by accident but normalization is amazing, day 2 95
% with day 3 140, there is no such thing as day 2&3 comp at 95
%fig_title = 'Day 2 & 3 Comparison, 50 fps, Station 3, Orientation 270 deg';
fig_title = '140 fps, Station 13,4,3, Orientation 0';
fig_title = 'test';
%fig_title = 'Day 5 Comparison, 95 fps, Station 0, Orientation 0 deg';
%fig_title = 'Day 5 180 Comparison, 95 fps, Station 0, Orientation 0 deg';

%length(tags)
%for i = 1:1
%fig_title = ['Day ',run{i,ind.day},', TPN ',run{i,ind.tpn}, ...
%    ', Station ',run{i,ind.station},', Orientation ',run{i,ind.orient},' deg'];

obj = obj.load_meas(points,'dynamic');
%obj = obj.load_pref();
meas = obj.meas;

name = obj.plot_meas(1,fig_title);

q = 0.019641;
%q = 0.0696988;
%q = .1514278;

pstatic = 14.21330817;
% pstatic = 14.2190296;
figure(2); clf; hold on
for i = 1:length(points)
    plot(meas(i,:)/q);
end
grid on


%obj.save_plot(fullfile(fold_name,name));

% obj = obj.load_windoff();
% %name = obj.plot_meas(2,fig_title);
% %obj.save_plot(fullfile(fold_name,name));
% %set(gcf,'color','w'); img = getframe(gcf); imwrite(img.cdata, [name, '.png']);
% 
% obj = obj.load_pref();
% name = obj.plot_meas(3,fig_title);
% %obj.save_plot(fullfile(fold_name,name));
% %set(gcf,'color','w'); img = getframe(gcf); imwrite(img.cdata, [name, '.png']);
% 
% obj = obj.load_atmos();
% obj.plot_meas(2,fig_title)
% 
% obj = obj.load_meas(points,'total');
% obj.plot_meas(3,fig_title);
% 
% obj = obj.load_windoff();
% obj = obj.load_pref();
% obj = obj.load_atmos();
% obj.plot_meas(4, fig_title);


