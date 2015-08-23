function handles = startMM()

import org.micromanager.MMStudioMainFrame;

handles = struct;

handles.gui = MMStudioMainFrame(false);
handles.gui.show;
pause(1);

handles.mmc = handles.gui.getCore;

%handles.wheelEX = 'WheelEX';
%handles.wheelEM = 'WheelEM';
% handles.configGroup = 'Channel';

% configAcq_default = {'CFP-CFP','CFP-YFP'};
% exposure_default = [10 10];
% handles.acq = struct;
% handles.acq.configs = configAcq_default;
% handles.acq.exposure = exposure_default;
% handles.acq = handles.gui.getAcquisitionEngine;

assignin('base','handles',handles);
