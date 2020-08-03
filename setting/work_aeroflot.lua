-- Перед тем чтоб робота перевести робота в боевой режим, посмотрите работу робота XoraX в режиме эмуляции
-- Следите за объёмом и рисками
-- Не гонитеь за большими заработками
-- Удачи...
-- @xorax <=> @koras
-- счёт клиента, как вариант его можно узнать в зваяках в таблице заявок
setting.ACCOUNT = 'L01-00000F00';

-- класс бумаги. У фьючерсов в основном он одинаков
setting.CLASS_CODE = "TQBR";

-- код бумаги. Название бумаги разная от месяца к месяцу 
setting.SEC_CODE = "AFLT";

-- тег графика, необходимо указывать в том графике из которого робот будет получать данные. 
-- график нужен в минутном таймфрейме(обязательно)
setting.tag = "aeroflot";

-- тип инструмента, каждый тип имеет свои настройки
-- 1 фьючерс
-- 2 акции на moex
setting.type_instrument = 2;

-- минимальная прибыль
setting.profit_range = 0.35;

-- минимальная прибыль при больших заявках при торговле веерной продажей
setting.profit_range_array = 0.03;
-- для веерной продажи. Какой промежуток между заявками
setting.profit_range_array_panel = 0.01;

-- погрешность, необходимо для предотвращения проскальзывания при активной торговле
setting.profit_infelicity = 0.02;

-- лимит количества заявок на сессию работы робота.
setting.LIMIT_BID = 10;

-- сколько использовать контрактов по умолчанию в режиме скальпинга
setting.use_contract = 2;
 
-- включён или выключен режим эмуляции по умолчанию
setting.emulation = false;
 

-- Выставлять контракт на продажу через тейки или лимитки
-- Если рыно слабо ходит то выгоднее лимитки. Так как при выставлении тейков, продаваться будет ниже, что не выгодно.
-- по умолчанию стоят тейки
setting.sell_take_or_limit = false;
 

setting.SPRED_LONG_BUY_UP = 0.12; -- условия; не покупаем если здесь ранее мы купили | вверх диапозон;
setting.SPRED_LONG_BUY_down = 0.11; -- условия; не покупаем если здесь ранее мы купили | вниз диапозон

setting.not_buy_high_UP = 0.5; -- условия; цена входа при запуске скрипта 
setting.not_buy_high_change = 0.05; --  изменения в контрольеой панели

setting.not_buy_low_UP = 1.5; -- условия; цена входа при запуске скрипта 
setting.not_buy_low_change = 0.05; --  изменения в контрольеой панели


setting.take_profit_offset = 0.05;
setting.take_profit_spread = 0.05;
 
setting.candle_buy_number_down_price = 6; -- сколько свечей должно пройти чтобы отпустить продажу  
 
setting.fractal_down_range = 0.05; -- если цена ниже; значит здесб был уровень; а под уровнем не покупаем.
setting.fractal_candle = 3;
setting.fractal_under_up = 0.06; -- под вверхом не покупаем; можем пробить а цена не пойдёт в нашу сторону

-- сколько нужно подряд купить контрактов при падении рынка
-- что-бы заблокировать кнопку покупки
-- +1 покупка, блокировка покупок
setting.each_to_buy_to_block = 3; -- потом только решение за человеком или пока не будут проданы все позиции


-- рынок падает, увеличиваем растояние между покупками
setting.SPRED_LONG_TREND_DOWN = 0.01;
setting.SPRED_LONG_TREND_DOWN_SPRED = 0.02; -- на сколько увеличиваем растояние

-- рынок падает, увеличиваем растояние между покупками(минимальное число)
setting.SPRED_LONG_TREND_DOWN_minimal = 0.01;

-- минимильное измерение в инструменте 
setting.instrument_measurement = 0.01;

-- расстояние от максимальной покупки
-- зависимость от используемых контрактов
stopClass.spred = 1.0;
stopClass.spred_default = 0.04;
-- на сколько исзменять параметр в панели управления
stopClass.spred_limit = 0.11;

-- увеличение промежутка между стопами
stopClass.spred_range = 0.1;
stopClass.spred_range_default = 0.09;

-- на сколько исзменять параметр в панели управления
stopClass.spred_range_limit = 0.01;

-- сколько свечей являются уходящими по тренду для расчёта общей динамики
engine.candle_range = 10;

-- какой средний промежуток в цене инструмента считается допустимый при расчёте формации
engine.candle_price_range = 0.05; -- для нефти например

-- какая высота должна быть, для того чтобы понять, текущий уровень высокий или низкий
-- минимальная высота в цене
engine.candle_price_max_hight = 0.5;

-- минутные свечи. используются для подсчёта 
setting.count_of_candle = 45;

-- https://open-broker.ru/pricing-plans/
