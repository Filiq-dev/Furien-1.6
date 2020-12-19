#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <nvault>
#include <hamsandwich>
#include <csx>

#include <furien>

#if AMXX_VERSION_NUM < 183

    #define MAX_PLAYERS 32

#endif

#define PLUGIN_NAME "Furien Money"
#define PLUGIN_AUTHOR "Filiq_"
#define PLUGIN_VERSION "0.0.1"

enum enumCvars {
    cMinPlayers,
    cMoneyKillF,
    cMoneyKillAF,
    cBombPlanted,
    cBombDefused,
    cTeamWin
}

new
    PlayerMoney[MAX_PLAYERS + 1],
    vaultMoney,
    UserName[MAX_PLAYERS + 1][33],
    fCvars[enumCvars]

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    RegisterHam(Ham_Killed, "player", "PlayerDeath", true)

    fCvars[cMinPlayers] = register_cvar("furien_minplayers", "4")
    fCvars[cMoneyKillF] = register_cvar("furien_kill_furien", "15")
    fCvars[cMoneyKillAF] = register_cvar("furien_kill_afurien", "15")
    fCvars[cBombPlanted] = register_cvar("furien_bombplanted", "30")
    fCvars[cBombDefused] = register_cvar("furien_bombdefused", "30")
    fCvars[cTeamWin] = register_cvar("furien_teamwin", "15")

    vaultMoney = nvault_open("FurienMoney")
}

public plugin_end() {
    nvault_close(vaultMoney)
}

public plugin_natives() {
    register_native("SetPlayerMoney", "setPlayerMoney")
    register_native("GetPlayerMoney", "getPlayerMoney")
}

public client_putinserver(client) {
    if(is_user_bot(client))
        return
    
    get_user_name(client, UserName[client], 32)

    LoadData(client)
}

public client_disconnect(client) {
    if(!is_user_bot(client))
        SaveData(client)
}

public LoadData(client) {
    new 
        vaultkey[64],
        vaultdata[256]

    formatex(vaultkey, charsmax(vaultkey), "%s-Furien", UserName[client])
    formatex(vaultdata, charsmax(vaultdata), "%d", PlayerMoney[client])

    nvault_get(vaultMoney, vaultkey, vaultdata, charsmax(vaultdata))

    SetPlayerMoney(client, str_to_num(vaultdata))
}

public SaveData(client) {
    new 
        vaultkey[64],
        vaultdata[256]

    formatex(vaultkey, charsmax(vaultkey), "%s-Furien", UserName[client])
    formatex(vaultdata, charsmax(vaultdata), "%d", PlayerMoney[client])

    nvault_set(vaultMoney, vaultkey, vaultdata)
}

public bomb_defused(client) {
    SetPlayerMoney(client, GetPlayerMoney(client) + get_pcvar_num(fCvars[cBombDefused]))

    client_print(client, print_chat, "Ai primit %d pentru defuse", get_pcvar_num(fCvars[cBombDefused]))
} 

public bomb_planted(client) {
    SetPlayerMoney(client, GetPlayerMoney(client) + get_pcvar_num(fCvars[cBombPlanted]))

    client_print(client, print_chat, "Ai primit %d pentru plant", get_pcvar_num(fCvars[cBombPlanted]))
}

public Furien_Win() {
    new 
        Clients[MAX_PLAYERS],
        NumbersOfClients,
        client 
    
    get_players(Clients, NumbersOfClients, "ae", "TERRORIST")

    for(new i = 0; i < NumbersOfClients; i++) {
        client = Clients[i]

        SetPlayerMoney(client, GetPlayerMoney(client) + get_pcvar_num(fCvars[cTeamWin]))

        client_print(client, print_chat, "Ai primit %d pentru ca echipa ta a castigat", get_pcvar_num(fCvars[cTeamWin]))
    }
}

public AFurien_Win() {
    new 
        Clients[MAX_PLAYERS],
        NumbersOfClients,
        client 
    
    get_players(Clients, NumbersOfClients, "ae", "CT")

    for(new i = 0; i < NumbersOfClients; i++) {
        client = Clients[i]

        SetPlayerMoney(client, GetPlayerMoney(client) + get_pcvar_num(fCvars[cTeamWin]))
    
        client_print(client, print_chat, "Ai primit %d pentru ca echipa ta a castigat", get_pcvar_num(fCvars[cTeamWin]))
    }
}

public Furien_Spawn_Set(client) {
    SetPlayerMoney(client, GetPlayerMoney(client))
}

public PlayerDeath(victim, killer) {
    if(killer == victim || get_playersnum() < get_pcvar_num(fCvars[cMinPlayers]))
        return

    cs_set_user_money(killer, 0)

    SetPlayerMoney(killer, GetPlayerMoney(killer) + (cs_get_user_team(killer) == AF_TEAM ? get_pcvar_num(fCvars[cMoneyKillAF]) : get_pcvar_num(fCvars[cMoneyKillF])))

    client_print(killer, print_chat, "Ai primit %d$ pentru ca l-ai omorat pe %s", cs_get_user_team(killer) == AF_TEAM ? get_pcvar_num(fCvars[cMoneyKillAF]) : get_pcvar_num(fCvars[cMoneyKillF]), UserName[victim])
    client_print(killer, print_chat, "ai %d", PlayerMoney[killer])
}

public setPlayerMoney() {
    new 
        client = get_param(1),
        value = get_param(2)

    if(!is_user_connected(client))
        return

    if((GetPlayerMoney(client) + value) < 16000) cs_set_user_money(client, value)

    PlayerMoney[client] = value
}

public getPlayerMoney() {
    new 
        client = get_param(1)
    
    return PlayerMoney[client]
}