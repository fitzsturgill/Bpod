function processNidaqData(src,event)
    % callback function
    global nidaq
    nidaq.duration
    nidaq.ai_data = event.Data; % for non-continuous acquisition     
    correctSamples = nidaq.duration / nidaq.sample_rate;
    nSamples = size(nidaq.ai_data, 1);
    samplesShort = correctSamples - nSamples;
    if samplesShort > 0
        nidaq.ai_data = [nidaq.ai_data; NaN(samplesShort, size(event.Data, 2))];
    elseif sampleShort < 0
        nidaq.ai_data = nidaq.ai_data(1:correctSamples, :);
    end
%     nidaq.ai_data = [nidaq.ai_data;event.Data]; % alex's code, continuous
%     acquisition
end      
