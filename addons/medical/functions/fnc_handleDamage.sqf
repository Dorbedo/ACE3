/*
 * Author: KoffeinFlummi, Glowbal
 * Main HandleDamage EH function.
 *
 * Arguments:
 * 0: Unit That Was Hit <OBJECT>
 * 1: Name Of Hit Selection <STRING>
 * 2: Amount Of Damage <NUMBER>
 * 3: Shooter <OBJECT>
 * 4: Projectile <OBJECT/STRING>
 *
 * Return Value:
 * Damage To Be Inflicted <NUMBER>
 *
 * Public: No
 */

#include "script_component.hpp"

private ["_unit", "_selection", "_damage", "_shooter", "_projectile", "_damageReturn", "_hitPoints",  "_typeOfDamage"];
_unit         = _this select 0;
_selection    = _this select 1;
_damage       = _this select 2;
_shooter      = _this select 3;
_projectile   = _this select 4;

if !(local _unit) exitWith {nil};

if !([_unit] call FUNC(hasMedicalEnabled)) exitwith {systemChat format["Has no medical enabled: %1", _unit];};

if (typeName _projectile == "OBJECT") then {
    _projectile = typeOf _projectile;
    _this set [4, _projectile];
};

// If the damage is being weird, we just tell it to fuck off.
_hitSelections = ["head", "body", "hand_l", "hand_r", "leg_l", "leg_r"];
if !(_selection in (_hitSelections + [""])) exitWith {0};

_damageReturn = _damage;

_damageReturn = (_this select 2);
if (GVAR(level) == 0) then {
    _damageReturn = (_this + [_damageReturn]) call FUNC(handleDamage_basic);
};

if (_damageReturn < 0.01) exitWith {0};

if (GVAR(level) >= 1) then {
    [_unit, _selectionName, _damage, _source, _projectile, _damageReturn] call FUNC(handleDamage_caching);

    if (_damageReturn > 0.9) then {
        _hitPoints = ["HitHead", "HitBody", "HitLeftArm", "HitRightArm", "HitLeftLeg", "HitRightLeg"];
        _newDamage = _damage - (damage _unit);
        if (_selectionName in _hitSelections) then {
            _newDamage = _damage - (_unit getHitPointDamage (_hitPoints select (_hitSelections find _selectionName)));
        };
        if ([_unit, [_selectionName] call FUNC(selectionNameToNumber), _newDamage] call FUNC(determineIfFatal)) then {
            if ([_unit] call FUNC(setDead)) then {
                _damageReturn = 1;
            };
        } else {
            _damageReturn = 0.89;
        };
    };
};

if (_unit getVariable [QGVAR(preventDeath), false] && {_damageReturn >= 0.9} && {_selection in ["", "head", "body"]}) exitWith {
    if (vehicle _unit != _unit and {damage _vehicle >= 1}) then {
        // @todo
        // [_unit] call FUNC(unload);
    };
    0.89
};

_damageReturn
