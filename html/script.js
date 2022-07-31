var Plants;
var Plant;
var type;
var Tables;
var table;
var amount;
var processing = false;
var inventory;
var canProcess = false;


function closeMenu() {
    $.post('https://core_drugs/close', JSON.stringify({}));
    processing = false;

    $("#main_container").fadeOut(400);
    timeout = setTimeout(function() {
        $("#main_container").html("");
        $("#main_container").fadeIn();
    }, 400);


}

$(document).keyup(function(e) {
    if (e.keyCode === 27) {


        closeMenu();

    }

});

function playClickSound() {
    var audio = document.getElementById("clickaudio");
    audio.volume = 0.05;
    audio.play();
}

function playProcessed() {
    var audio = document.getElementById("processed");
    audio.volume = 0.05;
    audio.play();
}

function deleteTable() {
    if (!processing) {
        $.post('https://core_drugs/deleteTable', JSON.stringify({}));


        $("#main_container").fadeOut(400);
        timeout = setTimeout(function() {
            $("#main_container").html("");
            $("#main_container").fadeIn();
        }, 400);
    }

}

function updateProcess() {

    var input = $('#u1785').val();



    if (input == "" || parseInt(input) < 0 || parseInt(input) > 10) {
        input = 1;
    }

    amount = input;

    $('#u1767-4').text("X" + input);


    $('.ingrediant').each(function() {

        var original = $(this).find('#u1740-4').attr('data-original');

        var item = $(this).attr('data-item');
        item = inventory[item];

        if (item != null) {
            if (item < (parseInt(original) * parseInt(input))) {

                $(this).find("#u1734").css("opacity", "0.7");
                $(this).find('#u1740-4').css('color', "#ff667d");

            } else {
                $(this).find("#u1734").css("opacity", "1.0");
                $(this).find('#u1740-4').css('color', "white");
            }
        }


        $(this).find('#u1740-4').text("X" + (parseInt(original) * parseInt(input)).toString());

    });


}

function process() {

    if (processing || !canProcess) {

        return;
    }

    if (amount == null) {
        amount = 1;
    }

    var time = Tables[table].Time * amount * 1000;

    processing = true;
    $.post('https://core_drugs/process', JSON.stringify({
        type: table,
        amount: amount,
        time: time
    }));
    playClickSound();

    $("#u1700").animate({
        width: 475
    }, time, function() {
        processed();
    });



}

function processed() {
    playProcessed();
    $("#u1700").animate({
        width: 0
    }, 200, function() {
        processing = false;
    });



}

function setProgress(field, p, textField) {

    var prog = (196 / 100) * p;


    $(field).animate({
        width: prog
    }, 400, function() {



    });

    p = Math.round(p * 100) / 100
    $(textField).text(p + "%");

}

function feedPlant() {
    playClickSound();
    $.post('https://core_drugs/feed', JSON.stringify({}));

}

function waterPlant() {
    playClickSound();
    $.post('https://core_drugs/water', JSON.stringify({}));

}

function destroyPlant() {
    playClickSound();
    $.post('https://core_drugs/destroy', JSON.stringify({}));

}

function harvestPlant() {
    playClickSound();
    $.post('https://core_drugs/harvest', JSON.stringify({}));

}

