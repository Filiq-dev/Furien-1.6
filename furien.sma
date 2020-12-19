#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <fun>
#include <engine>

#if AMXX_VERSION_NUM < 183

    #define MAX_PLAYERS 32

#endif

#define PLUGIN_NAME "Furien Mod"
#define PLUGIN_AUTHOR "Filiq_"
#define PLUGIN_VERSION "0.0.3"

#define AF_TEAM CS_TEAM_CT
#define F_TEAM CS_TEAM_T

enum eCvarsSettings {
    cTeamSwitch,
    cAutoTeamSwitch,
    cFurienGravity,
    cFurienSpeed 
}

new 
    fCvars[eCvarsSettings],
    FurienRoundsCount = 0,
    gEnt

new 
    Float:tTime

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    fCvars[cTeamSwitch] = register_cvar("furien_team_switch", "1")
    fCvars[cAutoTeamSwitch] = register_cvar("furien_auto_fteam_switch", "3")
    fCvars[cFurienGravity] = register_cvar("furien_gravity", "0.374")
    fCvars[cFurienSpeed] = register_cvar("furien_speed", "700.0")

    register_logevent("Round_Start", 2, "1=Round_Start")
    register_logevent("Round_End", 2, "1=Round_End")

    if(get_pcvar_num(fCvars[cTeamSwitch])) {
        register_event("SendAudio", "RoundWin_AF", "a", "1=0", "2=%!MRAD_ctwin")
        register_event("SendAudio", "RoundWin_F", "a", "1=0", "2=%!MRAD_terwin")
    }

    RegisterHam(Ham_Spawn, "player", "Client_Spawn_Post", true)
    RegisterHam(Ham_Item_PreFrame, "player", "Client_MaxSpeed_Post", true)

    gEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

    if(pev_valid(gEnt)) {
        set_pev(gEnt, pev_classname, "invisibility")
        global_get(glb_time, tTime)
        
        set_pev(gEnt, pev_nextthink, tTime + 0.1)
        register_think("invisibility", "think_Invisibility")
    } 
    else set_task(0.1, "think_Invisibility", .flags="b")
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

public Client_MaxSpeed_Post(client) {
    if(!is_user_alive(client))
        return 

    switch(cs_get_user_team(client)) {
        case F_TEAM: {
            if(fm_get_user_speed(client) != 1.0)
                fm_set_user_speed(client, get_pcvar_float(fCvars[cFurienSpeed]))
        }
    }
}

public think_Invisibility(Ent) {
    if(Ent != gEnt)
        return FMRES_IGNORED

    tTime += 0.1
    entity_set_float(Ent, EV_FL_nextthink, tTime)

    new 
        Clients[MAX_PLAYERS],
        NumbersOfClients,
        client,
        Weapon[MAX_PLAYERS + 1],
        bool:CanBeInvisibile[MAX_PLAYERS + 1],
        Float:Vec[3],
        Speed
    
    get_players(Clients, NumbersOfClients, "ae", "TERRORIST")
    for(new i = 0; i < NumbersOfClients; i++) {
        client = Clients[i]

        Weapon[client] = get_user_weapon(client)
        CanBeInvisibile[client] = bool:(Weapon[client] == CSW_KNIFE)

        if(CanBeInvisibile[client]) {
            entity_get_vector(client, EV_VEC_velocity, Vec)
            Speed = floatround(vector_length(Vec))        

            if(Speed < 255)    
                set_user_rendering(client, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, Speed / 2)
            else
                set_user_rendering(client, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
        } 
        else set_user_rendering(client, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
    }

    return FMRES_IGNORED
}

Float:fm_get_user_speed(client) {
    new Float:Speed 
    
    pev(client, pev_maxspeed, Speed)
    return Speed
}

fm_set_user_speed(client, Float:Speed = -1.0) {
    engfunc(EngFunc_SetClientMaxspeed, client, Speed)
    set_pev(client, pev_maxspeed, Speed)
}