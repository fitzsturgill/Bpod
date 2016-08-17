function phDemodOnline(currentTrial)
    global BpodSystem nidaq

    decimationFactor = nidaq.online.decimationFactor;
    lowCutoff = 15;
    LED1_f = nidaq.LED1_f;
    LED2_f = nidaq.LED2_f;
    
    if nidaq.LED1_amp > 0
        nidaq.online.currentDemodData{1} = phDemod(nidaq.ai_data(:,1), nidaq.ao_data(:,1), nidaq.sample_rate, LED1_f, lowCutoff);
    else
        nidaq.online.currentDemodData{1} = NaN(size(nidaq.ai_data(:,1)));
    end
    if nidaq.LED2_amp > 0    
        nidaq.online.currentDemodData{2} = phDemod(nidaq.ai_data(:,2), nidaq.ao_data(:,2), nidaq.sample_rate, LED2_f, lowCutoff);    
    else
        nidaq.online.currentDemodData{2} = NaN(size(nidaq.ai_data(:,2)));
    end
    %% generate x data, scale from 0 initially (you can add/subtract offsets to x data within downstream funtions)
    dT = 1/nidaq.sample_rate;
    nidaq.online.currentXData = 0:dT:nidaq.duration - dT;
    nidaq.online.currentXData = nidaq.online.currentXData'; % make column vector

    %% downsample and save trial data
    nidaq.online.trialXData = decimate(nidaq.online.currentXData, decimationFactor);
    nidaq.online.trialDemodData{currentTrial, 1} = decimate(nidaq.online.currentDemodData{1}, decimationFactor);
    nidaq.online.trialDemodData{currentTrial, 2} = decimate(nidaq.online.currentDemodData{2}, decimationFactor);    

%     %% pad or truncate if acquisition stopped short or long, but as of 8/15/16 this functionality is redundant- see processNidaqData
%     samplesShort = length(xData) - length(demod_ch1);
%     if samplesShort > 0 % i.e. not 0
%         demod_ch1 = [demod_ch1; NaN(samplesShort, 1)];
%         demod_ch2 = [demod_ch2; NaN(samplesShort, 1)];        
%     elseif samplesShort < 0
%         demod_ch1 = demod_ch1(1:length(xData));
%         demod_ch2 = demod_ch2(1:length(xData));
%     end    