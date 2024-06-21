extends Control
class_name BankMenu

enum EBankMode {DEPOSIT,WITHDRAW}

@export var bankCommand:Control
@export var details:Control
@export var operationLabel:Label
@export var amountInput:Control
@export var amountInAccount:Control
@export var goldAmountLabel:Label

var currentActiveScreen:Control = null
var currentMode:EBankMode = EBankMode.DEPOSIT

func _ready():
    currentActiveScreen = bankCommand
    _refreshGold()

func _process(delta):
    if Global.UI.Config.visible: return false
    if currentActiveScreen == amountInput:
        if Input.is_action_just_pressed("action_cancel"):
            Global.Audio.playSFX("cancel")
            goto(bankCommand)
            amountInput.editing = false
            amountInput.currentNumber = 0
            return
        if Input.is_action_just_pressed("action_ok"):
            Global.Audio.playSFX("shop")
            executeTransaction()
            goto(bankCommand)
            amountInput.editing = false
            amountInput.currentNumber = 0
            return
        if Global.Inputs.isRepeating("ui_up"):
            Global.Audio.playSFX("cursor")
            amountInput.dir = 1
            amountInput.change(1)
        elif Global.Inputs.isRepeating("ui_down"):
            Global.Audio.playSFX("cursor")
            amountInput.dir = -1
            amountInput.change(-1)
        elif Global.Inputs.isRepeating("ui_left"):
            Global.Audio.playSFX("cursor")
            amountInput.move(-1)
        elif Global.Inputs.isRepeating("ui_right"):
            Global.Audio.playSFX("cursor")
            amountInput.move(1)
        else:
            amountInput.dir = 0

func _refreshGold():
    amountInAccount.currentNumber = Global.State.bank.gold
    goldAmountLabel.text = "%d" % Global.State.party.gold

func close():
    Global.Scene.closeUI(self)

func goto(screen):
    get_viewport().gui_release_focus()
    currentActiveScreen = null
    _refreshGold()
    await get_tree().process_frame
    currentActiveScreen = screen

func openBankMode(mode:EBankMode):
    currentMode = mode
    # populate and focus on item list
    amountInput.editing = true
    amountInput.dir = 0
    match mode:
        EBankMode.DEPOSIT:
            operationLabel.text = "Deposit"
            amountInput.currentMax = Global.State.bank.maxDepositGold()
            amountInput.currentNumber = Global.State.party.gold
        EBankMode.WITHDRAW:
            operationLabel.text = "Withdraw"
            amountInput.currentMax = Global.State.bank.maxTakeOutGold()
            amountInput.currentNumber = 1000
    goto(amountInput)

func executeTransaction():
    match currentMode:
        EBankMode.DEPOSIT:
            Global.State.bank.depositGold(amountInput.currentNumber)
        EBankMode.WITHDRAW:
            Global.State.bank.takeOutGold(amountInput.currentNumber)
    _refreshGold()
    details.refreshLines()