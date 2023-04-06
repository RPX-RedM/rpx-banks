var ShowingToast = false;
var ShopData = null;
var TransactionType = 1;

window.addEventListener("message", (event) => {
    const action = event.data.action;
    switch (action) {
        case "OPEN_BANK":
            $(".balance").html(event.data.balance.toLocaleString('en-US', { 
                style: 'currency', 
                currency: 'USD' 
            }));
            $("#bankmenu").fadeIn(250);
            break;
        case "CLOSE_BANK":
            $("#bankmenu").fadeOut(250);
            break;
        case "UPDATE_BALANCE":
            $(".balance").html(event.data.balance.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD'
            }));
            break;
        default:
            return;
    }
});

$(".close").click(function() {
    $("#bankmenu").fadeOut(250);
    $.post(`https://${GetParentResourceName()}/CloseNUI`);
});

$(".withdraw").click(function() {
    TransactionType = 1;
    $("#bankmenu").fadeOut(250, function() {
        $("#amount").val("");
        $("#transactionmenu").fadeIn(250);
        $("#transhead").html("Withdraw");
        $(".transact").html("Withdraw");
    });
});

$(".deposit").click(function() {
    TransactionType = 2;
    $("#bankmenu").fadeOut(250, function() {
        $("#amount").val("");
        $("#transactionmenu").fadeIn(250);
        $("#transhead").html("Deposit");
        $(".transact").html("Deposit");
    });
});

$(".transact").click(function() {
    var amount = $("#amount").val();
    if(amount == "") {
        Toast("Please enter an amount.", 2500);
    } else {
        $.post(`https://${GetParentResourceName()}/Transact`, JSON.stringify({
            type: TransactionType,
            amount: amount
        }));
        $("#transactionmenu").fadeOut(250, function() {
            $("#bankmenu").fadeIn(250);
        });
    }
});


$(".back").click(function() {
    $("#transactionmenu").fadeOut(250, function() {
        $("#bankmenu").fadeIn(250);
    });
});


// This enables the player to close the NUI with the escape key.
$(document).keyup(function(e) {
    if (e.keyCode == 27) {
        $("#bankmenu").fadeOut(250);
        $.post(`https://${GetParentResourceName()}/CloseNUI`);
    }
});

Toast = function(text, time) {
    if(!ShowingToast) {
        ShowingToast = true;
        $("#toast").html("<p>" + text + "</p>");
        $("#toast").fadeIn(250, function () {
            setTimeout(function() {
                $("#toast").fadeOut(250, function () {
                    $("#toast").html("");
                    ShowingToast = false;
                });
            }, time);
        });
    }
}