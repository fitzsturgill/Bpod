function processNidaqData(src,event)
    % Save trial data to the global nidaqTrailData variable.
    % Also, plot the data as it comes in.
    global nidaq
    nidaq.ai_data = [nidaq.ai_data;event.Data]; 
end      
