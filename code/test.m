clc; clear all;

data_file = fullfile('post_fixed','LS-RT_Reduced Average.txt');
pause_time = 5;

% these are the fields to read into matlab, prevents irrelevant data from
% being read
col_file = 'columns.txt';
tag_file = 'tags.txt';
offset_file = 'zero_offset.txt';

%working_dir = 'data';
point_file = 'points.txt';

% initialize
data_file_local = fullfile('data','LS-RT_Reduced Average.txt');
obj = VWT_Rake_Data(data_file_local, col_file, tag_file, offset_file, point_file);
%obj.stand_atm = 14.696; % psi

% last_mod = dir(obj.tag_file);
% last_mod = last_mod.datenum;

file_list = {data_file, col_file, tag_file, offset_file};
%file_prop = zeros(4,1);
last_mod = zeros(4,1);

obj = obj.read_cols();
obj = obj.read_data();
obj = obj.read_windoff();
obj = obj.read_tags();
obj = obj.read_points();

% points = [18,19,43:49,65:68];
points = [71:72];
obj = obj.load_meas(points,'static');
%obj = obj.load_windoff()


tag = 'pref';

% need to update so it doesn't recalculate if the windoff point
% hasn't changed
pnt_ind = find(not(cellfun('isempty', strfind(obj.columns, 'TPN'))));
data = zeros(size(obj.meas));
%pref = zeros(size(obj.meas,1));

% go point by point and find corresponding wind-off point
for i = 1:length(obj.pnt_index)
    
    point = str2double(obj.raw_data(obj.pnt_index(i)).data{pnt_ind});
    
    windoff_ind = -1;
    [rows, ~] = size(obj.keys.index);
    for j = 1:rows % wind-off index
        
        % array of data points
        array = obj.keys.index{j,2};
        if ~isempty(array(array == point))
            %disp('found it')
            windoff_ind = j;
            break
        end
    end
    %return
    % if windoff_ind never gets found, the point in question is
    % a wind-off point SOMETHINGS NOT RIGHT, NEED TO CHANGE
    % THIS
    if windoff_ind == -1
        windoff_ind = obj.pnt_index(i);
    end
    
    % wind_off points are found, now extract
    array = obj.keys.index{windoff_ind,1}; % array of wind-off points
    %return
    % find the index of the wind_off point
    point_index = obj.find_point(array);
    %[~, cols] = size(obj.meas);
    
    
    % find the indices for the given tag
    
    if strcmp(tag, 'pref')
        tag_ind = find(not(cellfun('isempty', strfind(obj.columns, 'VWT_PREF'))));
    else
        for j = 1:length(obj.tags)
            if strcmpi(obj.tags(j).name, tag)
                tag_ind = obj.tags(j).key;
                break
            end
        end
        
    end
    
    
    % initialize all wind-off data for given tag and fill it in
    wo_data = zeros(length(point_index),length(tag_ind));
    data_written = false; % just in case, but should never need to be used
    
    for j = 1:length(point_index)
        pnt = point_index(j);
        line_of_data = str2double(obj.raw_data(pnt).data(tag_ind));
        
        % only write/save the data if there are no NaN's
        if isempty(line_of_data(isnan(line_of_data)))
            wo_data(j,:) = line_of_data;
            data_written = true;
        end
        
    end
    
    if ~data_written
        disp('no usable wind-off data to read from')
    end
    %return
    
    % ----------
    % average the data column by column
    %data(i,:) = mean(wo_data,1);
    
    % only use the latest windoff point
    data(i,:) = wo_data(end,:);
    % ---------
    
    
    %                 % subtract the wind-off data from measurements if meas has no NaN
    %                 if isnan(obj.meas(i,:)) == 0
    %                     obj.meas(i,:) = obj.meas(i,:) - data;
    %                 end
    
end

