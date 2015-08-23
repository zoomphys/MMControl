function updatestatus(figure,msg)
figHandles = guidata(figure);
log = getappdata(figure,'log');
log = {log{:} [getTime() '   ' msg]};
% log = {log{:} msg};

disp(msg);
%msg
set(figHandles.status_text,'String',msg);
setappdata(figure,'log',log);
