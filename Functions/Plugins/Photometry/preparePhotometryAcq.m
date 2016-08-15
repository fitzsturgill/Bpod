function preparePhotometryAcq(S)
    % prepares NIDAQ session
    % S = Bpod settings structure (contains updated information about LED
    % intensity, etc.)
    global nidaq
    updateLEDData(S); % FS MOD        
    nidaq.ai_data = [];
    nidaq.session.prepare(); %Saves 50ms on startup time, perhaps more for repeats.
    nidaq.session.startBackground(); % takes ~0.1 second to start and release control.