
/*
	dzn_ZeusSearchPatch
	v0.3
*/

if (!hasInterface) exitWith {};
call compile preprocessFileLineNumbers format ["%1Settings.sqf", "\dzn_ZeusSearchPatch\"];

#define GVAR(X)	dzn_ZSP_##X

#define ZEUS_DISPLAY (findDisplay 312)
#define ORIGINAL_SEARCH_IDC 283
#define CUSTOM_SEARCH_IDC 109200

[] spawn {
	waitUntil { !isNull (call BIS_fnc_displayMission) && local player };	
	GVAR(Show) = true;
	
	GVAR(fnc_addSearchField) = {
		/*
		 *	Hides original search field, draw new one and set up needed event handlers
		 */
		
		// --- Values from Arma 3\Curator\Addons\ui_f_curator\a3\ui_f_curator UI classes
		#define GRID_X	(((safezoneW / safezoneH) min 1.2) / 40)
		#define GRID_Y	((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
		#define GRP_X		safezoneX + safezoneW - 12.5 * GRID_X
		#define GRP_Y		1.5 * GRID_Y + (safezoneY)
		#define CTRL_X	0.1 * GRID_X - 1 * GRID_X
		#define CTRL_Y	4.1 * GRID_Y
		#define CTRL_W	12.7 * GRID_X + 0.05 * GRID_X
		#define CTRL_H	1 * GRID_Y
		
		private _display = ZEUS_DISPLAY;
		private _textbox = _display displayCtrl ORIGINAL_SEARCH_IDC;
		private _pos = ctrlPosition _textbox;
		_textbox ctrlShow false;
		_textbox ctrlCommit 0;
		
		private _newTextbox = _display ctrlCreate ["RscEdit", CUSTOM_SEARCH_IDC];		
		_newTextbox ctrlSetPosition [
			GRP_X + CTRL_X
			, GRP_Y + CTRL_Y
			, CTRL_W
			, CTRL_H
		];
		_newTextbox ctrlSetBackgroundColor [0, 0, 0, 0.75];
		_newTextbox ctrlCommit 0;		
		
		_newTextbox ctrlAddEventHandler ["KeyUp", {
			params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
			
			// --- Enter or NumEnter
			if (_key == 28 || _key == 156) exitWith {
				(ZEUS_DISPLAY displayCtrl ORIGINAL_SEARCH_IDC) ctrlSetText (ctrlText _displayorcontrol);
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
			params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
			
			if (_key == 14 && !(missionnamespace getvariable ["RscDisplayCurator_search", false])) exitWith {
				GVAR(Show) = !GVAR(Show);
				(ZEUS_DISPLAY displayCtrl CUSTOM_SEARCH_IDC) ctrlShow GVAR(Show);
				(ZEUS_DISPLAY displayCtrl CUSTOM_SEARCH_IDC) ctrlCommit 0;
			};
		}];
		
		if (GVAR(FocusHandlerEnabled)) then {
			_display displayAddEventHandler ["MouseButtonDown", {
				// --- Handle focus on custom search field even if it drawn under zeus ui panels
				params ["_displayorcontrol", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
				
				if (
					_xPos > (GRP_X + CTRL_X) 
					&& { _yPos < (GRP_Y + CTRL_Y + CTRL_H) }
					&& { _xPos < (GRP_X + CTRL_X + CTRL_W) && _yPos > (GRP_Y + CTRL_Y) }
				) then {
					[] spawn {
						uiSleep 0.025;
						ctrlSetFocus (ZEUS_DISPLAY displayCtrl CUSTOM_SEARCH_IDC); 
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
			
			// Stops loop until zeus ui opened
			waituntil {isNull ZEUS_DISPLAY}; 
		};
	};
};