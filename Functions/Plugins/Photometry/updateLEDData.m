function updateLEDData(S)
    
    global nidaq

    % generate output data
    nidaq.dt = 1/nidaq.sample_rate;
    t = 0:nidaq.dt:nidaq.duration - nidaq.dt; %last sample starts dt prior to t = duration
    LED1_data = (sin(2*pi*S.nidaq.LED1_f*t) + 1) /2 * S.GUI.LED1_amp;
%     LED1_data = zeros(1, length(t)) + .7;
    LED2_data = (sin(2*pi*S.nidaq.LED2_f*t) + 1) /2 * S.GUI.LED2_amp;
    LED1_data = [LED1_data]';
    LED2_data = [LED2_data]';

    
    nidaq.ao_data = [LED1_data LED2_data];
    
    nidaq.session.queueOutputData(nidaq.ao_data);