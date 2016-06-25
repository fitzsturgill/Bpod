function slaveResponse = updateValveSlave(so, valve)
% update command valve to be used by slave arduino (0 for omission)
    fwrite(so, valve);
    pause(0.05);
    try
        slaveResponse = fread(so);
    catch
        slaveReponse = [];
    end