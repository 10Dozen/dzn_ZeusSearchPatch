
/*
	dzn_ZeusSearchPatch
	v0.4
*/

if (!hasInterface) exitWith {};
call compile preprocessFileLineNumbers format ["%1Settings.sqf", "\dzn_ZeusSearchPatch\"];

#define GVAR(X)	dzn_ZSP_##X

#define ZEUS_DISPLAY (findDisplay 312)
#define ORIGINAL_SEARCH_IDC 283
#define CUSTOM_SEARCH_IDC 109200
#define GET_ZEUS_CTRL(X) (ZEUS_DISPLAY displayCtrl X)

// --- Values from Arma 3\Curator\Addons\ui_f_curator\a3\ui_f_curator UI classes
/*
// Group
x = "safezoneX + safezoneW - 12.5 * GRID_X";
y = "1.5 * GRID_Y + (safezoneY)";
h = "safezoneH - 2 * GRID_Y";
w = "11 * GRID_X";

// Seach field
x = "0.1 * GRID_X";
y = "4.1 * GRID_Y";
w = "9.7 * GRID_X";
h = "1 * GRID_Y";
*/
#define GRID_X	(((safezoneW / safezoneH) min 1.2) / 40)
#define GRID_Y	((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
#define GRP_X		safezoneX + safezoneW - 12.5 * GRID_X
#define GRP_Y		1.5 * GRID_Y + (safezoneY)

#define CTRL_X	0.1 * GRID_X
#define CTRL_W	9.7 * GRID_X
#define CTRL_WIDE_X	0.1 * GRID_X - 1 * GRID_X
#define CTRL_WIDE_W	12.7 * GRID_X + 0.05 * GRID_X
#define CTRL_Y	4.1 * GRID_Y
#define CTRL_H	1 * GRID_Y


// --- Stuff to fix but of missiong sides
#define SIDE_B 155
#define SIDE_O 156
#define SIDE_I 157
#define SIDE_C 158
#define SIDE_E 159
#define MODE_UNITS 150
#define MODE_GROUPS 151
#define MODE_MODULES 152
#define MODE_MARKERS 154

[] spawn {
	waitUntil { !isNull (call BIS_fnc_displayMission) && local player };	
	GVAR(Show) = true;
	GVAR(Mode2SideMap) = [
		[MODE_UNITS, [SIDE_B, SIDE_O, SIDE_I, SIDE_C, SIDE_E]]
		, [MODE_GROUPS, [SIDE_B, SIDE_O, SIDE_I, SIDE_E]]
		, [MODE_MODULES, [SIDE_E]]
		, [MODE_MARKERS, [SIDE_E]]
	];
	
	GVAR(fnc_addModeSwitchHandler) = {
		{
			GET_ZEUS_CTRL(_x) ctrlAddEventHandler ["MouseButtonUp", {
				_this spawn GVAR(fnc_showSidesFix);
			}];		
		} forEach [MODE_UNITS, MODE_GROUPS, MODE_MODULES, MODE_MARKERS];	
	};
	
	GVAR(fnc_showSidesFix) = {
		/*
		 *	Redraws all side selectors on switching zeus mode
		 */
		params ["_control"];
		
		uiSleep 0.001;
		private _idc = ctrlIDC _control;
		private _sides = ((GVAR(Mode2SideMap) select { _x # 0 == _idc }) # 0) # 1;				
		{
			if (!ctrlShown GET_ZEUS_CTRL(_x)) then {
				GET_ZEUS_CTRL(_x) ctrlShow true;
			};
		} forEach _sides;
	};
	
	GVAR(fnc_addSearchField) = {
		/*
		 *	Hides original search field, draw new one and set up needed event handlers
		 */
		 
		private _display = ZEUS_DISPLAY;
		private _textbox = _display displayCtrl ORIGINAL_SEARCH_IDC;
		private _pos = ctrlPosition _textbox;
		_textbox ctrlShow false;
		_textbox ctrlCommit 0;
		
		private _newTextbox = _display ctrlCreate ["RscEdit", CUSTOM_SEARCH_IDC];	
		_newTextbox ctrlSetPosition [
			GRP_X + (if (GVAR(UseExtraWideField)) then { CTRL_WIDE_X } else { CTRL_X })
			, GRP_Y + CTRL_Y
			, (if (GVAR(UseExtraWideField)) then { CTRL_WIDE_W } else { CTRL_W }) 
			, CTRL_H
		];
		_newTextbox ctrlSetBackgroundColor [0, 0, 0, 0.75];
		_newTextbox ctrlCommit 0;		
		
		_newTextbox ctrlAddEventHandler ["KeyUp", {
			params ["_control", "_key", "_shift", "_ctrl", "_alt"];
			
			// --- Enter or NumEnter
			if (_key == 28 || _key == 156) exitWith {
				GET_ZEUS_CTRL(ORIGINAL_SEARCH_IDC) ctrlSetText (ctrlText _control);
			};
		}];
		_newTextbox ctrlAddEventHandler ["KeyDown", { false }];
		_newTextbox ctrlAddEventHandler ["SetFocus", { 
			missionnamespace setvariable ["RscDisplayCurator_search", true]; 
		}];
		_newTextbox ctrlAddEventHandler ["KillFocus", { 
			missionnamespace setvariable ["RscDisplayCurator_search", false]; 
		}];
		
		_display displayAddEventHandler ["KeyUp", {
			// --- Hide custom search field if Backspace pressed (hide UI in Zeus)
			params ["_display", "_key", "_shift", "_ctrl", "_alt"];
			
			if (_key == 14 && !(missionnamespace getvariable ["RscDisplayCurator_search", false])) exitWith {
				GVAR(Show) = !GVAR(Show);
				 
				GET_ZEUS_CTRL(CUSTOM_SEARCH_IDC) ctrlShow GVAR(Show);
				GET_ZEUS_CTRL(CUSTOM_SEARCH_IDC) ctrlCommit 0;
			};
		}];
		
		if (GVAR(FocusHandlerEnabled)) then {
			_display displayAddEventHandler ["MouseButtonDown", {
				// --- Handle focus on custom search field even if it drawn under zeus ui panels
				params ["_display", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
				
				if (
					_xPos > (GRP_X + CTRL_X) 
					&& { _yPos < (GRP_Y + CTRL_Y + CTRL_H) }
					&& { _xPos < (GRP_X + CTRL_X + CTRL_W) && _yPos > (GRP_Y + CTRL_Y) }
				) then {
					[] spawn {
						uiSleep 0.025;
						ctrlSetFocus GET_ZEUS_CTRL(CUSTOM_SEARCH_IDC); 
					};
				};		
			}];
		};
	};
	
	while {!isNull (call BIS_fnc_displayMission)} do {
		if (GVAR(Enabled)) then {
			// Waits until Zeus UI is opened
			waituntil {!(isNull ZEUS_DISPLAY)}; 

			[] call GVAR(fnc_addSearchField);
			[] call GVAR(fnc_addModeSwitchHandler);
			
			// Stops loop until zeus ui opened
			waituntil {isNull ZEUS_DISPLAY}; 
		};
	};
};