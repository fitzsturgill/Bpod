function updatePhotometryPlot
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
    plot(BpodSystem.ProtocolFigures.NIDAQPanel1,(0:length(demod_ch1)-1)/nidaq.sample_rate,demod_ch1);
    plot(BpodSystem.ProtocolFigures.NIDAQPanel2,(0:length(demod_ch2)-1)/nidaq.sample_rate,demod_ch2);
    
    zoomFactor = 5; % scale y axis +/- zoomFactor standard deviations from the mean
    ylabel(BpodSystem.ProtocolFigures.NIDAQPanel1,{'Ch1'});
    m1 = mean(demod_ch1);
    s1 = std(demod_ch1);
    set(BpodSystem.ProtocolFigures.NIDAQPanel1, 'YLim', [m1 - x1*zoomFactor, m1 + s1*zoomFactor]);
    ylabel(BpodSystem.ProtocolFigures.NIDAQPanel2,{'Ch2'})
    m2 = mean(demod_ch2);
    s2 = std(demod_ch2);    
    set(BpodSystem.ProtocolFigures.NIDAQPanel2, 'YLim', [m2 - x2*zoomFactor, m2 + s2*zoomFactor]);
    drawnow;
%     legend(nidaq.ai_channels,'Location','East')