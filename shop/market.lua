-- ЗДесь принимается решение о покупке или продаже в зависимости от текущего состояния счёта
-- https://open-broker.ru/pricing-plans/universal/
-- 751,97 ₽
-- 7,5  = 0.01
local loger = dofile(getScriptPath() .. "\\modules\\loger.lua");
local label = dofile(getScriptPath() .. "\\modules\\drawLabel.lua");
local transaction = dofile(getScriptPath() .. "\\shop\\transaction.lua");
local signalShowLog =
    dofile(getScriptPath() .. "\\interface\\signalShowLog.lua");
-- local statsPanel = dofile(getScriptPath() .. "\\interface\\stats.lua");
local panelBids = dofile(getScriptPath() .. "\\interface\\bids.lua");
-- local interfaceBids = dofile(getScriptPath() .. "\\interface\\bids.lua");
local contitionMarket = dofile(getScriptPath() .. "\\shop\\contition_shop.lua");
-- local deleteBids = dofile(getScriptPath() .. "\\shop\\deleteBids.lua");
local control = dofile(getScriptPath() .. "\\interface\\control.lua");
local risk_stop = dofile(getScriptPath() .. "\\shop\\risk_stop.lua");

-- сервис, общие математические операции
dofile(getScriptPath() .. "\\shop\\market_service.lua");
local market_gap = dofile(getScriptPath() .. "\\shop\\market_gap.lua");


 

-- SHORT  = FALSE
-- LONG = true

local DIRECT = 'LONG';

function getRand() return tostring(math.random(2000000000)); end

function setDirect(localDirect) DIRECT = localDirect; end

function setLitmitBid(setting) LIMIT = setting.LIMIT_BID; end
-- price текущая цена
-- levelLocal  сила сигнала
-- event -- продажа или покупка

local level = 1;

-- обновляем транкзакцию для того чтобы при тестировании не отправлялись заросы
function updateTransaction(_transaction) transaction = _transaction; end

-- исполнение покупки(продажи контракта) контракта
-- first operation
-- the market entry
-- done
function startContract(result)
    -- сперва находим контракт который купили и ставим статус что мы купили контракт
    if #setting.sellTable > 0 then
        for contract = 1, #setting.sellTable do
            -- loger.save(setting.sellTable[contract].type);  
            if setting.sellTable[contract].executed == false and
                    setting.sellTable[contract].trans_id == result.trans_id then

                    signalShowLog.addSignal(27, false, setting.sellTable[contract].price);
                    setting.sellTable[contract].executed = true;
                    -- выставляем на продажу контракт.
                    secondOperation(result, setting.sellTable[contract]);
                return;
            end
        end
    end
end

 
 



-- присваиваем номер заявке на продажу
-- обновляем номер заявки на стопах
-- done
function saleExecution(result)
    if #setting.sellTable > 0 then
        for contract = 1, #setting.sellTable do
            -- обновляем номер заявки
            if  setting.sellTable[contract].executed == false and setting.sellTable[contract].trans_id == result.trans_id then

                loger.save("saleExecution  order_num=" .. result.order_num .. " trans_id=" .. result.trans_id .. "  ");
                setting.sellTable[contract].order_num = result.order_num
                -- risk_stop.update_stop();
            end
        end
    end
end

 


-- -- done
-- function commonOperation(_price, datetime)

--     -- сколько подряд покупок было
--     -- не влияет на тип операции шорт или лонг
--     if setting.each_to_buy_step <= setting.each_to_buy_to_block then
--         setting.each_to_buy_step = setting.each_to_buy_step + 1;
--         -- увеличиваем число контрактов которые надо продать до разблокировки
--         setting.each_to_buy_to_block_contract =
--             setting.use_contract + setting.each_to_buy_to_block_contract
--     end

--     -- текущаая свеча
--     -- ставим заявку на с отклонением на 0.01

--     local price = 0;

--     if setting.type_instrument == 3 then
--         if setting.mode == 'buy' then
--             price = tonumber(_price + setting.profit_infelicity); -- и надо снять заявку если не отработал
--         else
--             price = tonumber(_price - setting.profit_infelicity); -- и надо снять заявку если не отработал
--         end
--     else
--         if setting.mode == 'buy' then
--             price = _price + setting.profit_infelicity; -- и надо снять заявку если не отработал
--         else
--             price = _price - setting.profit_infelicity; -- и надо снять заявку если не отработал
--         end
--     end

--     setting.candles_operation_last = setting.number_of_candles;
--     if setting.emulation then
--         signalShowLog.addSignal(20, false, tostring(price));
--     else
--         signalShowLog.addSignal(7, false, price);
--     end

