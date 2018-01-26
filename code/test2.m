
data_file = fullfile('M:','LS-RT_Reduced Average.txt');

% these are the fields to read into matlab, prevents irrelevant data from
% being read
col_file = 'columns.txt';
tag_file = 'tags_test.txt';
offset_file = 'zero_offset.txt';

%working_dir = 'data';
point_file = 'points.txt';

% initialize
data_file_local = fullfile('data','LS-RT_Reduced Average.txt');
obj = VWT_Rake_Data(data_file_local, col_file, tag_file, offset_file, point_file);

obj = obj.read_cols();
obj = obj.read_data();
obj = obj.read_windoff();



% read in the column file that contain all fields to include
            fileID = fopen(obj.tag_file,'r');
            line = fgetl(fileID);
            fields = strsplit(line,'\t');
            field_num = length(find(not(cellfun('isempty',fields))));
           
            line = fgetl(fileID);
            data = cell(1,field_num);
            
            i = 1;
            while ischar(line)
                
                data{i} = strsplit(line,'\t');
                
                i = i+1;
                line = fgetl(fileID);
            end
            
            fclose(fileID);
            
            return
            channel_num = i-1;
            %return
            % re-sort the column file into a struct called tags
            for i = 1:field_num
                obj.tags(i).name = fields{i};
                
                for j = 1:channel_num
                    obj.tags(i).channel{j} = data{j}{i};
                    obj.tags(i).key(j) = find(not(cellfun('isempty', strfind(obj.columns, data{j}{i}))));
                end
            end