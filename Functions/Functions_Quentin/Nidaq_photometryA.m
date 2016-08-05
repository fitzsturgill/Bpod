function nidaq=Nidaq_photometryA(action,nidaq)
global NidaqData_thisTrial

switch action
    case 'ini'
%% NIDAQ Initialization
%  Define parameters for analog inputs.
nidaq.duration                 = 15;       % Arbitrary long
nidaq.sample_rate              = 2000;     % 2khz aquisition
nidaq.ai_channels              = {'ai0','ai1','ai2'};       % 3 channels

% Define parameters for analog outputs (important for LED modulation
nidaq.ao_channels                 = {'port0/line0'};           % 1 channel (for laser)
nidaq.ao_data                     = ones(nidaq.sample_rate,length(nidaq.ao_channels));

daq.reset
daq.HardwareInfo.getInstance('DisableReferenceClockSynchronization',true); % Necessary for this Nidaq

% Set up session and channels
nidaq.session = daq.createSession('ni')
for ch = nidaq.ai_channels
    addAnalogInputChannel(nidaq.session,'Dev1',ch,'Voltage');
end
for ch = nidaq.ao_channels
    addDigitalChannel(nidaq.session,'Dev1',ch, 'OutputOnly')
end

% Sampling rate and continuous updating (important for queue-ing ao data)
nidaq.session.Rate = nidaq.sample_rate;
nidaq.session.IsContinuous = true;


    case 'WaitToStart'
%% GET NIDAQ READY TO RECORD
    NidaqData_thisTrial = [];
    nidaq.session.queueOutputData(nidaq.ao_data)
    nidaq.session.NotifyWhenDataAvailableExceeds = nidaq.session.Rate/5; % Must be done after queueing data.
    nidaq.session.prepare();            %Saves 50ms on startup time, perhaps more for repeats.
    nidaq.session.startBackground();    % takes ~0.1 second to start and release control. 
  

    case 'Stop'
%% STOP NIDAQ
    nidaq.session.stop()
    wait(nidaq.session) % Wait until nidaq session stop
    nidaq.session.outputSingleScan(zeros(1,length(nidaq.ao_channels))); % drop output back to 0
end
end