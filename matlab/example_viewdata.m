% example file to view plots of specified points
clear all; clc

% where to read the data file
data_file = fullfile('data','LS-RT_Reduced Average.txt');

% these are the fields/tags to read in, don't read irrelevant data
col_file = 'columns.txt'; % fields to read in
tag_file = 'tags.txt';    % label the fields
offset_file = 'zero_offset.txt';  % associated wind-off for every point
point_file = ''; % this file not needed since points will be manually set

% initialize
obj = VWT_Rake_Data(data_file, col_file, tag_file, offset_file, point_file);

% read in files
obj = obj.read_cols(); % read col_file
obj = obj.read_data(); % read data_file
obj = obj.read_windoff(); % read offset_file
obj = obj.read_tags(); % read tag_file

% save plots in this folder
fold_name = 'plots';

% choose any of these data points
%points = [18,19,43:49,65:68,164:168,205:211,247:252];
points = [19, 49, 68, 168, 211, 252];
%points = [19, 49, 68, 168, 211, 252];
%points = [81:87, 286:290, 113:118, 302:306];
%points = [87, 290, 118, 306];
%points = [87, 118, 290, 306];

% choose a figure title
%fig_title = 'Day 2 & 3 Comparison, 50 fps, Station 3, Orientation 270 deg';
fig_title = 'Streamwise Pressure Profiles at 140 fps, Orientation 0';
%fig_title = 'Day 5 Comparison, 95 fps, Station 0, Orientation 0 deg';
%fig_title = 'Day 5 180 Comparison, 95 fps, Station 0, Orientation 0 deg';
    
% load either 'static', 'dynamic', or 'total' measurements
obj = obj.load_meas(points,'static');
fig_num = 1;
name = obj.plot_meas(fig_num,fig_title); % use variable 'name' as save name
obj.save_plot(fullfile(fold_name,name));

% compensate data for wind-off data
obj = obj.load_windoff();
% add pref to the data
obj = obj.load_pref();
obj.plot_meas(2,fig_title); % plot without saving off 'name' variable

% compensate data for standard atmosphere
obj = obj.load_atmos();
obj.plot_meas(3,fig_title);

% compare with totals
obj = obj.load_meas(points,'total');
obj = obj.load_windoff();
obj = obj.load_pref();
obj = obj.load_atmos();
obj.plot_meas(4, fig_title);
