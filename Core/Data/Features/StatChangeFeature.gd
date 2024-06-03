extends BaseFeature
class_name StatChangeFeature

enum Kind { AMOUNT, PERC }

@export var stat : Global.Stat
@export var kind : Kind
@export var amount : int = 0

static func getStackModAmount(_kind:Kind,_level:int,_amount:int):
    match _kind:
        Kind.PERC:
            var _mult = 0.01 + (_level * 0.005)
            return _amount * _mult
        _:
            var _mult = 1.0 + (_level * 0.1)
            return _amount * _mult