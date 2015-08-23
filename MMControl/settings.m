function varargout = settings(varargin)
%SETTINGS M-file for settings.fig
%      SETTINGS, by itself, creates a new SETTINGS or raises the existing
%      singleton*.
%
%      H = SETTINGS returns the handle to a new SETTINGS or the handle to
%      the existing singleton*.
%
%      SETTINGS('Property','Value',...) creates a new SETTINGS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to settings_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SETTINGS('CALLBACK') and SETTINGS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SETTINGS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help settings

% Last Modified by GUIDE v2.5 06-Mar-2014 13:52:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @settings_OpeningFcn, ...
                   'gui_OutputFcn',  @settings_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before settings is made visible.
function settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to settings_figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Is the changeme_main gui's handle is passed in varargin?
% if the name 'changeme_main' is found, and the next argument
% varargin{mainGuiInput+1} is a handle, assume we can open it.

dontOpen = false;
mainGuiInput = find(strcmp(varargin, 'main'));
if (isempty(mainGuiInput)) ...
    || (length(varargin) <= mainGuiInput) ...
    || (~ishandle(varargin{mainGuiInput+1}))
    dontOpen = true;
else
    % Remember the handle, and adjust our position
    handles.mainFigure = varargin{mainGuiInput+1};
    
    % Obtain handles using GUIDATA with the caller's handle 
    handles.mainHandles = guidata(handles.mainFigure);
    
    % Position to be relative to parent:
    parentPosition = getpixelposition(handles.mainFigure);
    currentPosition = get(hObject, 'Position');  
    % Set x to be directly in the middle, and y so that their tops align.
    newX = parentPosition(1) + (parentPosition(3)/2 - currentPosition(3)/2);
    newY = parentPosition(2) + (parentPosition(4)/2 - currentPosition(4)/2);
    %newY = parentPosition(2) + (parentPosition(4) - currentPosition(4));
    newW = currentPosition(3);
    newH = currentPosition(4);
    
    set(hObject, 'Position', [newX, newY, newW, newH]);
    
    % Initialize values
    set(handles.configGroup_edit,'String',handles.mainHandles.configGroup);
    set(handles.prefix_edit,'String',handles.mainHandles.prefix);
    set(handles.plotOptions_edit,'String',handles.mainHandles.plotOptions);

    set(handles.isAutoSaveTrack_checkbox,'Value',handles.mainHandles.isAutoSaveTrack);
    set(handles.isAutoShutter_checkbox,'Value',handles.mainHandles.isAutoShutter);
    set(handles.isLaserUncage_checkbox,'Value',handles.mainHandles.isLaserUncage);
    set(handles.isExposeCam_checkbox,'Value',handles.mainHandles.isExposeCam);
end

% Update handles structure
guidata(hObject, handles);

if dontOpen
   disp('-----------------------------------------------------');
   disp('Improper input arguments. Pass a property value pair') 
   disp('whose name is "main" and value is the handle')
   disp('to the main figure, e.g:');
   disp('   x = main()');
   disp('   settings(''main'', x)');
   disp('-----------------------------------------------------');
else
   uiwait(hObject);
end


% --- Outputs from this function are returned to the command line.
function varargout = settings_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to settings_figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout{1} = [];
delete(hObject);


% --- Executes on button press in buttonCancel.
function buttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to buttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
settings_figure_CloseRequestFcn(handles.settings_figure, eventdata, handles);


% --- Executes when user attempts to close settings_figure.
function settings_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to settings_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(handles.mainFigure, handles.mainHandles);
uiresume(hObject);

% -----------------------------------------
% From main figure


function configGroup_edit_Callback(hObject, eventdata, handles)
% hObject    handle to configGroup_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of configGroup_edit as text
%        str2double(get(hObject,'String')) returns contents of configGroup_edit as a double
str = get(hObject,'String');
handles.mainHandles.configGroup = str;

