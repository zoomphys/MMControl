
function edit_number(hObject, handles, varname,vartype)
str = get(hObject,'String');
if isempty(str)
    set(hObject,'String',num2str(handles.(varname)));
    return;
end

if strcmp(vartype,'double')
    handles.(varname) = str2double(str);
elseif strcmp(vartype,'int')
    handles.(varname) = round(str2double(str));
end

updatestatus(handles.main_figure,[varname ' has been set to: ' num2str(handles.(varname))]);
guidata(hObject, handles);
