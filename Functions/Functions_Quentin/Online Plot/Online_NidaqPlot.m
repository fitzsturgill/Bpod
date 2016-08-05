function figData=Online_NidaqPlot(action,subPlotTitles,Phase,figData,newData,curTrialType)
global BpodSystem
%% general ploting parameters
labelx='Time (sec)'; labely='DF/F'; 
minx=-4; maxx=4;  xstep=1;    xtickvalues=minx:xstep:maxx;
miny=-0.005; maxy=0.01;
MeanThickness=2;

switch action
    case 'ini'
%% Close pre-existing plot and test parameters
try
    close 'Online Nidaq Plot';
end
%% Create Figure
figPlot=figure('Name','Online Nidaq Plot','Position', [100 400 600 700], 'numbertitle','off');
hold on
ProtoSummary=sprintf('%s : %s -- %s - %s',...
    date, BpodSystem.GUIData.SubjectName, ...
    BpodSystem.GUIData.ProtocolName, Phase);
ProtoLegend=uicontrol('style','text');
set(ProtoLegend,'String',ProtoSummary); 
set(ProtoLegend,'Position',[10,1,400,20]);

%% Current Nidaq plot
lastsubplot=subplot(4,2,[1 2]);
hold on
title('Last Nidaq recording');
xlabel(labelx); ylabel(labely);
ylim auto;
set(lastsubplot,'XLim',[minx maxx],'XTick',xtickvalues,'YLim',[miny maxy]);
rewplot=plot([0 0],[-1,1],'-b');
lastplot=plot([-5 5],[0 0],'-k');
hold off

%% Plot previous recordings
for i=1:6
    photosubplot(i)=subplot(4,2,i+2);
    hold on
    title(subPlotTitles(i));
    xlabel(labelx); ylabel(labely);
    ylim auto;
    set(photosubplot(i),'XLim',[minx maxx],'XTick',xtickvalues,'YLim',[miny maxy]);
    rewplot(i)=plot([0 0],[-1,1],'-b');
    meanplot(i)=plot([-5 5],[0 0],'-r');
    hold off
end

set(photosubplot(1),'XLabel',[]);
set(photosubplot(2),'XLabel',[],'YLabel',[]);
set(photosubplot(3),'XLabel',[]);
set(photosubplot(4),'XLabel',[],'YLabel',[])
%set(photosubplot(5),'XLabel',labelx,'YLabel',labely);
set(photosubplot(6),'YLabel',[]);

%Save the figure properties
figData.fig=figPlot;
figData.lastsubplot=lastsubplot;
figData.lastplot=lastplot;
figData.photosubplot=photosubplot;
figData.meanplot=meanplot;

    case 'update'
%% Compute new average trace
allData=get(figData.photosubplot(curTrialType), 'UserData');
dataSize=size(allData,2);
allData(:,dataSize+1)=newData(:,3);
set(figData.photosubplot(curTrialType), 'UserData', allData);
meanData=mean(allData,2);

%% Update plot
set(figData.lastplot, 'Xdata',newData(:,1),'YData',newData(:,3));
curSubplot=figData.photosubplot(curTrialType);
set(figData.meanplot(curTrialType), 'Xdata',newData(:,1),'YData',meanData,'LineWidth',MeanThickness);
set(curSubplot,'NextPlot','add');
plot(newData(:,1),newData(:,3),'-k','parent',curSubplot);
uistack(figData.meanplot(curTrialType), 'top');
hold off
end
end