updatestatus(handles.mainFigure,['Configuration group has been set to: ' str]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function configGroup_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to configGroup_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function prefix_edit_Callback(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefix_edit as text
%        str2double(get(hObject,'String')) returns contents of prefix_edit as a double
str = get(hObject,'String');
handles.mainHandles.prefix = str;

updatestatus(handles.mainFigure,['Image prefix has been set to: ' str]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function prefix_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function plotOptions_edit_Callback(hObject, eventdata, handles)
% hObject    handle to plotOptions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of plotOptions_edit as text
%        str2double(get(hObject,'String')) returns contents of plotOptions_edit as a double
str = get(hObject,'String');
handles.mainHandles.plotOptions = str;

updatestatus(handles.mainFigure,['Plot options has been set to: ' str]);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function plotOptions_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotOptions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in isAutoSaveTrack_checkbox.
function isAutoSaveTrack_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isAutoSaveTrack_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isAutoSaveTrack_checkbox
state = get(hObject,'Value');
handles.mainHandles.isAutoSaveTrack = state;

updatestatus(handles.mainFigure,['Auto Save Track has been set to: ' num2str(state)]);
guidata(hObject, handles);


% --- Executes on button press in isAutoShutter_checkbox.
function isAutoShutter_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isAutoShutter_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isAutoShutter_checkbox
state = get(hObject,'Value');
if ~isfield(handles.mainHandles,'mmc')
    updatestatus(handles.mainFigure,'Micro-manager has not started.');
    set(hObject,'Value',~state);
    return;
end
    
handles.mainHandles.isAutoShutter = state;
handles.mainHandles.mmc.setAutoShutter(handles.mainHandles.isAutoShutter);

updatestatus(handles.mainFigure,['Auto Shutter has been set to: ' num2str(state)]);
guidata(hObject, handles);


% --- Executes on button press in fl_togglebutton.
function fl_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to fl_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fl_togglebutton
state = get(hObject,'Value');
if ~isfield(handles.mainHandles,'mmc')
    updatestatus(handles.mainFigure,'Micro-manager has not started.');
    set(hObject,'Value',~state);
    return;
end

if state
    handles.mainHandles.mmc.setConfig('ShutterFL','Open');
else
    handles.mainHandles.mmc.setConfig('ShutterFL','Close');
end
updatestatus(handles.mainFigure,['FL shutter has been set to: ' num2str(state)]);


% --- Executes on button press in tr_togglebutton.
function tr_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to tr_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tr_togglebutton
state = get(hObject,'Value');
if ~isfield(handles.mainHandles,'mmc')
    updatestatus(handles.mainFigure,'Micro-manager has not started.');
    set(hObject,'Value',~state);
    return;
end

if state
    handles.mainHandles.mmc.setConfig('ShutterTR','Open');
else
    handles.mainHandles.mmc.setConfig('ShutterTR','Close');
end
updatestatus(handles.mainFigure,['TR shutter has been set to: ' num2str(state)]);


% --- Executes on button press in laser_togglebutton.
function laser_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to laser_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of laser_togglebutton
state = get(hObject,'Value');
if ~isfield(handles.mainHandles,'mmc')
    updatestatus(handles.mainFigure,'Micro-manager has not started.');
    set(hObject,'Value',~state);
    return;
end

if state
    handles.mainHandles.mmc.setConfig('ShutterUV','Open');
else
    handles.mainHandles.mmc.setConfig('ShutterUV','Close');
end
updatestatus(handles.mainFigure,['UV shutter has been set to: ' num2str(state)]);


% --- Executes on button press in isLaserUncage_checkbox.
function isLaserUncage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isLaserUncage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isLaserUncage_checkbox
state = get(hObject,'Value');
if state
    handles.mainHandles.shutterUncage = 'ShutterUV';
else
    handles.mainHandles.shutterUncage = 'ShutterFL';
end

handles.mainHandles.isLaserUncage = state;
updatestatus(handles.mainFigure,['Uncaging by Laser has been set to: ' num2str(state)]);
guidata(hObject, handles);


% --- Executes on button press in isExposeCam_checkbox.
function isExposeCam_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to isExposeCam_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of isExposeCam_checkbox
state = get(hObject,'Value');
handles.mainHandles.isExposeCam = state;

updatestatus(handles.mainFigure,['Record Uncaging has been set to: ' num2str(state)]);
guidata(hObject, handles);