--     setting.count_buy = setting.count_buy + 1;
--     setting.count_buyin_a_row = setting.count_buyin_a_row + 1; -- сколько раз подряд купили и не продали
--     setting.limit_count_buy = setting.limit_count_buy + setting.use_contract; -- отметка для лимита
--     return price;
-- end


-- third
-- исполнение тейка или лимита в профите
-- done
function takeExecutedContract(result)
    
    loger.save("-- исполнение продажи контракта ");
    -- сперва находим контракт который купили и ставим статус что мы купили контракт
    if #setting.sellTable > 0 then
        for contract = 1, #setting.sellTable do

            if  setting.sellTable[contract].executed == false and
                setting.sellTable[contract].trans_id == result.trans_id then

                -- статистика
                setting.count_sell = setting.count_sell + 1;
                -- count the number of used contracts
                setting.count_contract_sell = setting.count_contract_sell +  setting.sellTable[contract].use_contract;

                setting.sellTable[contract].executed = true;
                -- для учёта при выставлении заявки
                setting.sellTable[contract].work = false;
                setting.sellTable[contract].price_take = result.price;

                -- подсчёт профита, от фактической стоимости
                local sell = setting.sellTable[contract].use_contract *  result.price;
                local buy = setting.sellTable[contract].use_contract * setting.sellTable[contract].buy_contract;



                setting.profit = sell - buy + setting.profit;
 
                if setting.mode == 'buy' then
                    -- long
                    setting.profit = sell - buy + setting.profit;
                else
                    -- short
                    setting.profit = buy - sell + setting.profit;
                end

                executionContractFinish(setting.sellTable[contract]);

                signalShowLog.addSignal(26, false, result.price);
                deleteBuyCost(result, setting.sellTable[contract])
                control.use_contract_limit(setting);

                loger.save(
                    "takeExecutedContract продали контракт result.trans_id = " ..
                        result.trans_id .. " trans_id = " ..
                        setting.array_stop.trans_id .. " order_num = " ..
                        setting.array_stop.order_num);
            end
        end
    end
    loger.save("вызов update_stop 1 ");
    risk_stop.update_stop();
end

-- -- выставление заявки на покупку/продажу
-- -- вызывается для эмуляции и не только
-- -- solve
-- -- done
-- function callBUY(price, datetime)
--     -- генерация trans_id для эмуляции 
--     local trans_id = getRand()

--     local use_contract = getUseContract(price, setting)
--     setting.count_contract_buy = setting.count_contract_buy + use_contract;

--     price = commonOperation(price, datetime);
--     if setting.emulation == false then
--         trans_id = transaction.send(setting.mode, price, use_contract, type, 0);
--     end

--     local data = {};
--     data.price = price;
--     data.datetime = datetime;
--     data.trans_id = trans_id;
--     -- сколько контрактов исполнилось 
--     data.use_contract = use_contract;
--     data.trans_id_buy = trans_id;

--     data.work = true;
--     data.executed = false;
--     data.type = setting.mode;
--     data.emulation = setting.emulation;
--     data.contract = use_contract;
--     data.buy_contract = price; -- стоимость продажи

--     if setting.emulation then
--         if setting.mode == 'buy' then
--             -- long
--             label.set("BUY", price, data.datetime, use_contract);
--         else
--             -- short 
--             label.set("SELL", price, data.datetime, use_contract);
--         end
--     end

