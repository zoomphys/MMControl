function handles = startMM()

import org.micromanager.MMStudioMainFrame;

handles = struct;

handles.gui = MMStudioMainFrame(false);
handles.gui.show;
pause(1);

% Get core and acquisition engine
handles.mmc = handles.gui.getCore;
handles.mma = handles.gui.getAcquisitionEngine;

% Assign handles to the base for other programs to access
assignin('base','handles',handles);