function openProccesingTable() {

    canProcess = true;

    var base = '<div id="gradient" style=" background: rgb(254,54,255); background: linear-gradient(90deg, rgba(' + Tables[table].Color + ',0.3) 0%, rgba(' + Tables[table].Color + ',0) 100%);"></div>' +
        '<div class="clearfix slide-right" id="processingTable"><!-- column -->' +
        '   <div class="clearfix colelem" style="color: rgba(' + Tables[table].Color + ', 1.0);   text-shadow:0 0 1px rgba(' + Tables[table].Color + ',.62),0 0 1px rgba(' + Tables[table].Color + ',.62);" id="u1670-4"><!-- content -->' +
        '    <p>COCAINE</p>' +
        '   </div>' +
        '   <div class="clearfix colelem" id="u1625-4"><!-- content -->' +
        '    <p>PROCESSING TABLE</p>' +
        '   </div>' +
        '   <div class="clearfix colelem" id="pu1694"><!-- group -->' +
        '    <div class="grpelem" id="u1694"><!-- simple frame --></div>' +
        '    <div class="shadow rounded-corners grpelem" style="background-color: rgba(' + Tables[table].Color + ', 1.0);  box-shadow:0 0 8px rgba(' + Tables[table].Color + ',.5),0 0 8px rgba(' + Tables[table].Color + ',.5);" id="u1700"><!-- simple frame --></div>' +
        '   </div>' +
        '   <div class="clearfix colelem" id="pu1713"><!-- group -->' +
        '    <div class="shadow grpelem" style=" border: 2px solid rgba(' + Tables[table].Color + ', 1.0);background-color: rgba(31,31,31,0.5); background-image: url(img/' + Tables[table].Item + '.png); background-size: 80%; background-repeat: no-repeat; background-position: center;" id="u1713"><!-- simple frame --></div>' +
        '    <div class="clearfix grpelem" id="u1714"><!-- group -->' +
        '     <div class="clearfix grpelem" id="u1767-4"><!-- content -->' +
        '      <p>x1</p>' +
        '     </div>' +
        '    </div>' +
        '    <div class="clearfix grpelem" id="u1731"><!-- group -->' +
        '     <div class="clearfix grpelem" id="ppu1734"><!-- column -->' +
        '      <div class="clearfix colelem" id="pu1734"><!-- group -->' +

        '  <div id="ingrediants">';

    var exist = false;

    for (const [key2, value2] of Object.entries(Tables[table].Ingrediants)) {

        for (const [key, value] of Object.entries(inventory)) {
            if (key == key2 && value >= value2) {
                exist = true;
            }
        }

        if (exist) {

            base = base + '       <div class="clearfix grpelem ingrediant" data-item="' + key2 + '" id="u1737"><!-- group -->' +
                '       <div class="shadow grpelem" id="u1734" style="background-color: rgba(31,31,31,0.5); background-image: url(img/' + key2 + '.png); background-size: 80%; background-repeat: no-repeat; background-position: center;"><!-- simple frame --></div>' +
                '        <div class="clearfix grpelem" data-original="' + value2 + '" id="u1740-4">' +
                'X' + value2 +
                '        </div>' +
                '       </div>';
        } else {
            canProcess = false;

            base = base + '       <div class="clearfix grpelem ingrediant" data-item="' + key2 + '"  id="u1737"><!-- group -->' +
                '       <div class="shadow grpelem" id="u1734" style=" opacity: 0.7; background-color: rgba(31,31,31,0.5); background-image: url(img/' + key2 + '.png); background-size: 80%; background-repeat: no-repeat; background-position: center;"><!-- simple frame --></div>' +
                '        <div class="clearfix grpelem" style="color: #ff667d" data-original="' + value2 + '" id="u1740-4">' +
                'X' + value2 +
                '        </div>' +
                '       </div>';
        }


    }

    base = base + '   </div>' +

        '      </div>' +
        '      <div class="clearfix colelem" id="pu1785"><!-- group -->' +
        '       <input class="shadow grpelem"  type="number" max="100" min="1" value="1" oninput="updateProcess()" id="u1785"><!-- simple frame --></input>' +
        '       <div class="shadow rounded-corners clearfix grpelem" style="box-shadow: inset 0px 0px 0px 2px rgba(' + Tables[table].Color + ', 1.0);" onclick="process()" id="u1770"><!-- group -->' +
        '        <div class="clearfix grpelem"  id="u1773-4"><!-- content -->' +
        '         <p>PROCESS</p>' +
        '        </div>' +
        '       </div>' +
        '<div id="delete" onclick="deleteTable()" style="box-shadow: inset 0px 0px 0px 2px rgba(' + Tables[table].Color + ', 1.0);">X</div>' +
        '      </div>' +
        '     </div>' +
        '     <div class="clearfix grpelem" id="pu1776"><!-- group -->' +


        '     </div>' +
        '    </div>' +
        '   </div>' +
        '  </div>';

    $("#main_container").html(base);


}

