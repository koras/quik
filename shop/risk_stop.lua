local loger = dofile(getScriptPath() .. "\\modules\\loger.lua");
local label = dofile(getScriptPath() .. "\\modules\\drawLabel.lua");
local transaction = dofile(getScriptPath() .. "\\shop\\transaction.lua");
local signalShowLog =
    dofile(getScriptPath() .. "\\interface\\signalShowLog.lua");
local panelBids = dofile(getScriptPath() .. "\\interface\\bids.lua");

-- local controlPanel = dofile(getScriptPath() .. "\\interface\\control.lua");

-- local markets = dofile(getScriptPath() .. "\\shop\\market.lua");

local usestop = true;

-- класс для работы с стопами, риск-менеджмент
-- Главное не сколько заработаешь, а сколько не потеряешь

-- стопы обновляются только при покупке или продаже контракта
-- при срабатывании стопа, должны убираться контракты которые находятся на самом вверху
-- и закрываться позиции по покупке. Более такие позиции не учитываются в логике
local function update_stop(setting)

    if usestop == false then return; end

    if setting.current_price <= setting.array_stop.price then
        setting.update = false;
    end

    -- можно ли использовать стопы
    if setting.use_stop and setting.update then
        -- получаем заявки для ордеров
        -- определяем максимальную и минимальную цену покупки
        getOrdersForBid();
        -- снимаем старые стопы если таковые имеются
        backStop();
        -- генерируем объёкт из стоп заявок
        -- и ставим стоп
        generationCollectionStop();
    end
end

-- расчёт максимального расстояния в зависимости от количества используемых контрактов при старте
local function calculateMaxStopStart(setting)
    if usestop == false then return; end
    -- зависимость контрактов
    setting.spred = setting.spred_default;
    --  settingData.spred = setting.LIMIT_BID / setting.use_contract * setting.profit_range ;
    --  settingData.spred = setting.LIMIT_BID * setting.SPRED_LONG_TREND_DOWN / setting.use_contract  + settingData.spred + settingData.spred_range ;
end

local function setStopDefault(setting)
    if usestop == false then return; end

    setting.price_min = 10000000;
    setting.spred = setting.spred_default;
    --  settingData.spred_range = 0.1;
    setting.contract_work = 0;
end

-- расчёт цены для следующего стоп заявки
local  function getMaxPriceRange(countStop)

    if settingData.price_max <= 0 then
        settingData.price_max = setting.current_price;
    end

    -- расчёт максимального отступа от максимальной цены
    local mPrice = settingData.price_max - settingData.spred;
    -- if countStop > 1 then
    --     -- для второго стопа

    --     mPrice  = mPrice  -  countStop * settingData.spred_range + settingData.spred_range;  

    -- end

    return mPrice;
end

-- ситуация когда срабатывали стопы, и сейчас стопов больше чем контрактов

-- функция сбора заявок для стопов
-- определяем максимальную и минимальную цену покупки
-- необходимо для определения куда ставить стоп
local function getOrdersForBid()
    if #setting.sellTable == 0 then return; end

    loger.save('ettingData.contract_work =' .. settingData.contract_work);
    settingData.contract_work = 0;
    for contractStop = 1, #setting.sellTable do
        -- берём все заявки которые куплены

        if setting.sellTable[contractStop].type == 'buy' and
            setting.sellTable[contractStop].work then

            -- если стоп сработал хотя бы раз, то больше максимальную цену не обновляем
            if setting.sellTable[contractStop].price > settingData.price_max then
                -- максимальная цена покупки
                settingData.price_max = setting.sellTable[contractStop].price;

            end
            if setting.sellTable[contractStop].price < settingData.price_min then
                -- минимальная цена покупки
                settingData.price_min = setting.sellTable[contractStop].price;
            end
        end

        if setting.sellTable[contractStop].type == 'sell' and
            setting.sellTable[contractStop].work then

            settingData.contract_work = settingData.contract_work +
                                          setting.sellTable[contractStop]
                                              .use_contract;
            loger.save(
                '-- смотрим сколько осталось контрактов  ' ..
                    settingData.contract_work);

        end
    end

    if settingData.contract_work == 0 then
        loger.save('-- нет контрактов в работе ');
    end
end

-- сколько стопов уже

-- Ставим новый стоп, увеличиваем стоп на количество срабатываемых стопов и уменьшаем количество стопов
local function generationCollectionStop()

    local contract_work = settingData.contract_work + settingData.contract_add;
    loger.save(
        "Ставим новый стоп generationCollectionStop contract_work = " ..
            tostring(contract_work));

    if contract_work > 0 then
        -- смотрим куда поставить стоп
        maxPrice = getMaxPriceRange()
        -- loger.save('generationCollectionStop  ставм стоп   контрактов = '.. contract_work.." по цене : "..maxPrice )
        sendTransStop(contract_work, maxPrice);
    end
