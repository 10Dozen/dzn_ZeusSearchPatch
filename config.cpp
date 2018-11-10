
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
		version = "0.3";
	};
};

class Extended_PostInit_EventHandlers
{
	class dzn_ZeusSearchPatch
	{
		init = "call ('\dzn_ZeusSearchPatch\Init.sqf' call SLX_XEH_COMPILE)";
	};
};