
#  Дипломная работа по профессии «Системный администратор». Исполнитель Канюгин Сергей sys-24.

Содержание
==========
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)
    * [Дополнительно](#Дополнительно)
* [Выполнение работы](#Выполнение-работы)
* [Критерии сдачи](#Критерии-сдачи)
* [Как правильно задавать вопросы дипломному руководителю](#Как-правильно-задавать-вопросы-дипломному-руководителю) 

---------

### Порядок выполнения дипломной работы

## Инфраструктура

Для развёртки инфраструктуры использовались Terraform и Ansible.  

Инфраструктура описана в файле main.tf 

Согласно требованиям созданы следующие виртуальные машины:

 - vm-ansible
 - vm-web1
 - vm-web2
 - vm-zabbix
 - vm-elk

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/1.jpg)
---
Инфраструктуру размещена в Yandex Cloud. 

### Сайт 
Виртуальные машины (vm-web1 и vm-web2) созданы в разных зонах (ru-central1-b и ru-central1-a).

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/2.jpg)
---

На виртуальных машинах (веб-серверах) установлен сервер nginx (файл nginx.yaml).  

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/3.jpg)
---

Виртуальные машины находятся во внутренней сети и  доступ к ним по ssh через бастион-сервер (vm-ansible). Доступ к web-порту виртуальной машины через балансировщик yandex cloud.

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/4.jpg)

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/5.jpg)
---

Осуществлена настройка балансировщика:

1. Создана [Target Group] включены в неё две созданных ВМ.

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/6.jpg)
---

2. Создана [Backend Group], осуществлена настройка backends на target group, ранее созданную. 

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/7.jpg)
---

3. Создан [HTTP router].

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/8.jpg)
---

4. Создан [Application load balancer].

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/9.jpg)
---

Протестирован сайт
`curl -v <публичный IP балансера>:80` 

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/10.jpg)

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/19.jpg)
---

### Мониторинг
Создана ВМ (vm-zabbix), на которой развернут Zabbix. 

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/11.jpg)
---

Zabbix-server расположен по адресу http://84.201.166.190:8080/
Логин Admin
Пароль zabbix

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/12.jpg)
---

На каждой ВМ установлен Zabbix Agent, агенты настроены на отправление метрик в Zabbix. 

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/13.jpg)
---

Настроены дешборды с отображением метрик (CPU, RAM, диски, сеть, http запросов к веб-серверам). 

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/14.jpg)
---

### Логи
Cоздана ВМ (vm-elk), на которой развернут Elasticsearch. 

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/15.jpg)
---

Установлен filebeat в ВМ к веб-серверам (vm-web1, vm-web2), который настроен на отправку access.log, error.log nginx в Elasticsearch.

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/16.jpg)
---
На ВМ (vm-elk) развернута Kibana, с помощью которой осуществлено соединение с Elasticsearch. Kibana находится по адресу http://51.250.19.82:5601

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/17.jpg)

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/18.jpg)
---
### Сеть
Развернут один VPC. 
![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/20.jpg)

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/21.jpg)
---

Настроены [Security Groups] соответствующих сервисов на входящий трафик только к нужным портам.

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/22.jpg)
![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/23.jpg)
![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/24.jpg)
![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/25.jpg)
![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/26.jpg)
---

Настроена ВМ (vm-ansible) с публичным адресом, в которой открыт только один порт — ssh.  Эта вм реализовывает концепцию  [bastion host]. 

![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/27.jpg)
---

### Резервное копирование
Создан snapshot дисков всех ВМ. Ограничено время жизни snaphot в неделю. Сами snaphot настроены на ежедневное копирование.
![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/28.jpg)
![скрин для Git](https://github.com/Sergeykanyugin/sys-diplom/blob/diplom-zabbix/img/29.jpg)
---

## Дипломная работа и программный код Terraform и Ansible находятся в отдельном репазитории


https://github.com/Sergeykanyugin/sys-diplom 