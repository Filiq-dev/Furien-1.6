#include <amxmodx>
#include <cstrike>
#include <fun>

#include <furien>

#if AMXX_VERSION_NUM < 183

    #define MAX_PLAYERS 32

#endif

#define PLUGIN_NAME "Furien Weapons"
#define PLUGIN_AUTHOR "Filiq_"
#define PLUGIN_VERSION "0.0.1"

enum MenuSettings {
    MenuPrimary,
    MenuSecondary
}

enum AFPWSettings
{
	szPWeaponName[MAX_PLAYERS],
	iPWeaponCost,
	szPWeaponIndex[17],
	szPWeaponType,
	iPWeaponBpAmmo
}

new const AntiFurienPWeapons[][AFPWSettings] =
{
	{ "UMP^t^t^t^t^t    \r0$", 0, "weapon_ump45", CSW_UMP45, 250 },
	{ "M3^t^t^t^t^t^t    \r0$", 0, "weapon_m3", CSW_M3, 250 },
	{ "AWP^t^t^t^t    \r15$", 15, "weapon_awp", CSW_AWP,250 },
	{ "MP5^t^t^t^t^t   \r25$", 25, "weapon_mp5navy", CSW_MP5NAVY,250 },
	{ "AK47^t^t^t^t   \r35$", 35, "weapon_ak47", CSW_AK47, 250 },
	{ "M4A1^t^t^t^t   \r35$", 35, "weapon_m4a1", CSW_M4A1, 250 },
	{ "M249^t^t^t^t   \r99$", 99, "weapon_m249", CSW_M249, 250 },
	{ "\y[ExtraVIP] \wFAMAS \r60$", 60, "weapon_famas", CSW_FAMAS, 250 }	
}

enum AFSWSettings
{
	szSWeaponName[MAX_PLAYERS],
	iSWeaponCost,
	szSWeaponIndex[17],
	szSWeaponType,
	iSWeaponBpAmmo
}

new const AntiFurienSWeapons[][AFSWSettings] =
{
	{ "Glock ^t^t^t^t^t^t^t^t\dprice: \r0$", 0, "weapon_glock18", CSW_GLOCK18, 250 },
	{ "USP pistol ^t^t^t^t\dprice: \r5$", 5, "weapon_usp", CSW_USP, 250 },
	{ "FiveseveN  ^t^t^t\dprice: \r5$", 5, "weapon_fiveseven", CSW_FIVESEVEN, 250 },
	{ "Desert Eagle  ^t\dprice: \r15$", 15, "weapon_deagle", CSW_DEAGLE, 250 },
	{ "Elite Duals   ^t^t\dprice: \r20$", 20, "weapon_elite", CSW_ELITE, 250 }
}

new Menus[MenuSettings]

new bool:HasWeapon[MAX_PLAYERS + 1]

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    Menus[MenuPrimary] = menu_create("Anti-Furien Menu \d|| \rPrimary", "Handler_Primary")
    Menus[MenuSecondary] = menu_create("Anti-Furien Menu \d|| \rPistols", "Handler_Secondary")
	
    menu_setprop(Menus[MenuPrimary], MPROP_PERPAGE, 0)
	
    for(new i;i < sizeof AntiFurienPWeapons;i++)
        menu_additem(Menus[MenuPrimary], AntiFurienPWeapons[i][szPWeaponName])
	
    for(new i;i < sizeof AntiFurienSWeapons;i++)
        menu_additem(Menus[MenuSecondary], AntiFurienSWeapons[i][szSWeaponName])
}

public plugin_natives() {
    register_native("OpenWeaponsMenu", "PrimaryMenu")
}

public Furien_Spawn_Set(client) {
    HasWeapon[client] = false
}

public PrimaryMenu() {
    new client = get_param(1)

    if(!is_user_alive(client) || cs_get_user_team(client) != AF_TEAM)
        return true

    if(HasWeapon[client] == true) 
        return true
    
    menu_display(client, Menus[MenuPrimary])

    return false
}

public SecondaryMenu(client) {
    if(!is_user_alive(client) || cs_get_user_team(client) != AF_TEAM)
        return true
    
    menu_display(client, Menus[MenuSecondary])

    return false
}

public Handler_Primary(client, menu, item) {
    if(!is_user_alive(client) || cs_get_user_team(client) != AF_TEAM)
        return true

    if(HasWeapon[client] == true) 
        return true

    client_print(client, print_chat, "ai primit")

    HasWeapon[client] = true
    SecondaryMenu(client)

    give_item(client, AntiFurienPWeapons[item][szPWeaponIndex])
    cs_set_user_bpammo(client, AntiFurienPWeapons[item][szPWeaponType], AntiFurienPWeapons[item][iPWeaponBpAmmo])

    return true
}
public Handler_Secondary(client, menu, item) {
    if(!is_user_alive(client) || cs_get_user_team(client) != AF_TEAM)
        return true

    give_item(client, AntiFurienSWeapons[item][szSWeaponIndex])
    cs_set_user_bpammo(client, AntiFurienSWeapons[item][szSWeaponType], AntiFurienSWeapons[item][iSWeaponBpAmmo])

    return true
}