end

-- снимаем старые стоп заявки
local function backStop()
    -- обнуляем заявки

    loger.save(" ");
    loger.save(
        "backStop  trans_id " .. tostring(ettingData.array_stop.trans_id) ..
            "   order_num = " .. tostring(ettingData.array_stop.order_num));

    if settingData.array_stop.emulation then
        -- удаляем метку

        settingData.array_stop.work = 0;
        settingData.array_stop.trans_id = 0;
        settingData.array_stop.order_num = 0;
        settingData.array_stop.stop_number = 0;
        DelLabel(setting.tag, settingData.array_stop.label);
    else
        -- только 2, потому что только 2 заявкам присвоен  номер

        if settingData.array_stop.work == 2 and settingData.array_stop.stop_number ~=
            0 and settingData.array_stop.trans_id ~= 0 or
            settingData.array_stop.work == 1 and settingData.array_stop.stop_number ~=
            0 and settingData.array_stop.trans_id ~= 0 then
            -- стоп больше не используется 
            local stop_number = tostring(ettingData.array_stop.stop_number);
            local order_num = tostring(ettingData.array_stop.order_num);
            local trans_id = tostring(ettingData.array_stop.trans_id);
            local order_type = tostring(ettingData.array_stop.order_type);

            loger.save("backStop 2 -- trans_id " ..
                           tostring(ettingData.array_stop.trans_id ..
                                        " stop_number " .. stop_number));

            transaction.delete(trans_id, stop_number, order_type);

            settingData.array_stop.work = 0;
            settingData.array_stop.trans_id = 0;
            settingData.array_stop.order_num = 0;
            settingData.array_stop.stop_number = 0;

        end
    end

end

-- создаём объёкт 
-- countContract - сколько контрактов на стопе
-- countPrice - стоимость контракта

local function sendTransStop(countContract, countPrice)
     
 

    if usestop == false then return; end

    settingData.array_stop.order_type = "SIMPLE_STOP_ORDER";
    settingData.array_stop.trans_id = getRand();

    loger.save("sendTransStop: order_num=" .. settingData.array_stop.order_num ..
                   " trans_id =  " .. settingData.array_stop.trans_id)

    if settingData.array_stop.work == 3 and settingData.array_stop.trans_id == 0 and
        settingData.array_stop.order_num == 0 or settingData.array_stop.work == 0 and
        settingData.array_stop.trans_id == 0 and settingData.array_stop.order_num ==
        0 then

        local dataParam = {};
        settingData.array_stop.emulation = setting.emulation;
        settingData.array_stop.price = countPrice;
        settingData.array_stop.contract = countContract;

        settingData.array_stop.label = 0;
        -- work = 0 - отправляем на сервер
        -- work = 1 - заявка выставлена
        -- work = 2 - заявка снята пл какой либо причине
        -- work = 3 - заявка снята пл какой либо причине
        settingData.array_stop.work = 1;
        settingData.array_stop.order_num = 0;

        if setting.emulation then

            -- рисуем стоп
            settingData.array_stop.work = 1;
            settingData.array_stop.order_type = 1;
            settingData.array_stop.order_type = "SIMPLE_STOP_ORDER";
            settingData.array_stop.trans_id = getRand();
            settingData.array_stop.label =
                label.set(setting, 'stop', countPrice, setting.datetime, countContract,
                          'stop ' .. countContract)
            loger.save("dataParam.label =" .. settingData.array_stop.label)

        else
            -- здесь статус меняется полсле того как пришёл статус об установке стопа 
            -- dataParam.work = 0; 

            local type = "SIMPLE_STOP_ORDER";

            local direction = 4;
            settingData.array_stop.trans_id =
                transaction.sendStop('Sell', countPrice, countContract,
                                     direction);
            -- settingData.array_stop.trans_id = transaction.send('sell', countPrice, countContract, type, 0 );

            loger.save("sendTransStop   ставим стоп " .. countPrice ..
                           '  trans_id=' .. settingData.array_stop.trans_id)
            -- отправляем транкзакцию 
        end
    end
end

-- обновление заявки по которой пришла информация
-- присваиваем номер заявке, если он отсутствует
-- вызывается в OnStopOrder

local function updateOrderNumber(order)

    if order.trans_id == settingData.array_stop.trans_id and
        settingData.array_stop.work == 1 then

        settingData.array_stop.work = 2;
        settingData.array_stop.order_num = order.order_num;
    end
end

-- обновление номера стопа 
-- это надо для удаления стопа

