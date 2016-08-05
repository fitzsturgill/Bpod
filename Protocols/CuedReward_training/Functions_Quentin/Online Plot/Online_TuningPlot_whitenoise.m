function figData=Online_TuningPlot_whitenoise(action,S,TrialSequence,figData,Nidaq,thistrial)

global BpodSystem

%% General Parameters
plotSpan=20.5;
minxPhoto=-1; maxxPhoto=1.5;
minyPhoto=-0.05; maxyPhoto=0.05;
baseline=[-1.1 -0.1];
soundresponse=[0 0.5];

Freq=S.MeanFrequencies;
NbOfFreq=S.NbOfFreq;
NbOfTrials=size(TrialSequence,1);
FreqSequence=zeros(NbOfTrials,1);
for i=1:NbOfTrials
    FreqSequence(i)=Freq(TrialSequence(i));
end

switch action
    case 'ini'
try
     close 'Auditory Tuning Curve';
end         
%% Data initialization
figData.X1=1:1:NbOfTrials;
figData.Y1=FreqSequence;
figData.X2=[minxPhoto maxxPhoto]; 
figData.Y2=[0 0];
for i=1:NbOfFreq
    thisFreq=sprintf('freq_%.f',Freq(i));
    figData.Title3{i}=sprintf('%.fHz',Freq(i));
    figData.(thisFreq).X3=[minxPhoto maxxPhoto];
    figData.(thisFreq).Y3=[0 0];
    figData.(thisFreq).Nidaq=[];
end
figData.X4=1:1:NbOfTrials; 
figData.Y4=ones(NbOfTrials,1);
figData.X5=Freq; 
figData.Y5=zeros(NbOfFreq,1);


%% Figure
figData.figPlot=figure('Name','Auditory Tuning Curve','Position', [800 400 600 700], 'numbertitle','off');
hold on;
ProtoSummary=sprintf('%s : %s -- %s - %s',...
    date, BpodSystem.GUIData.SubjectName, ...
    BpodSystem.GUIData.ProtocolName);
MyBox = uicontrol('style','text');
set(MyBox,'String',ProtoSummary, 'Position',[10,1,400,20])

%% Subplots
figData.Subplot(1)=subplot(3,3,[1 3],'XLim',[5-plotSpan plotSpan]); hold on;
title('Trials sequence'); xlabel('Trials'); ylabel('Trial Type');
figData.Plot(1)=plot(figData.X1,figData.Y1,'ko');
figData.CurTrialPlot=plot([1 1],[min(Freq) max(Freq)],'-r');

figData.Subplot(2)=subplot(3,3,4,'XLim',[minxPhoto maxxPhoto],'YLim',[minyPhoto maxyPhoto]); hold on;
title('Last Photometry'); xlabel('Time (sec)'); ylabel('DF/F');
figData.Plot(2)=plot(figData.X2,figData.Y2,'-b');

figData.Subplot(3)=subplot(3,3,[5 6],'XLim',[minxPhoto maxxPhoto],'YLim',[minyPhoto maxyPhoto]); hold on;
title('Average Photometry'); xlabel('Time (sec)'); ylabel('DF/F');
for i=1:NbOfFreq
    thisFreq=sprintf('freq_%.f',Freq(i));
    figData.(thisFreq).Plot3=plot(figData.(thisFreq).X3,figData.(thisFreq).Y3);
end
legend(figData.Title3);

figData.Subplot(4)=subplot(3,3,7); hold on;
title('Bleach'); xlabel('Trials'); ylabel('DF/F');
figData.Plot(4)=plot(figData.X4,figData.Y4,'go');

figData.subplot(5)=subplot(3,3,[8 9]); hold on;
title('Overall'); xlabel('Trial Type'); ylabel('DF/F');
figData.Plot(5)=plot(figData.X5,figData.Y5,'sb');

case 'update'
%% Update data
    curFreq=FreqSequence(thistrial);
    curType=TrialSequence(thistrial);
    Time=Nidaq(:,1);
    NidaqRaw=Nidaq(:,2);
    NidaqDFF=Nidaq(:,3);  
    thisFreq=sprintf('freq_%.f',curFreq); 
    figData.(thisFreq).Nidaq=[figData.(thisFreq).Nidaq NidaqDFF];
    figData.(thisFreq).X3=mean(figData.(thisFreq).Nidaq,2);  
    if thistrial==1
        figData.NidaqBaseline=mean(NidaqRaw(Time>baseline(1) & Time<baseline(2)));
    end
    figData.Y4(thistrial)=mean(NidaqRaw(Time>baseline(1) & Time<baseline(2)))/figData.NidaqBaseline;
    figData.Y5(curType)=mean(figData.(thisFreq).X3(Time>soundresponse(1) & Time<soundresponse(2)));
    
%% Update plot
    set(figData.Subplot(1), 'XLim',[thistrial+5-plotSpan thistrial+plotSpan]);
    set(figData.CurTrialPlot,'Xdata', [thistrial+1 thistrial+1]);
    
    set(figData.Plot(2),'XData',Time,'YData',NidaqDFF)
    set(figData.(thisFreq).Plot3,'XData',Time,'YData',figData.(thisFreq).X3);
    set(figData.Plot(4),'YData',figData.Y4);
    set(figData.Plot(5),'YData',figData.Y5);
    
end
