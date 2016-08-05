function NidaqData=Online_NidaqEvents(thisTrial,StateToZero,Duration)
global BpodSystem

%Parameters
SampRate=2000;     %Hz
DecimateFactor=1;
Length=Duration*SampRate;
SampRate=SampRate/DecimateFactor; %Hz

%Data processing
Data=decimate(BpodSystem.Data.NidaqData{thisTrial}(1:Length,1),DecimateFactor);
Fbaseline=mean(Data(0.1*SampRate:1.1*SampRate));
DFF=(Data-Fbaseline)./Data;

%Time
DataSize=size(Data,1);
Time=linspace(0,Duration,DataSize);
TimeToZero=BpodSystem.Data.RawEvents.Trial{1,thisTrial}.States.(StateToZero)(1,1);
Time=Time'-TimeToZero;

%NewDataSet
NidaqData(:,1)=Time;
NidaqData(:,2)=Data;
NidaqData(:,3)=DFF;

end