function [number] = str2num_GJK(input_string, idx1, idx2)
%% aren't conversions annoying?? with this script, it'll still be annoying,
%  but you can customize just how annoying it's going to be!!
%  
%  input: string -- string of characters to convert
%         idx1 -- index to begin a substring (optional)
%         idx2 -- index to end a substring (optional)
%
%  output: number -- double value containing the number; NaN if NaN
%
%  note -- takes into account negative (-) values in string's 1st char

tmp_number = [];
neg_val = false;

if nargin < 3
    if nargin < 2
        idx1 = 1;
        idx2 = length(input_string);
    else
        idx2 = length(input_string);
    end
end

for ss=idx1:idx2
    if ss==idx1
        init_char = input_string(ss);
        if strcmp(init_char,'-')
            neg_val = true;
            continue;
        end
        
        tmp_number = strcat(tmp_number,init_char);
        
    else
        tmp_number = strcat(tmp_number, input_string(ss));
    end
end

number = str2num(tmp_number);
assignin('base','number_STRING',tmp_number);
if neg_val
    number = number.*-1;
end

if isempty(number)
    number = NaN;
end



%
%%%
%%%%%
%%%
%