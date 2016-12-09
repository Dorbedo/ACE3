/*
 * Author: BaerMitUmlaut
 * Triggers the pain effect (single flash).
 *
 * Arguments:
 * 0: Enable <BOOL>
 * 1: Intensity <NUMBER>
 *
 * Return Value:
 * None
 */
#include "script_component.hpp"
params ["_enable", "_intensity"];

if (!_enable) exitWith {
    GVAR(ppPain) ppEffectEnable false;
};
GVAR(ppPain) ppEffectEnable true;

private _initialAdjust = [];
private _delayedAdjust = [];

if (GVAR(painEffectType) == 0) then {
    _intensity     = linearConversion [0, 1, _intensity, 0, 0.6, true];
    _initialAdjust = [1, 1, 0, [1, 1, 1, _intensity], [1, 1, 1, 1], [0.33, 0.33, 0.33, 0], [0.59, 0.64, 0, 0, 0, 0, 4]];
    _delayedAdjust = [1, 1, 0, [1, 1, 1,          0], [1, 1, 1, 1], [0.33, 0.33, 0.33, 0], [0.59, 0.64, 0, 0, 0, 0, 4]];
} else {
    _intensity     = linearConversion [0, 1, _intensity, 0, 0.008, true];
    _initialAdjust = [_intensity, _intensity, 0.3, 0.39];
    _delayedAdjust = [         0,          0, 0.3, 0.39];
};

GVAR(ppPain) ppEffectAdjust _initialAdjust;
GVAR(ppPain) ppEffectCommit 0.2;
[{
    GVAR(ppPain) ppEffectAdjust _this;
    GVAR(ppPain) ppEffectCommit 0.5;
}, _delayedAdjust, 0.2] call CBA_fnc_waitAndExecute;