--     setting.sellTable[(#setting.sellTable + 1)] = data;
--     -- Выставили контракт на покупку
--     signalShowLog.addSignal(23, false, price);
--     panelBids.show();
--     control.use_contract_limit(setting);
-- end

-- -- второй этап регистрации события
-- -- если шорт, то здесь выставляем заявку на покупку, после продажи
-- -- лонг, выставляем заявку на продажу, если купили контракт
-- -- done
-- function secondOperation(order, contractBuy)

--     if contractBuy.use_contract == 0 then
--         loger.save("нет контрактов " .. contractBuy.use_contract);
--     end

--     loger.save("secondOperation");

--     local type = "TAKE_PROFIT_STOP_ORDER";
--     if setting.sell_take_or_limit == false then type = "NEW_ORDER"; end

--     local price = setting.profit_range + contractBuy.price;

--     for sell_use_contract = 1, contractBuy.use_contract do

--         local data = {};
--         data.number = 0

--         if setting.mode == 'buy' then
--             -- long 
--             data.type = 'sell'
--         else
--             -- short
--             data.type = 'buy'
--         end

--         data.datetime = order.datetime
--         data.order_type = type;
--         data.work = true;
--         data.executed = false; -- покупка исполнилась
--         data.emulation = setting.emulation;
--         data.contract = 1;
--         data.use_contract = 1;
--         data.buy_contract = contractBuy.price; -- стоимость продажи
--         data.trans_id_buy = contractBuy.trans_id_buy
--         loger.save("secondOperation 1");
--         signalShowLog.addSignal(23, false, price);

--         loger.save("secondOperation 3 " .. sell_use_contract);
--         data.price = price;
--         if setting.emulation then

--             data.trans_id = getRand();
--             signalShowLog.addSignal(22, false, price);

--             if setting.mode == 'buy' then
--                 label.set("redCircle", price, contractBuy.datetime, 1, "sell");
--             else
--                 label.set("greenCircle", price, contractBuy.datetime, 1, "buy");
--             end

--         else
--             data.order_num = order.order_num;

--             if setting.mode == 'buy' then
--                 data.trans_id = transaction.send("SELL", price, 1, type,
--                                                  order.order_num);
--             else
--                 data.trans_id = transaction.send("BUY", price, 1, type,
--                                                  order.order_num);
--             end
--             signalShowLog.addSignal(9, false, price);
--         end
--         loger.save("secondOperation 5 " .. sell_use_contract);
--         setting.sellTable[#setting.sellTable + 1] = data;
--         -- обязательно в конце цикла
--         price = price + setting.profit_range_array;
--     end

--     panelBids.show();
-- end

-- -- исполнение продажи контракта в режиме эмуляции
-- -- done
-- function callSELL_emulation(result)

--     --  local price_callSELL_emulation = result.close;

--     if #setting.sellTable > 0 then
--         for sellT = 1, #setting.sellTable do
--             if 
--          --   setting.sellTable[sellT].type == 'sell' and
--                 setting.sellTable[sellT].work and setting.sellTable[sellT].emulation and result.close >= setting.sellTable[sellT].price then

--                 setting.sellTable[sellT].work = false;

--                 executionContractFinish(setting.sellTable[sellT]);
--                 -- сколько продано контрактов за сессию (режим эмуляции)
--                 --   setting.emulation_count_contract_sell = setting.emulation_count_contract_sell + setting.sellTable[sellT].contract; 
--                 setting.count_contract_sell =  setting.count_contract_sell +  setting.sellTable[sellT].contract;
--                 setting.profit = setting.sellTable[sellT].price - setting.sellTable[sellT].buy_contract +  setting.profit;

--                 if setting.limit_count_buy >= setting.sellTable[sellT].contract then
--                     setting.limit_count_buy =
--                         setting.limit_count_buy -
--                             setting.sellTable[sellT].contract;
--                 end

--                 signalShowLog.addSignal(21, false, result.close);
--                 if setting.emulation then
--                     label.set('SELL', result.close, result.datetime, 1, 'sell contract ' .. 1);
--                 end
--                 -- надо удалить контракт по которому мы покупали 
--                 --   panelBids.show(); 
--                 control.use_contract_limit();
--                 deleteBuy_emulation(setting.sellTable[sellT]);
--                 risk_stop.update_stop();

--             end
--         end
--     end
-- end

-- здесь ищем контракт который мы купили / продали  ранее 
-- после продажи контракта надо его пометить, что мы больше не используем
-- режим эмуляции
-- no done
function deleteBuy_emulation(contract_sell)
    if #setting.sellTable > 0 then
        for contract_buy_tr = 1, #setting.sellTable do

            if contract_sell.trans_id_buy == setting.sellTable[contract_buy_tr].trans_id then
                setting.sellTable[contract_buy_tr].work = false;
                setting.sellTable[contract_buy_tr].use_contract = setting.sellTable[contract_buy_tr].contract - contract_sell.use_contract;
                panelBids.show(setting);
            end
        end
    end
end

function check_buy_status_block(contract)
    -- если кнопка покупки заблокирована автоматически по причине падение
    if setting.each_to_buy_status_block then

        setting.each_to_buy_to_block_contract =
            setting.each_to_buy_to_block_contract - contract.use_contract

        if 0 >= setting.each_to_buy_to_block_contract then

            -- разблокируем кнопку покупки, потому что всё продали что должны были
            setting.each_to_buy_status_block = false
            setting.each_to_buy_to_block_contract = 0;
            setting.each_to_buy_step = 0; -- сколько подряд раз уже купили 
            control.buy_process();
        end
    end
end

-- надо отметить в контркте на покупку что заявка исполнена
-- finish - помечаем контракт
-- done
function deleteBuyCost(result, saleContract)
    if #setting.sellTable > 0 then
        for sellT = 1, #setting.sellTable do
            if setting.sellTable[sellT].executed == true and
                setting.sellTable[sellT].trans_id == saleContract.trans_id_buy then

                local local_contract = setting.sellTable[sellT];

                setting.sellTable[sellT].use_contract = local_contract.use_contract - saleContract.contract;

                setting.count_buyin_a_row = 0;
                setting.SPRED_LONG_LOST_SELL = result.price;

                
           
                setting.SPRED_LONG_TREND_DOWN = setting.SPRED_LONG_TREND_DOWN - setting.SPRED_LONG_TREND_DOWN_SPRED;
          


                if setting.SPRED_LONG_TREND_DOWN < 0 then
                    setting.SPRED_LONG_TREND_DOWN = setting.SPRED_LONG_TREND_DOWN_minimal;
                end

                setting.sellTable[sellT].work = false;

                if setting.limit_count_buy > 0 then
                    setting.limit_count_buy = setting.limit_count_buy - result.qty
                end

                if setting.limit_count_buy == 0 then
                    setting.sellTable[sellT].work = false;
                end

                setting.count_contract_sell =  setting.count_contract_sell + saleContract.contract;

                signalShowLog.addSignal(8, false, result.price);

                if setting.emulation then
                    label.set(setting, 'SELL', result.price, setting.sellTable[sellT].datetime, 1, "");
                end
                -- надо удалить контракт по которому мы покупали
                loger.save("вызов update_stop 2 ");
                -- risk_stop.update_stop(); 
                panelBids.show(setting);
            end
        end
    end
end

-- автоматическая торговля
-- done
local function decision_market(setting,price, datetime)


    loger.save( "getSignal gap " .. setting.SEC_CODE)


    market_gap.getOldPrice(setting);

    market_gap.autoStart(setting);

    market_gap.pushMarket(setting, datetime);


    -- Надо прочекать открытие рынка
   --  contitionMarket.getGetOpenMarket(price, setting.sellTable);


    -- подсчитаем скольк заявок у нас на продажу
    -- Не покупать, если была покупка по текущей цене или в промежутке
    local checkRangeBuy = contitionMarket.getRand(setting,price, setting.sellTable);
    -- Не покупать, если стоит ли продажа в этом промежутке, не продали контракт
    local checkRangeSell = contitionMarket.getRandSell(setting,price, setting.sellTable);


    --  Не покупать, если свечной анализ показывает низкий уровень промежутка продаж/покупок 
     local randCandle = contitionMarket.getRandCandle(setting,price);

    -- Определяем, цена удовлетворяет тому чтобы купить или продать
    local randCandleProfit = contitionMarket.getRandCandleProfit(setting,price)

    -- Не покупать, если рынок падает а мы раньше купили, но не продали согласно правилам
    local failMarket = contitionMarket.getFailMarket(setting,price);

    -- Не покупать, если лимит по заявкам выделеным на покупку исчерпан
    local limitBuy = contitionMarket.getLimitBuy(setting);
    -- Не покупать, если сработала блокировка покупки при падении рынка
    local getFailBuy = contitionMarket.getFailBuy(setting,price);
    -- Не покупать, если кнопка покупки заблокирована  (блокируется кнопкой)
    local buyButtonBlock = contitionMarket.buyButtonBlock(setting,price);
    -- Не покупать, если цена выше коридора покупок
    local not_high = contitionMarket.not_high(setting,price);
    -- Не покупать, если цена выше коридора покупок
   --  local not_low = contitionMarket.not_low(price);
 
    if limitBuy 
    and checkRangeBuy 
    and checkRangeSell 
  --  and randCandleProfit 
    -- and randCandle 
   -- and failMarket 
    and getFailBuy 
   and buyButtonBlock 
   and not_high  
    -- and not_low
         then
        setting.SPRED_LONG_TREND_DOWN = setting.SPRED_LONG_TREND_DOWN +
                                            setting.SPRED_LONG_TREND_DOWN_SPRED;
        setting.SPRED_LONG_TREND_DOWN_LAST_PRICE = price; -- записываем последнюю покупку
 
   
        if  setting.status   then 
            market_gap.autoStart(setting);
        --  callBUY(price, datetime);
            -- обновляем изменения в панели управления
        end
    end
end

local function decision(setting, price, datetime, levelLocal, event) -- решение

    
    loger.save( "decision_market " .. setting.SEC_CODE)
    decision_market(setting, price, datetime, levelLocal, event);
end

local M = {}; 
M.saleExecution = saleExecution;
M.updateTransaction = updateTransaction;
M.callSELL_emulation = callSELL_emulation;
M.startContract = startContract;
M.takeExecutedContract = takeExecutedContract;
M.decision = decision;
M.setDirect = setDirect;
M.setLitmitBid = setLitmitBid;

return M
