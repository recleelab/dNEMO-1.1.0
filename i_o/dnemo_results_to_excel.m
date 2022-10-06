function [] = dnemo_results_to_excel(root_name, cell_arr)
%% <placeholder>
%

xls_answer = questdlg('Additionally save results file as xls/csv spreadsheet?',...
    'Save to Excel', 'Yes', 'No', 'No');
if strcmp(xls_answer, 'No')
    return
end

if ispc
    
    xls_filename = strcat(root_name,'.xlsx');
    
    spot_arr = cell_arr{1};
    spot_sheet = 'SPOTS';
    
    header = fieldnames(spot_arr).';
    print_mat = header;
    for frame_idx=1:length(spot_arr)
        tmp_mat = [];
        for field_idx=1:length(header)
            tmp_field = [spot_arr(frame_idx).(header{field_idx})];
            tmp_mat = cat(2, tmp_mat, tmp_field);
        end
        print_mat = cat(1, print_mat, num2cell(tmp_mat));
    end
    
    % modified -- 4/29/22
    % when dealing with some larger datasets, like [z-stack] x 
    % [150+ timepoints], large number of spots won't write to excel using
    % matlab's 'xlswrite'. updated to using writetable by converting
    % cell array >> structure array >> table >> excel spreadsheet
    % xlswrite(xls_filename, print_mat, spot_sheet);
    print_struct = cell2struct(print_mat(2:end,:),print_mat(1,:),2);
    print_table = struct2table(print_struct);
    writetable(print_table, xls_filename, 'Sheet', spot_sheet);
    % writetable(print_table, xls_filename);
    
    if length(cell_arr) > 1
        
        cells = cell_arr{2};
        if isempty(cells) || isempty(fieldnames(cells{1}))
            return;
        end
        for cell_idx=1:length(cells)
            
            tmp_struct = cells{cell_idx};
            cell_str = char(strcat('CELL #',num2str(cell_idx)));
            print_mat = header;
            
            for frame_idx=1:length(tmp_struct)
                tmp_mat = [];
                for field_idx=1:length(header)
                    tmp_field = [tmp_struct(frame_idx).(header{field_idx})];
                    tmp_mat = cat(2, tmp_mat, tmp_field);
                end
                print_mat = cat(1, print_mat, num2cell(tmp_mat));
            end
            % xlswrite(xls_filename, print_mat, cell_str);
            print_struct = cell2struct(print_mat(2:end,:),print_mat(1,:),2);
            print_table = struct2table(print_struct);
            writetable(print_table, xls_filename, 'Sheet', cell_str);
        end
        
    end
    
else
    xls_filename = strcat(root_name,'.csv');
    spot_arr = cell_arr{1};
    header = fieldnames(spot_arr);
    
    print_mat = [];
    
    for frame_idx=1:length(spot_arr)
        tmp_mat = [];
        for field_idx=1:length(header)
            tmp_field = [spot_arr(frame_idx).(header{field_idx})];
            tmp_mat = cat(2, tmp_mat, tmp_field);
        end
        print_mat = cat(1, print_mat, tmp_mat);
    end
    
    csvwrite(xls_filename, print_mat);
    
end

%
%%%
%%%%%
%%%
%