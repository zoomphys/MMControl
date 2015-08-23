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

% Last Modified by GUIDE v2.5 28-Mar-2013 12:24:22

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
    
    set(handles.configGroup_edit,'String',handles.mainHandles.configGroup);
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
uiresume(handles.settings_figure);


% --- Executes when user attempts to close settings_figure.
function settings_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to settings_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(hObject);

% -----------------------------------------
% From main figure

% --- Executes on button press in setBottom_pushbutton.
function setBottom_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setBottom_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.mainHandles.limitBottom = handles.mainHandles.mmc.getYPosition(handles.mainHandles.stage)+handles.mainHandles.limitMargin;
updatestatus(handles.mainFigure,['The stage bottom limit is set to: ' num2str(handles.mainHandles.limitBottom)]);
guidata(handles.mainFigure, handles.mainHandles);


% --- Executes on button press in setTop_pushbutton.
function setTop_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setTop_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.mainHandles.limitTop = handles.mainHandles.mmc.getYPosition(handles.mainHandles.stage)-handles.mainHandles.limitMargin;
updatestatus(handles.mainFigure,['The stage top limit is set to: ' num2str(handles.mainHandles.limitTop)]);
guidata(handles.mainFigure, handles.mainHandles);


% --- Executes on button press in setLeft_pushbutton.
function setLeft_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setLeft_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.mainHandles.limitLeft = -(handles.mainHandles.mmc.getXPosition(handles.mainHandles.stage)+handles.mainHandles.limitMargin);
updatestatus(handles.mainFigure,['The stage left limit is set to: ' num2str(handles.mainHandles.limitLeft)]);
guidata(handles.mainFigure, handles.mainHandles);


% --- Executes on button press in setRight_pushbutton.
function setRight_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setRight_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.mainHandles.limitRight = -(handles.mainHandles.mmc.getXPosition(handles.mainHandles.stage)-handles.mainHandles.limitMargin);
updatestatus(handles.mainFigure,['The stage right limit is set to: ' num2str(handles.mainHandles.limitRight)]);
guidata(handles.mainFigure, handles.mainHandles);


function configGroup_edit_Callback(hObject, eventdata, handles)
% hObject    handle to configGroup_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of configGroup_edit as text
%        str2double(get(hObject,'String')) returns contents of configGroup_edit as a double
handles.mainHandles.configGroup = get(hObject,'String');
updatestatus(handles.mainFigure,['Configuration group has been set to: ' handles.mainHandles.configGroup]);
guidata(handles.mainFigure, handles.mainHandles);


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
