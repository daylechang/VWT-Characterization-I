% example file of real-time plot updates.
clear all; close all; clc

% where the data is being written to by data system
%data_file = fullfile('M:','LS-RT_Reduced Average.txt');
data_file = fullfile('source','LS-RT_Reduced Average.txt');
% where to copy the file
data_file_local = fullfile('data','LS-RT_Reduced Average.txt');

% how long to wait
pause_time = 5; % sec

% these are the fields/tags to read in, don't read irrelevant data
col_file = 'columns.txt'; % fields to read in
tag_file = 'tags.txt';    % label the fields
offset_file = 'zero_offset.txt';  % associated wind-off for every point
point_file = 'points.txt'; % points to plot
% for the point_file, change/update the points plotted on 1st line and
% change title of figures on 2nd line. anything after that is ignored.
% changes take place without having to re-run the program

% initialize
obj = VWT_Rake_Data(data_file_local, col_file, tag_file, offset_file, point_file);

file_list = {data_file, col_file, tag_file, offset_file, point_file};
last_mod = zeros(length(file_list),1); % last modified time of every file

while true
    
    new_file = false;
    for i = 1:length(file_list) % for very file
        file_prop = dir(file_list{i});
        if file_prop.datenum > last_mod(i) % if it's a new file
            last_mod(i) = file_prop.datenum;
            new_file = true;
            if i == 1 % if the new file is LS-RT_Reduced Average.txt
                filename = strsplit(file_list{i},'\');
                filename = filename{end};
                disp(datestr(datetime('now')))
                disp([' copied ',filename])
                copyfile(file_list{i}, data_file_local) % copy the file
            end
        end
    end
    
    % if there were any new files
    if new_file
               
        % read in files
        obj = obj.read_cols();
        obj = obj.read_data();
        obj = obj.read_windoff();
        obj = obj.read_tags();
        obj = obj.read_points();
        
        % re-set the warning so only 1 warning is printed
        obj.warn_trip = false;
        
        obj = obj.load_meas(obj.points,'static');
        obj.plot_meas(1,obj.fig_title);
          
        obj = obj.load_meas(obj.points,'total');
        obj.plot_meas(2,obj.fig_title);
        
        obj = obj.load_pref();
        obj.plot_meas(3,obj.fig_title);
        
        obj = obj.load_meas(obj.points,'dynamic');
        obj.plot_meas(4,obj.fig_title);
        
        disp(' --- waiting ---')
        disp(' ')
        pause(pause_time)
        
        
    end
    
end