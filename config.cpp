
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
		version = "0.2";
	};
};

class Extended_PreInit_EventHandlers
{
	class dzn_ZeusSearchPatch
	{
		init = "call ('\dzn_ZeusSearchPatch\Init.sqf' call SLX_XEH_COMPILE)";
	};
};