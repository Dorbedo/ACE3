/*
 * Author: Glowbal, KoffeinFlummi
 * Starts the treatment process
 *
 * Arguments:
 * 0: The medic <OBJECT>
 * 1: The patient <OBJECT>
 * 2: SelectionName <STRING>
 * 3: Treatment classname <STRING>
 *
 * Return Value:
 * Succesful treatment started <BOOL>
 *
 * Public: Yes
 */

#include "script_component.hpp"

private ["_caller", "_target", "_selectionName", "_className", "_config", "_availableLevels", "_medicRequired", "_items", "_locations", "_return", "_callbackSuccess", "_callbackFailure", "_callbackProgress", "_treatmentTime", "_callerAnim", "_patientAnim", "_iconDisplayed"];
_caller = _this select 0;
_target = _this select 1;
_selectionName = _this select 2;
_className = _this select 3;

if !(_target isKindOf "CAManBase") exitWith {false};

_config = (configFile >> "ACE_Medical_Actions" >> "Basic" >> _className);
if (GVAR(level) >= 1) then {
    _config = (configFile >> "ACE_Medical_Actions" >> "Advanced" >> _className);
};
if !(isClass _config) exitwith {false};

// Check for required class
_medicRequired = getNumber (_config >> "requiredMedic");
if !([_caller, _medicRequired] call FUNC(isMedic) || [_target, _medicRequired] call FUNC(isMedic)) exitwith {false};

// Check item
_items = getArray (_config >> "items");
if (count _items > 0 && {!([_caller, _target, _items] call FUNC(hasItems))}) exitwith {false};

// Check allowed locations
_locations = getArray (_config >> "treatmentLocations");
_return = false;
if ("All" in _locations) then {
    _return = true;
} else {
    {
        if (_x == "field") exitwith {_return = true;};
        if (_x == "MedicalFacility" && {([_caller] call FUNC(isInMedicalFacility)) || ([_target] call FUNC(isInMedicalFacility))}) exitwith {_return = true;};
        if (_x == "MedicalVehicle" && {([vehicle _caller] call FUNC(isMedicalVehicle)) || ([vehicle _target] call FUNC(isMedicalVehicle))}) exitwith {_return = true;};
    }foreach _locations;
};
if !(_return) exitwith {false};

// Parse the config for the progress callback
_callbackProgress = getText (_config >> "callbackProgress");
if (isNil _callbackProgress) then {
    _callbackProgress = compile _callbackProgress;
} else {
    _callbackProgress = missionNamespace getvariable _callbackProgress;
};

// Start treatment
_treatmentTime = getNumber (_config >> "treatmentTime");
[
    _treatmentTime,
    [_caller, _target, _selectionName, _className, _items],
    DFUNC(treatment_success),
    DFUNC(treatment_failure),
    getText (_config >> "displayNameProgress"),
    _callbackProgress
] call EFUNC(common,progressBar);

// Patient Animation
_patientAnim = getText (_confg >> "animationPatient");
if (_caller != _target && {vehicle _target == _target} && {_patientAnim != ""}) then {
    [_target, _patientAnim] call EFUNC(common,doAnimation);
};

// Player Animation
_callerAnim = [getText (_config >> "animationCaller"), getText (_config >> "animationCallerProne")] select (stance _caller == "PRONE");
if (_caller == _target) then {
    _callerAnim = [getText (_config >> "animationCallerSelf"), getText (_config >> "animationCallerSelfProne")] select (stance _caller == "PRONE");
};
_wpn = ["non", "rfl", "pst"] select (["", primaryWeapon _caller, handgunWeapon _caller] find (currentWeapon _caller));
_callerAnim = [_callerAnim, "[wpn]", _wpn] call CBA_fnc_replace;
if (vehicle _caller == _caller && {_callerAnim != ""}) then {
    if (primaryWeapon _caller == "") then {
        _caller addWeapon "ACE_FakePrimaryWeapon";
    };
    _caller selectWeapon (primaryWeapon _caller);
    _caller setvariable [QGVAR(treatmentPrevAnimCaller), animationState _target];
    [_caller, _callerAnim] call EFUNC(common,doAnimation);
};

// Display Icon
_iconDisplayed = getText (_config >> "actionIconPath");
if (_iconDisplayed != "") then {
    [QGVAR(treatmentActionIcon), true, _iconDisplayed, [1,1,1,1], getNumber(_config >> "actionIconDisplayTime")] call EFUNC(common,displayIcon);
};

// handle display of text/hints
_displayText = "";
if (_target != _caller) then {
    _displayText = getText(_config >> "displayTextOther");
} else {
    _displayText = getText(_config >> "displayTextSelf");
};

if (_displayText != "") then {
    ["displayTextStructured", [_caller], [[_displayText, [_caller] call EFUNC(common,getName), [_target] call EFUNC(common,getName)], 1.5, _caller]] call EFUNC(common,targetEvent);
};


true;
