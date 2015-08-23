function saveLog(handles)
% Save log to a file
if ~exist(handles.filedir,'dir')
    filedir = '';
    updatestatus(handles.main_figure,'Directory does not exist. Log is saved to the program directory.');
else
    filedir = handles.filedir;
end

log = getappdata(handles.main_figure,'log');
logFilePath = fullfile(filedir,'MMControl_log.txt');

updatestatus(handles.main_figure,['Program log is saved to: ' logFilePath]);
fid = fopen(logFilePath,'wt');
fprintf(fid, '%s\n', log{:});
fclose(fid);
    