local function updateStopNumber(order)

    loger.save("updateOrderNumber 1 order_num=" .. order.order_num ..
                   " trans_id=" .. settingData.array_stop.trans_id)
    if order.trans_id == settingData.array_stop.trans_id and
        settingData.array_stop.order_num == 0 and settingData.array_stop.work == 1 then
        loger.save("updateOrderNumber 2  order_num=" .. order.order_num ..
                       " trans_id=" .. settingData.array_stop.trans_id)
        settingData.array_stop.stop_number = order.order_num;
    end
end

local function getRand() return tostring(math.random(2000000000)); end

-- сработал стоп (OnStopOrder)
-- необходимо снять старые заявки на продажу, если есть таковые
-- когда срабатывает стоп, передвижение стопов запрещено
local function appruveOrderStop(order)

    -- помечаем заявку как исполненной
    if settingData.use_stop and setting.emulation == false then

        loger.save("STOP STOP STOP STOP  trans_id = " ..
                       settingData.array_stop.trans_id .. " = " .. order.trans_id)
        loger.save("STOP STOP STOP STOP  order_num = " ..
                       settingData.array_stop.order_num .. " = " ..
                       order.order_num)

        --  режим торговли  
        if order.trans_id == settingData.array_stop.trans_id and order.order_num ==
            settingData.array_stop.order_num and settingData.array_stop.work == 2 then

            -- признак срабатывания стопа
            loger.save(
                "-- appruveOrderStop  признак срабатывания стопа ")

            settingData.array_stop.work = 0;
            settingData.array_stop.trans_id = 0;
            settingData.update = false;
            removeOldOrderSell();
            button_worked_stop();
            -- обновляем таблицу с заявками 
            panelBids.show(setting);
        end

    end
end

-- снимаем старые контракты которые продаём выше.
-- контракты расположены в самом вверху. Снимаем в зависимости от количества контрактов
-- перебираем старые заявки, сверху вних по цене.
-- подсчитываем 
local function removeOldOrderSell()
    if usestop == false then return; end

    local arrayOrders = {};
    -- коллекция транкзакция на покупку контрактов, для поиска, чтоб не учитывать в будущем
    local arrayOrdersBuys = {};

    if #setting.sellTable > 0 then
        for i = 1, #setting.sellTable do
            if setting.sellTable[i].type == "sell" and setting.sellTable[i].work then

                -- удаляем контракт  
                setting.sellTable[i].work = false;
                signalShowLog.addSignal(34, false,
                                        setting.sellTable[i].price);
                loger.save(
                    " помечаем заявку как неактивную sell," ..
                        setting.sellTable[i].contract);

                arrayOrdersBuys[#arrayOrdersBuys + 1] =
                    setting.sellTable[i].trans_id_buy;
                transaction.delete(setting.sellTable[i].trans_id,
                                   setting.sellTable[i].order_num,
                                   tostring(setting.sellTable[i].order_type));
            end
        end

        -- здесь делаем не рабочие заявки на продажу, диактивируя их
        if #arrayOrdersBuys > 0 then
            -- перебираем все заявки
            for o = 1, #setting.sellTable do
                -- находим только покупки
                if setting.sellTable[o].type == "buy" and
                    setting.sellTable[o].work then
                    for i = 1, #arrayOrdersBuys do
                        -- setting.sellTable[sellT].trans_id == saleContract.trans_id_buy 
                        if setting.sellTable[o].trans_id == arrayOrdersBuys[i] then
                            setting.sellTable[o].work = false;
                            loger.save(
                                " помечаем заявку как неактивную buy," ..
                                    setting.sellTable[o].price);
                        end
                    end
                end
            end
        end
    end
    panelBids.show(setting);
end

local function appruveOrderStopEmulation(order)

    if settingData.use_stop and setting.emulation and settingData.array_stop.price ~=
        nil then
        -- помечаем заявку как исполненной

        -- в режиме эмуляции сработал стоп, здесь смотрим цену
        if order.close <= settingData.array_stop.price and
            settingData.array_stop.work == 1 or order.close <=
            settingData.array_stop.price and settingData.array_stop.work == 2 then

            settingData.array_stop.work = 3;
            signalShowLog.addSignal(31, false,
                                    settingData.array_stop.price);

            -- снимаем стоп
            DelLabel(setting.tag, settingData.array_stop.label);
            button_worked_stop();

            loger.save(
                "-- appruveOrderStopEmulation признак срабатывания стопа ")
            -- признак срабатывания стопа

            removeOldOrderSell();
            panelBids.show(setting);
        end
    end
end

local R = {}

R.updateStopNumber = updateStopNumber;
R.calculateMaxStopStart = calculateMaxStopStart;
R.removeOldOrderSell = removeOldOrderSell;
R.backStop = backStop;
R.appruveOrderStopEmulation = appruveOrderStopEmulation;
R.appruveOrderStop = appruveOrderStop;
R.updateOrderNumber = updateOrderNumber;
--R.transCallback = transCallback;
R.update_stop = update_stop;

return R
