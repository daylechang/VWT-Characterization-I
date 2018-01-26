

classdef VWT_Rake_Data
    
    properties
        raw_data  % raw data, never changes
        
        meas      % the currently loaded measurements
        points    % the currently loaded test point numbers
        fig_title
        pnt_index % index of currently loaded points
        tag_index % index of currently loaded columns
        
        tag       % total or static measurements
        stand_atm = 14.696 % standard atmosphere [psi]
        warn_trip 
        
        units = 'psi';
        status = {'raw'};
        
        num_fields % or number of channels
        num_points % number of test point numbers
        columns % what's in the columns.txt file and should be in raw_data
        header  % what's in the raw data, don't use this
        col_index % index of the columns
        tags % info on how to call statics and totals
        keys % info on how to call wind-off
        
        % name of each corresponding file
        data_file
        col_file
        tag_file
        offset_file
        point_file
        
    end
    
    methods
        function obj = VWT_Rake_Data(data_file, col_file, tag_file, ...
                offset_file,point_file)
            
            obj.data_file = data_file;
            obj.col_file = col_file;
            obj.tag_file = tag_file;
            obj.offset_file = offset_file;
            obj.point_file = point_file;
            
            % make sure these files all exist
            
        end
        function obj = read_cols(obj)
            % read in col_file
            fileID = fopen(obj.col_file,'r');
            line = fgetl(fileID);
            
            i = 1;
            while ischar(line)
                obj.columns{i} = line;
                i = i+1;
                line = fgetl(fileID);
            end
            
            fclose(fileID);
            obj.num_fields = i-1;
            %obj.fields = fields;
            %obj.num_fields = num_fields;
            
        end
        function obj = read_tags(obj)
            % use tag file to help plot data
            %tag_file = 'tags.txt';
            
            
            % read in the column file that contain all fields to include
            fileID = fopen(obj.tag_file,'r');
            line = fgetl(fileID);
            fields = strsplit(line,'\t');
            field_num = length(fields);
            
            line = fgetl(fileID);
            data = cell(1,field_num);
            
            i = 1;
            while ischar(line)
                
                data{i} = strsplit(line,'\t');
                
                i = i+1;
                line = fgetl(fileID);
            end
            
            fclose(fileID);
            channel_num = i-1;
            
            % re-sort the column file into a struct called tags
            for i = 1:field_num
                obj.tags(i).name = fields{i};
                
                for j = 1:channel_num
                    obj.tags(i).channel{j} = data{j}{i};
                    obj.tags(i).key(j) = find(not(cellfun('isempty', strfind(obj.columns, data{j}{i}))));
                end
            end
            
        end
        function obj = read_data(obj)
            % read in data_file
            fileID = fopen(obj.data_file,'r');
            obj.header = strsplit(fgetl(fileID),'\t'); fgetl(fileID);
            line = fgetl(fileID);
            
            i = 1;
            while ischar(line)
                if strcmp(strsplit(line,'\t'), '')
                    line = fgetl(fileID);
                    continue
                end
                
                data{i} = strsplit(line,'\t');
                i = i+1;
                line = fgetl(fileID);
            end
            
            fclose(fileID);
            obj.num_points = i-1;
            
            
            %return
            % finds the index where item resides in cell array
            %index = find(not(cellfun('isempty', strfind(fields, ident))));
            
            keep = [];
            exist_flag = true;
            for i = 1:obj.num_fields
                field = obj.columns{i};
                index = find(not(cellfun('isempty', strfind(obj.header, field))));
                %disp(field)
                if isempty(index) || (length(index) >= 2)
                    disp([field, ' field does not exist...'])
                    exist_flag = false;
                else
                    keep = [keep; index];
                end
                
            end
            
            if ~exist_flag % if a field in col_file does not exist, exit
                return
            end
            
            if obj.num_fields ~= length(keep)
                disp('something is not right, check col_file')
                return
            end
            %num_fields = length(keep); % should be the same, but just in case
            
            
            % re-sort the data
            %meas = zeros(num_points, num_fields);
            
            for i = 1:obj.num_points
                obj.raw_data(i).data = data{i}(keep);
            end
            obj.col_index = keep;
            
        end
        function obj = read_windoff(obj)  % read wind-off correspondance file
            fileID = fopen(obj.offset_file,'r');
            fgetl(fileID);
            %header = fgetl(fileID);
            fgetl(fileID);
            line = fgetl(fileID);
            
            i = 1;
            while ischar(line)
                data{i} = line;
                i = i+1;
                line = fgetl(fileID);
            end
            
            fclose(fileID);
            num_pts = i-1;
            
            obj.keys(1).name = 'wind-off';
            obj.keys(1).header = {'wind-off','corresponding data'};
            
            for i = 1:num_pts
                datii = strsplit(strtrim(data{i}));
                %list = obj.str2list(datii{1});
                obj.keys(1).index{i,1} = obj.str2list(datii{1});
                obj.keys(1).index{i,2} = obj.str2list(datii{2});
            end
            
        end
        function obj = read_points(obj)
            fileID = fopen(obj.point_file,'r');
            points = fgetl(fileID);
            points = strsplit(points,',');
            
            obj.points = [];
            
            for i = 1:length(points)
                point = strsplit(points{i},':');
                
                if length(point) == 1
                    obj.points = [obj.points, str2double(point{1})];
                elseif length(point) == 2
                    
                    obj.points = [obj.points, ...
                        str2double(point{1}):str2double(point{2})];
                else
                    error('something is not right in the point file')
                end
                %    disp(point_array)
                %return
            end
            
            obj.fig_title = fgetl(fileID);
            
            fclose(fileID);
        end
        
        function [indices, warn_trip] = find_point(obj,list_of_points)
            % finds the matrix indices of the given TPN
            num_pts = length(list_of_points);
            indices = zeros(1,num_pts)-1;
            points = zeros(1,num_pts)-1;
            
            ind = find(not(cellfun('isempty', strfind(obj.columns, 'TPN'))));
            
            for i = 1:num_pts
                index = 1;
                for j = 1:obj.num_points
                    point = str2double(obj.raw_data(j).data{ind});
                    
                    if point == list_of_points(i)
                        indices(i) = index;
                        points(i) = point;
                        break
                    else
                        index = index + 1;
                    end
                    
                end
            end
            
            warn_trip = obj.warn_trip;
            if ~isempty(points(points == -1))
                if ~obj.warn_trip
                    disp([' point(s) ',num2str(list_of_points(points == -1)),' were excluded'])
                    warn_trip = true;
                end
                indices(indices == -1) = [];
                
                %points(points == -1) = [];
            end
            
        end
        function data = find_meas(obj, pnt_ind, tag) % returns correct data
            %pnt_ind = obj.points;
            tag_ind = [];
            % find the indices for a given tag
            for i = 1:length(obj.tags)
                if strcmpi(obj.tags(i).name, tag)
                    tag_ind = obj.tags(i).key;
                    break
                end
            end
            
            if isempty(tag_ind)
                %disp()
                error(['the tag ''',tag,''' is unrecognized'])
            end
            
            
            data = zeros(length(pnt_ind), length(tag_ind));
            
            for i = 1:length(pnt_ind)
                %data = obj.raw_data(i).data
                data(i,:) = str2double(obj.raw_data(pnt_ind(i)).data(tag_ind));
                %break
            end
        end
        function obj = load_meas(obj, points, tag)
            obj.points = points;
            obj.tag = tag;
            [obj.pnt_index, obj.warn_trip] = obj.find_point(points);
            
            if strcmpi(tag, 'dynamic')
                static = obj.find_meas(obj.pnt_index, 'static');
                total = obj.find_meas(obj.pnt_index, 'total');
                obj.meas = total - static;
                
            else
                obj.meas = obj.find_meas(obj.pnt_index, tag);
                
            end
            
            obj.status = {'raw'};
            obj = obj.remove_nans();
            
            
        end
        function obj = remove_nans(obj)
            
            % the indices to remove
            array = [];
            
            % go through each point and find nan's
            for i = 1:length(obj.pnt_index)
                
                line = obj.meas(i,:);
                if isnan(line) == 1 % if there is a nan in the line of data
                    %disp('there is a nan')
                    array = [array;i];
                end
            end
            
            % remove any lines of nan from the data (if any)
            obj.meas(array,:) = [];
            obj.pnt_index(array) = [];
        end
        function data = find_windoff(obj, tag)
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
                [point_index, ~] = obj.find_point(array);
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
            
        end
        function obj = load_windoff(obj)
            
            if strcmpi(obj.tag, 'dynamic')
                static = obj.find_windoff('static');
                total = obj.find_windoff('total');
                data = total - static;
            else
                data = obj.find_windoff(obj.tag);
            end
            obj.meas = obj.meas - data;
            obj.status{end+1} = 'windoff';
            
            
        end
        function data = find_anyp(obj, tag)
            
            count = 0;
            
            % search and make sure the specified tag is unique
            for i = 1:length(obj.columns)
                %if contains(obj.columns{i},tag,'IgnoreCase',true)
                if strfind(lower(obj.columns{i}), lower(tag))
                    count = count + 1;
                    p_ind = i;
                end
            end
            
            % if it's not unique throw an error
            if count ~= 1
                error(['the specified tag ''',tag,''' is not unique'])
            end
            
            % save off this new tag
            %new_tag = obj.columns{p_ind};
            
            % find the index in raw_data that this new tag
            %p_ind = find(not(cellfun('isempty', strfind(obj.columns, 'VWT_PREF'))));
            data = zeros(size(obj.meas));
            
            % go point by point and find refp
            for i = 1:length(obj.pnt_index)
                
                point = obj.pnt_index(i);
                data(i,:) = str2double(obj.raw_data(point).data{p_ind});
            end
            
        end
        function obj = load_pref(obj)
            
            if strcmpi(obj.tag, 'dynamic')
                % do nothing
            else
                data = obj.find_anyp('ref');
                obj.meas = obj.meas + data;
            end
            
            obj.status{end+1} = 'pref';
            
        end
        
        function obj = load_atmos(obj)
            
            % Pref - (Pref_wo - SA) = new_pref
            % or 
            % Pref + (SA - Pref_wo) = new_pref
            % delta_pref = (SA - Pref_wo)
            %
            % assumes SA > pref_wo most of the time
            
            pref_wo = obj.find_windoff('pref'); % pref_wo
            obj.meas = obj.meas + obj.stand_atm - pref_wo;
            obj.status{end+1} = 'atmos';           
            
        end
        
        function obj = load_norm(obj, tag)
            
            % makes specifying input 'tag' easier
            if strcmp(tag, 'q')
                new_tag = 'q';
                %elseif strcmp(tag, 'ref')
                
            elseif strcmp(tag, 'static') || strcmp(tag, 'ps')
                new_tag = '_ps';
            else
                error(['the specified tag ''',tag,''' is unrecognized'])
            end
            
            % extract the data for either VWT_Q or VWT_PS
            norm = obj.find_anyp(new_tag);
            
            % if pref has been applied to obj.meas, apply it to the static data
            for i = 1:length(obj.status)
                
                ref_applied = false;
                
                if strcmp(obj.status{i}, 'pref')
                    ref_applied = true;
                    break
                end
                
            end
            
            if ~ref_applied && ~strcmpi(obj.tag, 'dynamic')
                disp('warning: pref applied')
                obj.load_pref();
                
                % does nothing if dynamic
            end
            
            pref = zeros(size(norm));
            %             if ref_applied && strcmp(new_tag, '_ps')
            %                 pref = obj.find_anyp('ref');
            %             else
            %                 pref = zeros(size(norm));
            %             end
            norm = norm + pref;
            
            obj.meas = obj.meas ./ norm;
            
            %obj.status{end+1} = ['norm_',tag];
            obj.status{end+1} = 'norm';
            
        end
        
        
        
        function final_title = plot_meas(obj, fig_num, fig_title)
            [row, ~] = size(obj.meas);
            
            if ishandle(fig_num)
                fig_exist = true;
            else
                fig_exist = false;
            end
            
            figure(fig_num); clf; hold on; grid on
            
            if ~fig_exist % set all new figures to have these dimensions
                set(gcf, 'Units','inches')
                %set(gcf, 'Position', [1 1 9 5])
                set(gcf, 'Position', [1 1 9.75 4.5])
            end
            
            % find the index for comment
            com_ind = find(not(cellfun('isempty', strfind(obj.columns, 'Comment'))));
            comments = cell(row,1);
            
            for i = 1:row
                pnt_ind = obj.pnt_index(i);
                comments{i} = obj.raw_data(pnt_ind).data{com_ind};
                comments{i} = strrep(comments{i},'_',' ');
                plot(obj.meas(i,:),'-o')
                
            end
            
            legend(comments, 'Location', 'BestOutside')
            ylabel(['Pressure [',upper(obj.units),']'])
            xlabel('Probe Number')
            
            %some_string
            status = upper(strjoin(obj.status(2:end)));
            final_title = [fig_title,' ',upper(obj.tag),' ',status];
            final_title = strtrim(final_title);
            title(final_title)
            
            % expand axis to fill figure
            fig = gcf;
            ax = findobj(fig,'type','axes');
            for axn = 1:length(ax)
                outerpos = ax(axn).OuterPosition;
                ti = ax(axn).TightInset;
                left = outerpos(1) + ti(1);
                bottom = outerpos(2) + ti(2);
                ax_width = outerpos(3) - ti(1) - ti(3);
                ax_height = outerpos(4) - ti(2) - ti(4);
                ax(axn).Position = [left bottom ax_width ax_height];
            end
            
            
            
        end
        
        function save_plot(obj, raw_name)
            
            set(gcf,'color','w');
            img = getframe(gcf);
            imwrite(img.cdata, [raw_name, '.png']);
        end
        
        
        
    end
    
    methods (Static)
        
        
        
        % create an array based off a range specification given as str
        function list = str2list(some_string) % 13-19
            
            split_string = strsplit(some_string,',');
            range = split_string{1};
            
            split_string = strsplit(range,'-');
            
            if length(split_string) == 1
                list = str2num(split_string{1});
                
            elseif length(split_string) >= 2
                b1 = str2num(split_string{1}); b2 = str2num(split_string{2});
                %list = [b1:b2]';
                list = b1:b2;
                
            else
                disp(['input string error given: ',some_string])
                list = 0;
                return
            end
            
        end
        
        
        
    end
    
    
    
end