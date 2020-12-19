#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <fun>

#if AMXX_VERSION_NUM < 183

    #define MAX_PLAYERS 32

#endif

#define PLUGIN_NAME "Furien Mod"
#define PLUGIN_AUTHOR "Filiq_"
#define PLUGIN_VERSION "0.0.2"

#define AF_TEAM CS_TEAM_CT
#define F_TEAM CS_TEAM_T

enum eCvarsSettings {
    cTeamSwitch,
    cAutoTeamSwitch,
    cFurienGravity
}

new 
    fCvars[eCvarsSettings],
    FurienRoundsCount = 0

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    fCvars[cTeamSwitch] = register_cvar("furien_team_switch", "1")
    fCvars[cAutoTeamSwitch] = register_cvar("furien_auto_fteam_switch", "3")
    fCvars[cFurienGravity] = register_cvar("furien_gravity", "0.374")

    register_logevent("Round_Start", 2, "1=Round_Start")
    register_logevent("Round_End", 2, "1=Round_End")

    if(get_pcvar_num(fCvars[cTeamSwitch])) {
        register_event("SendAudio", "RoundWin_AF", "a", "1=0", "2=%!MRAD_ctwin")
        register_event("SendAudio", "RoundWin_F", "a", "1=0", "2=%!MRAD_terwin")
    }

    RegisterHam(Ham_Spawn, "player", "Client_Spawn_Post", true)
}

public Round_Start() {

}

public Round_End() {

}

public RoundWin_AF() {
    new 
        Clients[MAX_PLAYERS],
        NumbersOfClients,
        client 
    
    get_players(Clients, NumbersOfClients)

    for(new i = 0; i < NumbersOfClients; i++) {
        client = Clients[i]

        cs_set_user_team(client, cs_get_user_team(client) == AF_TEAM ? F_TEAM : AF_TEAM)
        // set_pev(client, pev_takedamage, DAMAGE_NO)
    }

    FurienRoundsCount = 0
}

public RoundWin_F() {
    if(FurienRoundsCount++ >= get_pcvar_num(fCvars[cAutoTeamSwitch])) {
        new 
            Clients[MAX_PLAYERS],
            NumbersOfClients,
            client 
        
        get_players(Clients, NumbersOfClients)

        for(new i = 0; i < NumbersOfClients; i++) {
            client = Clients[i]

            cs_set_user_team(client, cs_get_user_team(client) == AF_TEAM ? F_TEAM : AF_TEAM)
            // set_pev(client, pev_takedamage, DAMAGE_NO)
        }
        FurienRoundsCount = 0
    }
}

public Client_Spawn_Post(client) {
    if(!is_user_alive(client))
        return

    if(is_user_bot(client))
        set_pev(client, pev_flags, pev(client, pev_flags) | FL_FROZEN)

    set_user_rendering(client, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)

    strip_user_weapons(client)
    give_item(client, "weapon_knife")
    set_user_footsteps(client, 0)
    set_pev(client, pev_gravity, 1.0)

    switch(cs_get_user_team(client)) {
        case F_TEAM: {
            set_user_footsteps(client, 1)

            set_pev(client, pev_gravity, get_pcvar_float(fCvars[cFurienGravity]))
        }
        case AF_TEAM: {

        }
    }
}