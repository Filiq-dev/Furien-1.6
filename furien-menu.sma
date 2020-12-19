#include <amxmodx>
#include <cstrike>

#include <furien>

#define PLUGIN_NAME "Furien Menu"
#define PLUGIN_AUTHOR "Filiq_"
#define PLUGIN_VERSION "0.0.1"

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    register_clcmd("say /menu", "ShowMenu")
}

public Furien_Spawn_Set(client) {
    ShowMenu(client)
}

public ShowMenu(client) {
    new fMenu = menu_create("Furien Menu:", "Handler_ShowMenu")

    if(cs_get_user_team(client) == F_TEAM)
        menu_additem(fMenu, "Knife")
    else
        menu_additem(fMenu, "Weapons")

    menu_additem(fMenu, "Shop")
    menu_additem(fMenu, "Item")
    menu_additem(fMenu, "Settings")

    menu_display(client, fMenu)
}

public Handler_ShowMenu(client, menu, item) {
    if(!is_user_alive(client)) {
        menu_destroy(menu)
        
        return PLUGIN_HANDLED
    }

    switch(item) {
        case 0: {
            if(cs_get_user_team(client) == F_TEAM) {
                return PLUGIN_HANDLED
            }
            else {
                if(OpenWeaponsMenu(client) == true) {
                    ShowMenu(client)

                    client_print(client, print_chat, "Ai deschid deja meniul de arme o data.")
                } 
            }
        }
    }

    menu_destroy(menu)

    return PLUGIN_HANDLED
}