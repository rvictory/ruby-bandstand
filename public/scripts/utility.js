"use strict";

var wb = wb || {};

//Used to set the "active" navigation element given its id
wb.setSelectedNavigation = function (nav) {
    $('#main_navigation').find('li').removeClass('active');
    $('#' + nav).addClass('active');
};