function openInformation(alive) {

    var color;

    if (alive) {
        color = Plants[type].Color;
    } else {
        color = '217, 39, 60';
    }


    var base = '<div class="clearfix slide-right" id="information"><!-- column -->' +
        '   <div class="clearfix colelem" id="pu817"><!-- group -->' +
        '    <img class="grpelem" id="u817" alt="" width="80" height="80" src="img/' + Plants[type].Image + '"/><!-- rasterized frame -->' +
        '    <div class="clearfix grpelem" id="pu894-4"><!-- column -->' +
        '     <div class="clearfix colelem" id="u894-4"><!-- content -->' +
        '      <p>' + Plants[type].Type.toUpperCase() + '</p>' +
        '     </div>' +
        '     <div class="clearfix colelem" style=" color:rgb(' + color + '); text-shadow:0 0 8px rgba(' + color + ',.5),0 0 8px rgba(' + color + ',.5),1px 1px 1px rgba(0,0,0,.5);" id="u793-4"><!-- content -->' +
        '      <p>' + Plants[type].Label.toUpperCase() + '</p>' +
        '     </div>' +
        '    </div>' +
        '   </div>' +

        '   <div class="colelem" id="u851"><!-- simple frame --></div>' +
        '   <div class="clearfix colelem" id="pu798-4"><!-- group -->' +
        '    <div class="clearfix grpelem" id="u798-4"><!-- content -->' +
        '     <p>GROWTH</p>' +
        '    </div>' +
        '    <div class="clearfix grpelem" style=" color:rgb(' + color + '); text-shadow:0 0 8px rgba(' + color + ',.5),0 0 8px rgba(' + color + ',.5),1px 1px 1px rgba(0,0,0,.5);" id="u836-4"><!-- content -->' +
        '     0%' +
        '    </div>' +
        '    <div class="grpelem" id="u879"><!-- simple frame --></div>' +
        '    <div class="shadow rounded-corners grpelem" style=" background: rgb(' + color + ') -webkit-linear-gradient(left, rgb(' + color + '), rgba(255, 255, 255, 0.5)) no-repeat 0 0 / 30px; box-shadow:0 0 6px rgba(' + color + ',.36),0 0 6px rgba(' + color + ',.36);" id="u882"><!-- simple frame --></div>' +
        '   </div>' +
        '   <div class="clearfix colelem" id="pu801-4"><!-- group -->' +
        '    <div class="clearfix grpelem" id="u801-4"><!-- content -->' +
        '     <p>RATE</p>' +
        '    </div>' +
        '    <div class="grpelem" id="u857"><!-- simple frame --></div>' +
        '    <div class="clearfix grpelem" style=" color:rgb(' + color + '); text-shadow:0 0 8px rgba(' + color + ',.5),0 0 8px rgba(' + color + ',.5),1px 1px 1px rgba(0,0,0,.5);" id="u866-4"><!-- content -->' +
        '     <p>0%</p>' +
        '    </div>' +
        '    <div class="shadow rounded-corners grpelem" style=" background: rgb(' + color + ') -webkit-linear-gradient(left, rgb(' + color + '), rgba(255, 255, 255, 0.5)) no-repeat 0 0 / 30px; box-shadow:0 0 6px rgba(' + color + ',.36),0 0 6px rgba(' + color + ',.36);" id="u885"><!-- simple frame --></div>' +
        '   </div>' +
        '   <div class="clearfix colelem" id="pu804-4"><!-- group -->' +
        '    <div class="clearfix grpelem" id="u804-4"><!-- content -->' +
        '     <p>WATER</p>' +
        '    </div>' +
        '    <div class="grpelem" id="u860"><!-- simple frame --></div>' +
        '    <div class="clearfix grpelem" style=" color:rgb(' + color + '); text-shadow:0 0 8px rgba(' + color + ',.5),0 0 8px rgba(' + color + ',.5),1px 1px 1px rgba(0,0,0,.5);" id="u869-4"><!-- content -->' +
        '     <p>0%</p>' +
        '    </div>' +
        '    <div class="shadow rounded-corners grpelem" style=" background: rgb(' + color + ') -webkit-linear-gradient(left, rgb(' + color + '), rgba(255, 255, 255, 0.5)) no-repeat 0 0 / 30px; box-shadow:0 0 6px rgba(' + color + ',.36),0 0 6px rgba(' + color + ',.36);" id="u888"><!-- simple frame --></div>' +
        '   </div>' +
        '   <div class="clearfix colelem" id="pu839-4"><!-- group -->' +
        '    <div class="clearfix grpelem" id="u839-4"><!-- content -->' +
        '     <p>FOOD</p>' +
        '    </div>' +
        '    <div class="grpelem" id="u863"><!-- simple frame --></div>' +
        '    <div class="clearfix grpelem" style=" color:rgb(' + color + '); text-shadow:0 0 8px rgba(' + color + ',.5),0 0 8px rgba(' + color + ',.5),1px 1px 1px rgba(0,0,0,.5);" id="u872-4"><!-- content -->' +
        '     <p>0%</p>' +
        '    </div>' +
        '    <div class="shadow rounded-corners grpelem" style=" background: rgb(' + color + ') -webkit-linear-gradient(left, rgb(' + color + '), rgba(255, 255, 255, 0.5)) no-repeat 0 0 / 30px; box-shadow:0 0 6px rgba(' + color + ',.36),0 0 6px rgba(' + color + ',.36);" id="u891"><!-- simple frame --></div>' +
        '   </div>' +
        '   <div id="buttons">';

    if (alive) {
        base = base + '   <div id="button" onclick="feedPlant()">FEED</div>' +
            '   <div id="button" onclick="waterPlant()">WATER</div>' +
            '   <div id="button" onclick="harvestPlant()">HARVEST</div>';
    }


    base = base + '   <div id="button" onclick="destroyPlant()">DESTROY</div>' +
        '   </div>' +
        '  </div>';

    $("#main_container").html(base);



}



function updateInformation(info) {


    if (info.rate == 0 && $('#u866-4').text() != "0%") {
        $("#information").remove();
        openInformation(false)

    }


    setProgress("#u882", info.growth, '#u836-4');
    setProgress("#u885", info.rate, '#u866-4');
    setProgress("#u888", info.water, '#u869-4');
    setProgress("#u891", info.food, '#u872-4');

}

window.addEventListener('message', function(event) {


    var edata = event.data;

    if (edata.type == 'showPlant') {
        Plants = edata.plants;
        Plant = edata.plant;
        type = edata.plantType;
        openInformation(true)
    } else if (edata.type == 'showProcessing') {
        Tables = edata.tables;
        table = edata.process;
        inventory = edata.inventory;
        openProccesingTable();

    } else if (edata.type == 'updatePlant') {
        updateInformation(edata.info);
    } else if (edata.type == 'hidePlant') {
        $("#information").fadeOut();
        setTimeout(() => {
            $("#information").remove();
        }, 200);

    }

});