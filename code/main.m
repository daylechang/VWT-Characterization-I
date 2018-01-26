clc; clear all;

data_file = fullfile('M:','LS-RT_Reduced Average.txt');
pause_time = 5;

% these are the fields to read into matlab, prevents irrelevant data from
% being read
col_file = 'columns.txt';
tag_file = 'tags_orig.txt';
offset_file = 'zero_offset.txt';

%working_dir = 'data';
point_file = 'points.txt';

% initialize
data_file_local = fullfile('data','LS-RT_Reduced Average.txt');
obj = VWT_Rake_Data(data_file_local, col_file, tag_file, offset_file, point_file);

% last_mod = dir(obj.tag_file);
% last_mod = last_mod.datenum;

file_list = {data_file, col_file, tag_file, offset_file, point_file};
%file_prop = zeros(4,1);
last_mod = zeros(length(file_list),1);

while true
    
    new_file = false;
    for i = 1:length(file_list)
        file_prop = dir(file_list{i});
        if file_prop.datenum > last_mod(i)
            last_mod(i) = file_prop.datenum;
            new_file = true;
            if i == 1 % LS-RT_Reduced Average.txt
                filename = strsplit(file_list{i},'\');
                filename = filename{end};
                disp(datestr(datetime('now')))
                disp([' copied ',filename])
                copyfile(file_list{i}, data_file_local)
            end
            %
        end
    end
    
    if new_file
               
        % read in files
        obj = obj.read_cols();
        obj = obj.read_data();
        obj = obj.read_windoff();
        obj = obj.read_tags();
        %obj = obj.read_points();
        obj.warn_trip = false;
        %disp(num2str([' point(s) plotted: ',num2str(obj.points)]))
        
%         obj = obj.load_meas(obj.points,'Q');
%         %q10 = obj.meas;
%         obj.plot_meas(1,obj.fig_title);
        %return
        %obj = obj.load_meas(obj.points, 'Static');
        %obj.plot_meas(1,obj.fig_title);
        
        %obj = obj.load_meas(obj.points,'Q_11');
        
        fig_title = 'Experimental Data';
        %points = 399:403;
        points = 559:563;
        
        obj = obj.load_meas(points,'static');
        obj = obj.load_windoff();
        obj = obj.load_pref();
        obj = obj.load_atmos();
        obj.plot_meas(1,fig_title);
        
        obj = obj.load_meas(obj.points,'dynamic');
        obj = obj.load_norm('q');
        obj.plot_meas(2,fig_title);
        
        points = 404:408;
        points = 575:579;
        obj = obj.load_meas(points,'static');
        obj = obj.load_windoff();
        obj = obj.load_pref();
        obj = obj.load_atmos();
        obj.plot_meas(3,fig_title);
        
        obj = obj.load_meas(obj.points,'dynamic');
        obj = obj.load_norm('q');
        obj.plot_meas(4,fig_title);
        
        break
        
%         obj = obj.load_pref();
%         obj.plot_meas(2,obj.fig_title);
%         
        obj = obj.load_meas(obj.points,'total');
        obj.plot_meas(2,obj.fig_title);
        
        obj = obj.load_pref();
        obj.plot_meas(3,obj.fig_title);
        
        obj = obj.load_meas(obj.points,'dynamic');
        obj.plot_meas(4,obj.fig_title);
        
        obj = obj.load_norm('q');
        obj.plot_meas(5,obj.fig_title);
        
        obj.meas = obj.find_anyp('VWT_PREF');
        obj.plot_meas(6,'PREF');
%         
        disp(' --- waiting ---')
        disp(' ')
        pause(pause_time)
        
        
    end
    
end