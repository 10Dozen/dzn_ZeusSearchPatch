/*
	dzn_ZeusSearchPatch

*/

#define GVAR(X)	dzn_ZSP_##X

[] spawn {
	waitUntil { !isNull (call BIS_fnc_displayMission) && local player };
	
	GVAR(Enabled) = true;
	GVAR(Show) = true;
	GVAR(fnc_addSearchField) = {
		private _display = (findDisplay 312);
		private _textbox = _display displayCtrl 283;
		private _pos = ctrlPosition _textbox;
		_textbox ctrlShow false;
		_textbox ctrlCommit 0;
		
		#define GRID_X	(((safezoneW / safezoneH) min 1.2) / 40)
		#define GRID_Y	((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
		#define GRP_X		safezoneX + safezoneW - 12.5 * GRID_X
		#define GRP_Y		1.5 * GRID_Y + (safezoneY)
		#define CTRL_X	0.1 * GRID_X - 1 * GRID_X
		#define CTRL_Y	4.1 * GRID_Y
		#define CTRL_W	12.7 * GRID_X + 0.05 * GRID_X
		#define CTRL_H	1 * GRID_Y
		#define CTRL_ID	10
		
		private _newTextbox = _display ctrlCreate ["RscEdit", CTRL_ID];		
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
			
			if (_key == 28) exitWith {
				((findDisplay 312) displayCtrl 283) ctrlSetText (ctrlText _displayorcontrol);
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
			params ["_displayorcontrol", "_key", "_shift", "_ctrl", "_alt"];
			
			if (_key == 14 && !(missionnamespace getvariable ["RscDisplayCurator_search", false])) exitWith {
				GVAR(Show) = !GVAR(Show);
				((findDisplay 312) displayCtrl CTRL_ID) ctrlShow GVAR(Show);
				((findDisplay 312) displayCtrl CTRL_ID) ctrlCommit 0;
			};
		}];
	};
	
	while {true} do {
		if (GVAR(Enabled)) then {
			//waituntil Zeus UI is opened
			waituntil {!(isNull (findDisplay 312))}; 

			[] spawn GVAR(fnc_addSearchField);
			
			waituntil {isNull (findDisplay 312)};
		};
	};
};
