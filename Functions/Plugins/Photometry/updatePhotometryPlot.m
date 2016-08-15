function [demod_ch1, demod_ch2] = updatePhotometryPlot(startX)
    if nargin < 1
        startX = 0;
    end
    global BpodSystem nidaq
    lowCutoff = 15;
    
    LED1_f = nidaq.LED1_f;
    LED2_f = nidaq.LED2_f;
    
    if nidaq.LED1_amp > 0
        demod_ch1 = phDemod(nidaq.ai_data(:,1), nidaq.ao_data(:,1), nidaq.sample_rate, LED1_f, lowCutoff);
    else
        demod_ch1 = nidaq.ai_data(:,1);
    end
    if nidaq.LED2_amp > 0    
        demod_ch2 = phDemod(nidaq.ai_data(:,2), nidaq.ao_data(:,2), nidaq.sample_rate, LED2_f, lowCutoff);    
    else
        demod_ch2 = nidaq.ai_data(:,2);
    end
    
    xData = startX:1/nidaq.sample_rate:startX + 1/nidaq.sample_rate * (nidaq.duration * nidaq.sample_rate - 1); % begin at startX, spacing = 1/nidaq.sample_rate
    xData = xData';
    %% pad if acquisition stopped short
    samplesShort = length(xData) - length(demod_ch1);
    if samplesShort > 0 % i.e. not 0
        demod_ch1 = [demod_ch1; NaN(samplesShort, 1)];
        demod_ch2 = [demod_ch2; NaN(samplesShort, 1)];        
    elseif samplesShort < 0
        demod_ch1 = demod_ch1(1:length(xData));
        demod_ch2 = demod_ch2(1:length(xData));
    end
    plot(BpodSystem.ProtocolFigures.NIDAQPanel1,xData, demod_ch1);
    plot(BpodSystem.ProtocolFigures.NIDAQPanel2,xData,demod_ch2);
    
    zoomFactor = 5; % scale y axis +/- zoomFactor standard deviations from the mean
    ylabel(BpodSystem.ProtocolFigures.NIDAQPanel1,{'Ch1'});
    m1 = mean(demod_ch1);
    s1 = std(demod_ch1);
    set(BpodSystem.ProtocolFigures.NIDAQPanel1, 'YLim', [m1 - s1*zoomFactor, m1 + s1*zoomFactor]);
    ylabel(BpodSystem.ProtocolFigures.NIDAQPanel2,{'Ch2'})
    m2 = mean(demod_ch2);
    s2 = std(demod_ch2);    
    set(BpodSystem.ProtocolFigures.NIDAQPanel2, 'YLim', [m2 - s2*zoomFactor, m2 + s2*zoomFactor]);
    drawnow;
%     legend(nidaq.ai_channels,'Location','East')