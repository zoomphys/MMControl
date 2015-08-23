function strBin = getBinArray(strOrder)
% Get the boolean order string from string binary strOrder after checking the format 

% strip white spaces and check if the remaining characters are one of
% ('0','1')
strArray = strsplit(strtrim(strOrder));

strBin = '';
for i=1:length(strArray)
    s = strArray{i};
    if isempty(strfind(s,'x'))
        % if there is non '0' or '1' character
        if ~isempty(regexp(s,'[^0-1]','once'))
            s = [];
        end

        strBin = [strBin s];
    else
        sequence = strsplit(s,'x');
        error = 0;
        if length(sequence)~=2
            error = 1;
        else
            bit = sequence{1};
            if ~strcmp(bit,'0') && ~strcmp(bit,'1')
                error = 1;
            end
            
            exponent = str2num(sequence{2});
            if isempty(exponent)
                error = 1;
            end
            exponent = round(exponent);
        end
        
        if ~error
            strBin = [strBin repmat(bit,1,exponent)];
        end
    end
    
end

% binArray = (strBin=='1');
