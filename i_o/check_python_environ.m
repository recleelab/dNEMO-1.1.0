function [bool_flag] = check_python_environ()
%% <placeholder>
%

txt_filename = 'os_python3_location.txt';
txt_id = fopen(txt_filename);

line_01 = fgetl(txt_id);
line_02 = fgetl(txt_id);
line_03 = fgetl(txt_id);

bool_flag = 0;

% header
if strcmp(line_01, '#OS-PYTHON3-LOCATION')
    
    python3_loc_string = line_02;
    setenv('PATH', python3_loc_string);
    
    executable_loc_string = line_03;
    pyversion(executable_loc_string);
    
    bool_flag = 1;
end


%
%%%
%%%%%
%%%
%