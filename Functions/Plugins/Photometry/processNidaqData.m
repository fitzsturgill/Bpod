function processNidaqData(src,event)
    % callback function, session assummed to be non-continuous with
    % dataAvailableExceeds == SampleRate * Duration
    global nidaq
    nidaq.ai_data = event.Data; % for non-continuous acquisition     
    correctSamples = nidaq.duration * nidaq.sample_rate;
    nSamples = size(nidaq.ai_data, 1);
    samplesShort = correctSamples - nSamples;
    if samplesShort > 0
        nidaq.ai_data = [nidaq.ai_data; NaN(samplesShort, size(event.Data, 2))];
    elseif samplesShort < 0
        nidaq.ai_data = nidaq.ai_data(1:correctSamples, :);
    end

    nidaq.session.stop(); % Kills ~0.002 seconds after state matrix is done.

