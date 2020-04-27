-- scriptTest.lua (in your scripts directory)
local M = {}
  
local init = {}
  
local color = dofile(getScriptPath() .. "\\interface\\color.lua");
local loger = dofile(getScriptPath() .. "\\loger.lua");


init.create = false;


-- SPRED_LONG_BUY = 0.02; -- покупаем если в этом диапозоне небыло покупок
  
-- SPRED_LONG_TREND_DOWN = 0.04; -- рынок падает, увеличиваем растояние между покупками
-- SPRED_LONG_TREND_DOWN_SPRED = 0.02; -- на сколько увеличиваем растояние

-- SPRED_LONG_TREND_DOWN_LAST_PRICE= 0; -- последняя покупка

-- SPRED_LONG_PRICE_DOWN = 0.04; -- не покупать если мы продали по текущей цене, вниз
-- SPRED_LONG_PRICE_UP = 0.04; -- не покупать если мы продали по текущей цене, вверх. Если мы явно в росто идём
-- SPRED_LONG_LOST_SELL = 0; -- Последняя цена сделки по продаже констракта
  
local word = {
	['title'] = "title",
	['info'] = "info",    
	['LIMIT_BID'] = "LIMIT_BID", 
	['ACCOUNT'] = "ACCOUNT", 
	['SEC_CODE'] = "SEC_CODE", 
	['CLASS_CODE'] = "CLASS_CODE", 
	['emulation'] = "emulation",   
	['profit_range'] = "profit_range", 
	['profit'] = "prifit:",   
	['count_buy'] = "count buy:",   
	['count_sell'] = "count sell:",   
	['Trading_Bot_stat_Panel'] = "Trading Bot statistics",
	['tag'] = "Tag table",

	['last_buy_price'] = "Last buy price",
	['last_sell_price'] = "Last sell price",

	['use_contract'] = 'use contract:'
};
 
 
 
local function show()  
	CreateNewTableStats(); 
	stats()  
end
  
 
  function stats()    
	--  return;
	 --  transaction.send("SELL", price, setting.use_contract);
 

	 SetCell(t_stat, 2, 1,  tostring(setting.LIMIT_BID));   
	 SetCell(t_stat, 3, 1,  tostring(setting.ACCOUNT));   
	 SetCell(t_stat, 4, 1,  tostring(setting.SEC_CODE));  
	 SetCell(t_stat, 5, 1,  tostring(setting.CLASS_CODE));
	 SetCell(t_stat, 6, 1,  tostring(setting.tag));

	 SetCell(t_stat, 10, 1,  tostring(profit));   
	SetCell(t_stat, 11, 1,  tostring( count_buy));  
	SetCell(t_stat, 12, 1,  tostring(count_sell));  
	SetCell(t_stat, 13, 1,  tostring(setting.use_contract));  


	SetCell(t_stat, 14, 1,  tostring(SPRED_LONG_TREND_DOWN_LAST_PRICE));  
	SetCell(t_stat, 15, 1,  tostring(SPRED_LONG_LOST_SELL));  
	

 

end;

--- simple create a table
function CreateNewTableStats() 
if createTable  then return; end;

init.create = true; 
	t_stat = AllocTable();	 


	AddColumn(t_stat, 0, word.title , true, QTABLE_STRING_TYPE, 25);
	AddColumn(t_stat, 1, word.info, true, QTABLE_STRING_TYPE, 40);
	AddColumn(t_stat, 2, word.sell, true, QTABLE_STRING_TYPE, 40);  
 
 

	t = CreateWindow(t_stat); 
	SetWindowCaption(t_stat, word.Trading_Bot_stat_Panel);  
	SetWindowPos(tt, 0, 70, 22, 140);
	
	for i = 1, 30 do
		InsertRow(t_stat, -1);
	 end; 


	 for i = 0, 3 do
		Blue(t_stat,1, i);
		--Gray(t_stat,3, i);
	--	Gray(t_stat,5, i);
	--	Gray(t_stat,7, i);
		Blue(t_stat,9, i); 
	--	Gray(t_stat,11, i); 
	--	Gray(t_stat,13, i); 
	--	Gray(t_stat,15, i); 
	--	Gray(t_stat,17, i); 
		Blue(t_stat,20, i); 
	 end; 
	 
	 for i = 10, 19 do
		Yellow(t_stat, i, 0);
		Yellow(t_stat, i, 1); 
	   end; 
	   for i = 2, 8 do
		   Gray(t_stat, i, 0);
		   Gray(t_stat, i, 1); 
		 end; 
		for i = 21, 30 do
			 Gray(t_stat, i, 0);
			 Gray(t_stat, i, 1); 
		end; 
	 
	  
	SetCell(t_stat, 2, 0,  tostring(word.LIMIT_BID));   
	SetCell(t_stat, 3, 0,  tostring(word.ACCOUNT));  
	SetCell(t_stat, 4, 0,  tostring(word.SEC_CODE));  
	SetCell(t_stat, 5, 0,  tostring(word.CLASS_CODE)); 
	SetCell(t_stat, 6, 0,  tostring(word.tag)); 
	   
	SetCell(t_stat, 10, 0,  tostring(word.profit));  
	SetCell(t_stat, 11, 0,  tostring(word.count_buy));  
	SetCell(t_stat, 12, 0,  tostring(word.count_sell));  
	SetCell(t_stat, 13, 0,  tostring(word.use_contract));  
	SetCell(t_stat, 14, 0,  tostring(word.last_buy_price));  
	SetCell(t_stat, 15, 0,  tostring(word.last_sell_price));  




 
	-- ['last_buy_price'] = "Last buy price",
	-- ['last_sell_price'] = "Last sell price",


end;

 

 function deleteTableStats(Line, Col)   
	DestroyTable(t_stat)
 end;

 
 M.deleteTableStats = deleteTableStats;
 M.stats =  stats;
M.deleteTable = deleteTable;
M.CreateTable = CreateTable;
M.show = show;

return M