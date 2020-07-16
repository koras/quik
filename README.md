# Robot XoraX

Бесплатный робот для торговле фьючерсными контрактами Brent

Робот умеет выставлять заявки на продажу и покупку. У робота свой алгоритм торговли. 
Робот хорошо держит боковик и волатильность

Робот обладает функционалом:
- тейк профит на продажу
- регулировка профита покупки продажи контрактов
- лимит контрактов на торговлю
- установка количество используемых заявок на разовую покупку и продажу
- регилировка безопасного спреда на продажу тейк профита
- эмуляция торговли для понятия алгоритма торговли
- остановка и возобновление торговли в момент времени

Риски (снижение убытков) : 

Лимит на блокировку покупки. 


![Лимит на блокировку покупки](https://raw.githubusercontent.com/koras/robot_xorax/master/images/readme/risk_buy_block.PNG)

Если цена будет падать и робот купит 3 контракта подряд, не продав не одного контракта, то сработает блокировка покупки, пока вы сами не разблокируете руками. При продаже хотя-бы одного контракта, идёт сброс лимита в 0. Это сделано с первую очередь для того, чтобы ограничить убытки, если цена резко пойдёт вниз на пол доллара или больше и вы не успеете отключить робота 



- [Установка робота](https://github.com/koras/robot_xorax/blob/master/documentation/install.md)
- [Активные окна](https://github.com/koras/robot_xorax/blob/master/documentation/windows.md)
- [Контрольная панель](https://github.com/koras/robot_xorax/blob/master/documentation/control_panel.md)


Скрин результата работы

![Лимит на блокировку покупки](https://raw.githubusercontent.com/koras/robot_xorax/master/images/readme/scrin_work.PNG)

![Лимит на блокировку покупки](https://raw.githubusercontent.com/koras/robot_xorax/master/images/readme/example_1.PNG)
 

 
 




Последние релизы https://github.com/koras/robot_xorax/releases

Группы в телеграмм https://t.me/robots_xorax

