function updatePhotometryPlot(startX)
% startX: time point in seconds from beginning of photometry
% acquisition to be defined as 0
    if nargin < 1
        startX = 0;
    end
    global BpodSystem nidaq
    xData = nidaq.online.currentXData - startX;
    
    demod_ch1 = nidaq.online.currentDemodData{1};
    demod_ch2 = nidaq.online.currentDemodData{2};
    plot(BpodSystem.ProtocolFigures.NIDAQPanel1,xData, demod_ch1);
    plot(BpodSystem.ProtocolFigures.NIDAQPanel2,xData, demod_ch2);
    
    zoomFactor = 5; % scale y axis +/- zoomFactor standard deviations from the mean

    ylabel(BpodSystem.ProtocolFigures.NIDAQPanel1,{'Ch1'});
    if nidaq.LED1_amp > 0
        m1 = mean(demod_ch1);
        s1 = std(demod_ch1);
        set(BpodSystem.ProtocolFigures.NIDAQPanel1, 'YLim', [m1 - s1*zoomFactor, m1 + s1*zoomFactor]);
    end
    ylabel(BpodSystem.ProtocolFigures.NIDAQPanel2,{'Ch2'})
    if nidaq.LED2_amp > 0    
        m2 = mean(demod_ch2);
        s2 = std(demod_ch2);    
        set(BpodSystem.ProtocolFigures.NIDAQPanel2, 'YLim', [m2 - s2*zoomFactor, m2 + s2*zoomFactor]);
    end
    drawnow;
%     legend(nidaq.ai_channels,'Location','East')