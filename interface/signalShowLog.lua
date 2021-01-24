-- scriptTest.lua (in your scripts directory)
local M = {}
local init = {}
local arrTableLog = {}

local showLabel = false;
local showLabelPrice = true;


local words = dofile(getScriptPath() .. "\\langs\\words.lua");
local loger = dofile(getScriptPath() .. "\\modules\\loger.lua");
local label = dofile(getScriptPath() .. "\\modules\\drawLabel.lua");

local createTableLog = false;
local wordTitleTableLog = {
    ['number'] = "N",
    ['time'] = "Time",
    ['event'] = "Event",
    ['status'] = "Status",
    ['price'] = "Price",
    ['description'] = "Description",
    ['log_signal'] = 'Log signals'
};

local function setLabelTableLog(_arr) if createTableLog == false then return; end end

--- simple create a table
local function CreateNewTableLogEvent()
    --	if createTableLog  then return; end;
    createTableLog = true;

    t_id_TableLog = AllocTable();

    AddColumn(t_id_TableLog, 0, wordTitleTableLog.number, true,
              QTABLE_STRING_TYPE, 5);
    AddColumn(t_id_TableLog, 1, wordTitleTableLog.time, true,
              QTABLE_STRING_TYPE, 10);
    AddColumn(t_id_TableLog, 2, wordTitleTableLog.event, true,
              QTABLE_STRING_TYPE, 5);
    AddColumn(t_id_TableLog, 3, wordTitleTableLog.price, true,
              QTABLE_STRING_TYPE, 10);
    AddColumn(t_id_TableLog, 4, wordTitleTableLog.description, true,
              QTABLE_STRING_TYPE, 60);

    t = CreateWindow(t_id_TableLog);
    SetWindowCaption(t_id_TableLog, wordTitleTableLog.log_signal);

    SetWindowPos(t_id_TableLog, 0, 150, 520, 640);

    for i = 1, 35 do InsertRow(t_id_TableLog, -1); end
    for i = 0, 3 do
        Blue(4, i);
        Blue(8, i);
        Gray(10, i);
        Gray(12, i);
        Gray(14, i);
        Gray(16, i);
        Gray(18, i);
    end

end



local function updateLogSignal(_arr)
    if #arrTableLog == 0 then return; end

    itter = 1
    if #arrTableLog > 35 then itter = #arrTableLog - 35 end

    -- в режиме эмуляции больше не рисуем на графике
    if setting.emulation then

        if (showLabel) then
            if (_arr.status) then
                label.set(setting,'green', _arr.price, _arr.dt, 1, _arr.description);
            else
                label.set(setting,'red', _arr.price, _arr.dt, 1, _arr.description);
            end
        end

        if (_arr.event == 21) then
       --     label.set(setting,'SELL', _arr.price, _arr.dt, 1, 'sell contract ' .. 1);
        end
        if (_arr.event == 24) then
        --    label.set(setting,"BUY", _arr.price, _arr.dt, 0);
        end

        if (_arr.event == 8) then
         --   label.set(setting,'sell', _arr.price, _arr.dt, 1, _arr.description);
        end

        if (_arr.event == 22) then
         --   label.set(setting,'red', _arr.price, _arr.dt, 1, _arr.description);
        end

        if (showLabelPrice) then

            if (_arr.event == 1) then
             --   label.set(setting,'red', _arr.price, _arr.dt, 1, _arr.description);
            end
        end
    end

    for i = #arrTableLog + 1, itter, -1 do

        if i > 0 then keys = (#arrTableLog - i); end

        --	for key in arrTableLog do
        if (keys > 0) then
            if arrTableLog[i].status then
                White(t_id_TableLog, keys, 0);
                White(t_id_TableLog, keys, 1);
                White(t_id_TableLog, keys, 2);
                White(t_id_TableLog, keys, 3);
                White(t_id_TableLog, keys, 4);
            else
                White(t_id_TableLog, keys, 0);
                White(t_id_TableLog, keys, 1);
                White(t_id_TableLog, keys, 2);
                White(t_id_TableLog, keys, 3);
                White(t_id_TableLog, keys, 4);
            end

            if arrTableLog[i].event == 9 or arrTableLog[i].event == 20 then

                Green(t_id_TableLog, keys, 0);
                Green(t_id_TableLog, keys, 1);
                Green(t_id_TableLog, keys, 2);
                Green(t_id_TableLog, keys, 3);
                Green(t_id_TableLog, keys, 4);
            end

            if arrTableLog[i].event == 26 or arrTableLog[i].event == 27 then

                Green(t_id_TableLog, keys, 0);
                Green(t_id_TableLog, keys, 1);
                Green(t_id_TableLog, keys, 2);
                Green(t_id_TableLog, keys, 3);
                Green(t_id_TableLog, keys, 4);
            end

            if arrTableLog[i].event == 8 then

                Green(t_id_TableLog, keys, 0);
                Green(t_id_TableLog, keys, 1);
                Green(t_id_TableLog, keys, 2);
                Green(t_id_TableLog, keys, 3);
                Green(t_id_TableLog, keys, 4);
            end

            SetCell(t_id_TableLog, keys, 0, tostring(arrTableLog[i].number));
            SetCell(t_id_TableLog, keys, 1, tostring(arrTableLog[i].dtime));
            SetCell(t_id_TableLog, keys, 2, tostring(arrTableLog[i].event));
            SetCell(t_id_TableLog, keys, 3, tostring(arrTableLog[i].price));
            SetCell(t_id_TableLog, keys, 4, tostring(arrTableLog[i].description));

        end

    end

    setLabelTableLog(_arr);
end


local function addSignal(event, status, number)
    -- CreateNewTableLogEvent();
    local datetime = setting.datetime;
    local time = '';
    local txt = ' event :' .. event;

    loger.saveSignal(txt);

    if (datetime == nul) then
    else
        loger.saveSignal('time time ');
        time = datetime.hour .. ':' .. datetime.min .. ':' .. datetime.sec;
    end

    local arr = {
        ['dt'] = datetime,
        ['dtime'] = time,
        ['event'] = event,
        ['status'] = status,
        ['price'] = number,
        ['description'] = words.wSignal(event),
        ['number'] = (#arrTableLog + 1)
    };

    arrTableLog[#arrTableLog + 1] = arr;
    updateLogSignal(arr);
    -- table.insert(arrTableLog, (#arrTableLog+1),arr);   
end
 
 
 
local function deleteTable(Line, Col) DestroyTable(t_id_TableLog) end

M.addSignal = addSignal;
M.stats = stats;
M.deleteTable = deleteTable;
M.CreateNewTableLogEvent = CreateNewTableLogEvent;
M.show = show;

return M
