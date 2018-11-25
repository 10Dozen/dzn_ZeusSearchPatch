// Addon Settings

#define GVAR(X)	dzn_ZSP_##X
#define TITLE		"dzn Zeus Search Patch"

private _add = {
	params ["_var","_desc","_tooltip","_type","_val",["_exp", "No Expression"],["_subcat", ""],["_isGlobal", false]];	
	 
	private _arr = [
		format ["dzn_ZSP_%1", _var]
		, _type
		, [_desc, _tooltip]
		, if (_subcat == "") then { TITLE } else { [TITLE, _subcat] }
		, _val
		, _isGlobal
	];
	
	if !(typename _exp == "STRING" && { _exp == "No Expression" }) then { _arr pushBack _exp; };
	_arr call CBA_Settings_fnc_init;
};

[
	"Enabled"
	, "Enabled"
	, "Enable or disable Zeus Search Patch UI override"
	, "CHECKBOX"
	, true
] call _add;

[
	"FocusHandlerEnabled"
	, "Enable focus on click"
	, "Enables auto-focus on search field when clicking in the field area (even if overlayed with other UI elements)"
	, "CHECKBOX"
	, true
] call _add;

[
	"UseExtraWideField"
	, "Use extra wide search field"
	, "Makes new search field wider than Zeus UI."
	, "CHECKBOX"
	, true
] call _add;