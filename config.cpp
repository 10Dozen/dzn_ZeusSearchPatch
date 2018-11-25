
class CfgPatches
{
	class dzn_ZeusSearchPatch
	{
		units[] = {};
		weapons[] = {};
		magazines[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {"CBA_MAIN"};
		author[] = {"10Dozen"};
		version = "0.4";
	};
};

class Extended_PostInit_EventHandlers
{
	class dzn_ZeusSearchPatch
	{
		init = call compile preprocessFileLineNumbers "\dzn_ZeusSearchPatch\Init.sqf";
	};
};