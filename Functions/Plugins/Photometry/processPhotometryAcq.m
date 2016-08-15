function processPhotometryAcq(currentTrial)
    global BpodSystem nidaq
    
    
%     pause(0.05); 
%     nidaq.session.stop() % Kills ~0.002 seconds after state matrix is done.
%     wait(nidaq.session) % Trying to wait until session is done - did we record the full session?
    
    % ensure outputs reset to zero
%     nidaq.session.outputSingleScan(zeros(1,length(nidaq.aoChannels)));

    %% Save data in BpodSystem format.
    BpodSystem.Data.NidaqData{currentTrial, 1} = nidaq.ai_data; %input data
    BpodSystem.Data.NidaqData{currentTrial, 2} = nidaq.ao_data; % output data
    
    