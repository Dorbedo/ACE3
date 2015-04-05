/*
 * Author: PabstMirror
 * 
 *
 * Arguments:
 * 0: The Module Logic Object <OBJECT>
 * 1: synced objects <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * 
 *
 * Public: No
 */
#include "script_component.hpp"

PARAMS_3(_logic,_syncedUnits,_activated);

if (!_activated) exitWith {WARNING("Module - placed but not active");};
if (!isServer) exitWith {};

[_logic, QGVAR(noComputer), "noComputer"] call EFUNC(common,readSettingFromModule);
