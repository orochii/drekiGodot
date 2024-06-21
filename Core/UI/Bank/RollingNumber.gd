@tool
extends NinePatchRect
class_name RollingNumber

@export var currentNumber:int = 0
@export var numbersPerSecond:float = 3.0

var _currentPos = 0.0

func _ready():
    _currentPos = currentNumber * 0.1
    _refreshTexture()

func _process(delta):
    var _target = currentNumber * 0.1
    if _target != _currentPos:
        # Make alternative targets
        var _targetBot = _target - 1
        var _targetTop = _target + 1
        # Get all deltas
        var _deltaBot = abs(_targetBot-_currentPos)
        var _deltaMid = abs(_target-_currentPos)
        var _deltaTop = abs(_targetTop-_currentPos)
        # Decide what's the closest target
        if _deltaBot < _deltaMid: _target = _targetBot
        elif _deltaTop < _deltaMid: _target = _targetTop
        # Go towards target
        _currentPos = move_toward(_currentPos, _target, delta * numbersPerSecond)
        _currentPos = _currentPos - int(_currentPos)
        if _currentPos < 0: _currentPos += 1
        # Refresh texture
        _refreshTexture()

func _refreshTexture():
    region_rect.position.y = _currentPos * 160