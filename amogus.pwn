/* Amogus system

Можно изменять количество импосторов, 
количество заданий, количество лобби,
скины и цвета игроков, камеры, в общем практически все)

Константы:
	A_MAX_LOBBIES - Количество лобби
	A_MAX_PLAYERS_IN_LOBBY - Сколько всего игроков может быть в лобби (рекомендуется 10)
	A_MAX_TASKS - Всего заданий
	A_MAX_ROOMS - Всего комнат
	A_MAX_TASKS_IN_ROOM - Сколько всего может быть заданий в одной комнате
	A_MAX_SABOTAGES_TYPES - Всего типов саботажей
	A_MAX_CAMERAS - Всего камер
	A_MIN_PLAYER_TO_START - Сколько нужно игроков для запуска игры с вычетом импосторов
	
	A_VOTING_TIME - Количество времени для голосования
	A_SABOTAGE_COOLDOWN - Через сколько времени можно будет снова активировать саботаж импостору
	
	A_CAN_USE_ARROWS - Дает переключать камеры стрелочками
	A_DISABLE_JUMP - Выключает доступ к прыжкам в игре
	
Функции:
	A_SetCameraPanelPos - Устанавливает позицию, где можно смотреть камеры
	A_SetCameraData - Устанавливает камеру
	A_SetPlayersSpawnPlace - Устанавливает позицию игроков, где они стоят во время голосования или спавна (playerid - айди игроков в лобби от 0 то 9)
	A_SetPlayersWaitingPlace - Устанавливает позицию для игроков, где они ждут матч
	A_SetPlayersSkin - Устанавливает скины для игроков во время игры (playerid - айди игроков в лобби от 0 то 9)

 	A_Room_SetName - Устанавливает название комнаты
	A_TaskSetDesc - Устанавливает описание для задания
	A_Room_AddTaskData - Устанавливает информацию для задания в комнате (позиция, тип)
	
	
ТАМ ГДЕ НУЖНО СОЗДАТЬ ЗВУКИ НУЖНО ИСКАТЬ ПО ТАКОМУ КЛЮЧЕВОМУ СЛОВУ:
;;;;;;;;;;;;;

По желанию можно добавить звуки, которые я не добавил туда, где нужно.

Все звуки рекомендую взять из Among Us


*/

main(){}
#include <a_samp>
#undef MAX_PLAYERS
#define MAX_PLAYERS 10
#include <streamer>
#include <YSF>

#define A_INVALID_LOBBY_ID (0xFF)

new bool:A_CAN_USE_ARROWS = true,
	bool:A_DISABLE_JUMP = true;

// Ограничения
const A_MAX_LOBBIES = 3,
	A_MAX_PLAYERS_IN_LOBBY = 10,
	A_MAX_WAITING_PLACES = 1,
	A_MAX_TASKS = 11,
	A_MAX_ROOMS = 15,
	A_MAX_TASKS_IN_ROOM = 5,
	A_MAX_STATE_TEXTDRAWS = 4,
	A_MAX_DATA_TEXTDRAWS = 30,
	A_MAX_STATIC_TEXTDRAWS = 11,
	A_MAX_SABOTAGES_TYPES = 2,
	A_MAX_CAMERAS = 24,
	A_MAX_VOTING_TEXTDRAWS = (A_MAX_PLAYERS_IN_LOBBY*4)+6,
	A_MIN_PLAYERS_TO_START = 3, // 3 значит 4 игрока нужно если 1 импостор

// Информация
	A_VOTING_TIME = 60,
	A_SABOTAGE_COOLDOWN = 120,
	A_KILL_COOLDOWN = 15,
	A_END_MATCH = 2,
 	A_TASK_DONE = 55555,

// Указатели текстдравов
 	A_STATE_TEXTDRAW_TYPE=1,
	A_DATA_TEXTDRAW_TYPE=2,
	A_STATIC_TEXTDRAW_TYPE=3,
	A_VOTE_TEXTDRAW_TYPE=4,

// Статус игрока
	A_STATE_NULL=0,
	A_STATE_WAITING=1,
	A_STATE_PLAYING=2,
	A_STATE_SPECTATE=3,

// Указатели комнат
	A_ROOM_NULL=0,
	A_ROOM_DININGROOM=1,
	A_ROOM_MEDIC=2,
	A_ROOM_MOTOR1=3,
	A_ROOM_MOTOR2=4,
	A_ROOM_REACTOR=5,
	A_ROOM_SECURITY=6,
	A_ROOM_ELECTROSHIELD=7,
	A_ROOM_WAREHOUSE=8,
	A_ROOM_CONNECTION=9,
	A_ROOM_CONTROL=10,
	A_ROOM_SHIELDS=11,
	A_ROOM_NAVIGATION=12,
	A_ROOM_O2=13,
	A_ROOM_WEAPON=14,

// Указатели заданий
	A_TASK_NULL=0,
	A_TASK_KEYCARD=1,

// Указатели действий
 	A_EVENT_STATE_CLICK=1,
	A_EVENT_INTERNAL_UPDATE=2,
// Указатели ивентов
 	A_EVENT_NEAR_BODY=50,
	A_EVENT_NEAR_PLAYER=51,
	A_EVENT_NEAR_TASK=52,
	A_EVENT_CANT_USE=53,
	A_EVENT_BUTTONS=54,
	A_EVENT_EXIT=55,
	A_EVENT_VOTING=56,
 	A_EVENT_SABOTAGE=57,
	A_EVENT_MAIN_PLAYER=58,
	A_EVENT_LOBBY=59,
	A_EVENT_NEAR_CAMERA=60,
	A_EVENT_NEAR_SABOTAGE_DISABLE=61,
//Указатели ивентов для заданий
 	A_EVENT_NULL=0,
 	A_EVENT_KEYCARD=1,
	A_EVENT_ASTEROID=2,
	A_EVENT_DOWNLOAD=3,
	A_EVENT_UPLOAD=4,
	A_EVENT_MEDSCAN=5,
 	A_EVENT_TRASH=6,
 	A_EVENT_GIVE_ENERGY=7,
 	A_EVENT_SLIDE_ENERGY=8,
	A_EVENT_WIRE=9,
	A_EVENT_FUEL_MOTOR=10,
	A_EVENT_FUEL_ENGINE=11,
//Указатели саботажей
	A_SABOTAGE_LIGHT=0,
	A_SABOTAGE_REACTOR=1;

enum Amogus_System
{
	APlayers[A_MAX_PLAYERS_IN_LOBBY],
	ADeadBodies[A_MAX_PLAYERS_IN_LOBBY],
	AMaxImpostors,
	ATimer,
	AMainPlayer,
	APlayersCount,
	ADeadCount,
	AImpostorsDeadCount,
	AImpostorsCount,
	AMaxTasks,
	ATasksSuccessed,
	AVotingTimer,
	bool:AMatchIsStart,
	bool:AStarted,
	AGlobalState,
	ASabotageMapIcon[2],
	AVoteButtonTimer,
	AVoteSkips,
	AVotePlayersCount
}

new global_str[250];

enum Amogus_Rooms
{
	ARoomTasksCount,
	ARoomTaskType[A_MAX_TASKS_IN_ROOM],
	Float:ARoomTaskPlaceX[A_MAX_TASKS_IN_ROOM],
	Float:ARoomTaskPlaceY[A_MAX_TASKS_IN_ROOM],
	Float:ARoomTaskPlaceZ[A_MAX_TASKS_IN_ROOM],
	ARoomName[20]
}
new A_Lobby[A_MAX_LOBBIES][Amogus_System];
new A_Rooms[A_MAX_ROOMS][Amogus_Rooms];
new Float:A_CameraPanelPos[3];
new Float:A_Camera[A_MAX_CAMERAS][6];
new Float:A_Voting_Place[A_MAX_PLAYERS_IN_LOBBY][4];
new Float:A_Waiting_Place[3];
new A_Skins[A_MAX_PLAYERS_IN_LOBBY];

new AEventTasksDesc[50][40];

enum PlayerStat
{
	ALobby,
	bool:AIsImpostor,
	bool:AIsDead,
	bool:AIsSpectating,
	bool:AUsedReport,
	AEventState,
	AEventData,
	AEventDataTimer,
	AEventDataTicks,
	ACurrentEvent,
	PlayerText:AEventDataTextdraws[A_MAX_DATA_TEXTDRAWS],
	PlayerText:AEventStateTextdraws[A_MAX_STATE_TEXTDRAWS],
	PlayerText:AStaticTextdraws[A_MAX_STATIC_TEXTDRAWS],
	PlayerText:AVotingTextdraws[A_MAX_VOTING_TEXTDRAWS],
	APreviousClickedVoteTextdraw,
	AStaticTimer,
	ATasks[A_MAX_TASKS],
	ATasksState[A_MAX_TASKS],
	ATasksRoom[A_MAX_TASKS],
	ASabotageTimer,
	APreviousSkin,
	APreviousColor,
	AVotesCount,
	AKeysUpdate,
	AKillCooldown
}
new Player[MAX_PLAYERS][PlayerStat];

stock Float:frand(Float:min, Float:max) return float(random(0)) / (float(cellmax) / (max - min)) + min; 

public OnGameModeInit()
{
	SetGameModeText("Among US");
	for(new i; i < A_MAX_LOBBIES; i++)
	{
		for(new a; a < A_MAX_PLAYERS_IN_LOBBY; a++) 
		{
			A_Lobby[i][APlayers][a] = INVALID_PLAYER_ID;
			A_Lobby[i][ADeadBodies][a] = INVALID_ACTOR_ID;
		}
		A_ClearLobby(i);
	}

	A_Room_SetName(A_ROOM_DININGROOM, "Столовая");
	A_Room_SetName(A_ROOM_MEDIC, "Медпункт");
	A_Room_SetName(A_ROOM_MOTOR1, "Мотор №1");
	A_Room_SetName(A_ROOM_MOTOR2, "Мотор №2");
	A_Room_SetName(A_ROOM_REACTOR, "Реактор");
	A_Room_SetName(A_ROOM_SECURITY, "Охрана");
	A_Room_SetName(A_ROOM_ELECTROSHIELD, "Электрощитовая");
	A_Room_SetName(A_ROOM_WAREHOUSE, "Склад");
	A_Room_SetName(A_ROOM_CONNECTION, "Связь");
	A_Room_SetName(A_ROOM_CONTROL, "Управление");
	A_Room_SetName(A_ROOM_SHIELDS, "Щиты");
	A_Room_SetName(A_ROOM_NAVIGATION, "Навигация");
	A_Room_SetName(A_ROOM_O2, "О2");
	A_Room_SetName(A_ROOM_WEAPON, "Оружейная");

	A_TaskSetDesc(A_EVENT_ASTEROID, "Разрушить астероиды");
	A_TaskSetDesc(A_EVENT_UPLOAD, "Загрузить данные");
	A_TaskSetDesc(A_EVENT_DOWNLOAD, "Скачать данные");
	A_TaskSetDesc(A_EVENT_KEYCARD, "Проведите картой");
	A_TaskSetDesc(A_EVENT_MEDSCAN, "Пройти сканирование");
	A_TaskSetDesc(A_EVENT_TRASH, "Выбросить мусор");
	A_TaskSetDesc(A_EVENT_GIVE_ENERGY, "Подать энергию");
	A_TaskSetDesc(A_EVENT_SLIDE_ENERGY, "Проведите энергию");
	A_TaskSetDesc(A_EVENT_WIRE, "Починить проводку");
	A_TaskSetDesc(A_EVENT_FUEL_ENGINE, "Заправьте двигатели");
	A_TaskSetDesc(A_EVENT_FUEL_MOTOR, "Заправить мотор");
	
	//AddTaskData обязательно должен быть после SetDesc
	A_Room_AddTaskData(A_ROOM_WEAPON, A_EVENT_ASTEROID, 925.1812,-899.1889,1101.2266);
	A_Room_AddTaskData(A_ROOM_DININGROOM, A_EVENT_DOWNLOAD, 896.15186, -890.82648, 1101.71033);
	A_Room_AddTaskData(A_ROOM_ELECTROSHIELD, A_EVENT_UPLOAD, 894.78284, -909.63379, 1101.26770);
	A_Room_AddTaskData(A_ROOM_CONNECTION, A_EVENT_UPLOAD, 905.94397, -913.25891, 1100.84814);
	A_Room_AddTaskData(A_ROOM_CONTROL, A_EVENT_UPLOAD, 908.97925, -901.73505, 1101.26770);
	A_Room_AddTaskData(A_ROOM_NAVIGATION, A_EVENT_UPLOAD, 925.09802, -898.08325, 1100.70056);
	A_Room_AddTaskData(A_ROOM_CONTROL, A_EVENT_KEYCARD, 907.27716, -906.74097, 1100.70056);
	A_Room_AddTaskData(A_ROOM_MEDIC, A_EVENT_MEDSCAN, 896.45190, -900.68890, 1100.32202);
	A_Room_AddTaskData(A_ROOM_DININGROOM, A_EVENT_TRASH, 908.03558, -889.69415, 1101.75391);
	A_Room_AddTaskData(A_ROOM_WAREHOUSE, A_EVENT_TRASH, 903.41162, -915.22693, 1101.75391);
	A_Room_AddTaskData(A_ROOM_O2, A_EVENT_TRASH, 909.07996, -898.27289, 1101.75391);
	
	A_Room_AddTaskData(A_ROOM_MOTOR1, A_EVENT_GIVE_ENERGY, 884.86414, -896.10754, 1100.86902);
	A_Room_AddTaskData(A_ROOM_MOTOR2, A_EVENT_GIVE_ENERGY, 884.86414, -905.80597, 1100.86902);
	A_Room_AddTaskData(A_ROOM_SECURITY, A_EVENT_GIVE_ENERGY, 886.90497, -902.85730, 1101.50842);
	A_Room_AddTaskData(A_ROOM_SHIELDS, A_EVENT_GIVE_ENERGY, 911.67499, -910.99371, 1101.92322);
	A_Room_AddTaskData(A_ROOM_O2, A_EVENT_GIVE_ENERGY, 910.11420, -896.66040, 1102.22339);
	A_Room_AddTaskData(A_ROOM_WEAPON, A_EVENT_GIVE_ENERGY, 917.10132, -891.37561, 1101.45789);
	
	A_Room_AddTaskData(A_ROOM_ELECTROSHIELD, A_EVENT_SLIDE_ENERGY, 897.19757, -907.83795, 1102.22339);
	A_Room_AddTaskData(A_ROOM_CONNECTION, A_EVENT_SLIDE_ENERGY, 907.03082, -911.61505, 1101.23694);
	A_Room_AddTaskData(A_ROOM_CONTROL, A_EVENT_SLIDE_ENERGY, 910.6620,-902.7797,1101.2266);
	A_Room_AddTaskData(A_ROOM_NAVIGATION, A_EVENT_SLIDE_ENERGY, 924.44916, -897.33618, 1102.38733);
	
	A_Room_AddTaskData(A_ROOM_DININGROOM, A_EVENT_WIRE, 909.12744, -895.34692, 1101.45789);
	A_Room_AddTaskData(A_ROOM_SECURITY, A_EVENT_WIRE, 884.63116, -899.72888, 1101.21606);
	A_Room_AddTaskData(A_ROOM_ELECTROSHIELD, A_EVENT_WIRE, 897.56207, -902.54883, 1101.21606);
	A_Room_AddTaskData(A_ROOM_WAREHOUSE, A_EVENT_WIRE, 900.81378, -904.91980, 1101.21606);
	A_Room_AddTaskData(A_ROOM_CONTROL, A_EVENT_WIRE, 904.95673, -901.61914, 1101.21606);
	A_Room_AddTaskData(A_ROOM_NAVIGATION, A_EVENT_WIRE, 922.52795, -897.32257, 1101.21606);
	
	A_Room_AddTaskData(A_ROOM_WAREHOUSE, A_EVENT_FUEL_ENGINE, 902.44824, -912.61096, 1100.45471);
	A_Room_AddTaskData(A_ROOM_MOTOR1, A_EVENT_FUEL_MOTOR, 881.05780, -892.20990, 1101.16284);
	A_Room_AddTaskData(A_ROOM_MOTOR2, A_EVENT_FUEL_MOTOR, 881.17676, -909.73730, 1101.16284);
	
	// Временные задания, поэтому добавляем отдельно
	CreateDynamic3DTextLabel("{FFFFFF}[ Электрощитовая ]\n\n{AFAFAF}Включить свет", -1, 893.0752,-907.0934,1101.2266, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID);
	CreateDynamic3DTextLabel("{FFFFFF}[ Реактор ]\n\n{AFAFAF}Охладить реактор", -1, 877.6080,-901.2388,1101.2188, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID);
	//
	
	A_SetPlayersSpawnPlace(0, 902.3615,-895.1793,1101.2266,359.9998);
	A_SetPlayersSpawnPlace(1, 903.1228,-894.8716,1101.2266,25.3800);
	A_SetPlayersSpawnPlace(2, 903.8695,-894.0846,1101.2266,48.2536);
	A_SetPlayersSpawnPlace(3, 904.2944,-893.1671,1101.2266,77.0805);
	A_SetPlayersSpawnPlace(4, 904.2749,-892.0009,1101.2266,102.7741);
	A_SetPlayersSpawnPlace(5, 903.1086,-890.8124,1101.2266,156.3546);
	A_SetPlayersSpawnPlace(6, 901.9787,-890.8012,1101.2266,188.6282);
	A_SetPlayersSpawnPlace(7, 900.8037,-891.3620,1101.2266,227.4819);
	A_SetPlayersSpawnPlace(8, 900.3306,-892.6855,1101.2266,268.5290);
	A_SetPlayersSpawnPlace(9, 900.9784,-894.2524,1101.2266,310.5160);
	A_SetPlayersSkin(0, 1);
	A_SetPlayersSkin(1, 2);
	A_SetPlayersSkin(2, 3);
	A_SetPlayersSkin(3, 4);
	A_SetPlayersSkin(4, 5);
	A_SetPlayersSkin(5, 6);
	A_SetPlayersSkin(6, 7);
	A_SetPlayersSkin(7, 8);
	A_SetPlayersSkin(8, 9);
	A_SetPlayersSkin(9, 10);
	A_SetCameraData(0, 896.519, -894.105, 1102.868, 901.66705, -893.92596, 1101.28577);
	A_SetCameraData(1, 921.966, -898.385, 1102.914, 923.78241, -898.93658, 1102.01587);
	A_SetCameraData(2, 891.576, -907.095, 1102.863, 893.22754, -907.94989, 1102.31946);
	A_SetCameraData(3, 907.688, -899.175, 1102.861, 909.20093, -899.19373, 1102.21863);
	A_SetCameraData(4, 912.03, -891.45, 1102.865, 913.02008, -892.03760, 1102.48560);
	A_SetCameraData(5, 914.88, -889.525, 1102.861, 914.06470, -891.40625, 1102.11523);
	A_SetCameraData(6, 885.044, -894.291, 1102.877, 884.07184, -893.06232, 1102.31067);
	A_SetCameraData(7, 884.92224, -890.46191, 1102.86768, 883.96375, -891.89349, 1102.39832);
	A_SetCameraData(8, 890.84277, -901.58246, 1102.86768, 892.81104, -899.88196, 1101.97131);
	A_SetCameraData(9, 885.08557, -907.62372, 1102.86768, 884.01868, -908.91327, 1102.34875);
	A_SetCameraData(10, 884.53802, -911.50391, 1102.86768, 884.02307, -910.43451, 1102.51929);
	A_SetCameraData(11, 877.99725, -905.47192, 1102.86768, 877.92462, -904.04614, 1102.53113);
	A_SetCameraData(12, 910.80719, -913.70520, 1102.86768, 908.82599, -913.76477, 1101.99854);
	A_SetCameraData(13, 918.35217, -910.11224, 1102.86768, 915.83759, -911.03473, 1102.09253);
	A_SetCameraData(14, 915.61951, -913.39600, 1102.86768, 915.58337, -912.31903, 1102.59119);
	A_SetCameraData(15, 889.26642, -902.92310, 1102.86768, 888.35559, -901.80377, 1102.45166);
	A_SetCameraData(16, 899.72522, -915.83783, 1102.86768, 899.53522, -914.49835, 1102.53650);
	A_SetCameraData(17, 907.96545, -911.61304, 1102.86768, 908.54083, -913.85114, 1101.99231);
	A_SetCameraData(18, 898.61786, -904.44165, 1102.86768, 895.49683, -904.58051, 1101.99146);
	A_SetCameraData(19, 901.19922, -899.97815, 1102.86768, 901.33228, -898.72638, 1102.65955);
	A_SetCameraData(20, 897.35706, -901.11877, 1102.70129, 891.39722, -898.37512, 1100.80017);
	A_SetCameraData(21, 905.06177, -907.92242, 1102.86768, 905.89551, -906.89264, 1102.49988);
	A_SetCameraData(22, 904.11536, -905.00366, 1102.86768, 903.36700, -906.37012, 1102.53540);
	A_SetCameraData(23, 912.54175, -902.54590, 1102.86768, 910.62982, -903.43732, 1102.36194);
	A_SetPlayersWaitingPlace(902.3615,-895.1793,1101.2266);
	A_SetCameraPanelPos(887.6718,-898.5905,1101.2266);
	
	SetTimer("AmongUs", 1000, 1);
	return 1;
}
forward AmongUs();
public AmongUs()
{
	for(new i; i < A_MAX_LOBBIES; i++) A_Update(i);
}
public OnPlayerConnect(playerid)
{
	SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	Player[playerid][ALobby] = A_INVALID_LOBBY_ID;
	for(new i; i < A_MAX_DATA_TEXTDRAWS; i++) Player[playerid][AEventDataTextdraws][i] = PlayerText:INVALID_TEXT_DRAW;
	for(new i; i < A_MAX_STATE_TEXTDRAWS; i++) Player[playerid][AEventStateTextdraws][i] = PlayerText:INVALID_TEXT_DRAW;
	for(new i; i < A_MAX_STATIC_TEXTDRAWS; i++) Player[playerid][AStaticTextdraws][i] = PlayerText:INVALID_TEXT_DRAW;
	for(new i; i < A_MAX_VOTING_TEXTDRAWS; i++) Player[playerid][AVotingTextdraws][i] = PlayerText:INVALID_TEXT_DRAW;
	Player[playerid][APreviousClickedVoteTextdraw] = -1;
}
public OnPlayerDisconnect(playerid, reason)
{
	if(Player[playerid][ALobby] != A_INVALID_LOBBY_ID) A_PlayerChangeState(playerid, Player[playerid][ALobby], A_STATE_NULL);
}

public OnPlayerSpawn(playerid)
{
	SetPlayerPos(playerid, 904.7440,-892.4892,1101.2266);
	SetPlayerInterior(playerid, 2);
	
	if(Player[playerid][ALobby] != A_INVALID_LOBBY_ID && Player[playerid][AIsSpectating])
	{
		SetPlayerPos(playerid, A_CameraPanelPos[0], A_CameraPanelPos[1], A_CameraPanelPos[2]);
		SetPlayerVirtualWorld(playerid, Player[playerid][ALobby]);
		for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
		{
			if(A_Lobby[Player[playerid][ALobby]][APlayers][i] == playerid)
			{
				SetPlayerSkin(playerid, A_Skins[i]);
				break;
			}
		}
		Player[playerid][AEventData]=0;
		Player[playerid][AIsSpectating] = false;
		Player[playerid][AEventDataTicks] = 0;
		CancelSelectTextDraw(playerid);
	}
}

public OnPlayerUpdate(playerid)
{
	if(A_CAN_USE_ARROWS)
	{
		if(Player[playerid][ALobby] != A_INVALID_LOBBY_ID && Player[playerid][AKeysUpdate] < GetTickCount() && Player[playerid][AIsSpectating])
		{
			new Keys, rl;
			GetPlayerKeys(playerid, Keys, Keys, rl);
			
			if(rl == KEY_LEFT) A_PlayerEvent(playerid, Player[playerid][ALobby], Player[playerid][ACurrentEvent], A_EVENT_STATE_CLICK, Player[playerid][AEventStateTextdraws][1]);
			else if(rl == KEY_RIGHT) A_PlayerEvent(playerid, Player[playerid][ALobby], Player[playerid][ACurrentEvent], A_EVENT_STATE_CLICK, Player[playerid][AEventStateTextdraws][2]);
			
			Player[playerid][AKeysUpdate] = GetTickCount()+100;
		}
	}
	return 1;
}

stock A_SetCameraPanelPos(Float:X, Float:Y, Float:Z)
{
	A_CameraPanelPos[0] = X;
	A_CameraPanelPos[1] = Y;
	A_CameraPanelPos[2] = Z;
}
stock A_SetCameraData(cameraid, Float:X, Float:Y, Float:Z, Float:Xto, Float:Yto, Float:Zto)
{
	A_Camera[cameraid][0] = X;
	A_Camera[cameraid][1] = Y;
	A_Camera[cameraid][2] = Z;
	A_Camera[cameraid][3] = Xto;
	A_Camera[cameraid][4] = Yto;
	A_Camera[cameraid][5] = Zto;
}
stock A_IsMatchStarted(lobbyid) return A_Lobby[lobbyid][AMatchIsStart];
stock A_IsVotingTime(lobbyid) return (A_Lobby[lobbyid][AVotingTimer] > gettime());
stock A_SetPlayersSpawnPlace(playerid, Float:X, Float:Y, Float:Z, Float:Angle) 
{
	A_Voting_Place[playerid][0] = X;
	A_Voting_Place[playerid][1] = Y;
	A_Voting_Place[playerid][2] = Z;
	A_Voting_Place[playerid][3] = Angle;
}
stock A_SetPlayersWaitingPlace(Float:X, Float:Y, Float:Z) 
{
	A_Waiting_Place[0] = X;
	A_Waiting_Place[1] = Y;
	A_Waiting_Place[2] = Z;
}
stock A_SetPlayersSkin(playerid, skin) A_Skins[playerid] = skin;

stock A_Room_SetName(roomid, roomname[20]) SetString(A_Rooms[roomid][ARoomName], roomname);
#define A_Room_GetName(%0) A_Rooms[%0][ARoomName]

stock A_TaskSetDesc(taskeventid, const taskdesc[]) SetString(AEventTasksDesc[taskeventid], taskdesc);
#define A_TaskGetDesc(%0) AEventTasksDesc[%0]

stock A_Room_AddTaskData(roomid, tasktype, Float:X, Float:Y, Float:Z)
{
	if(A_Rooms[roomid][ARoomTasksCount] >= A_MAX_TASKS_IN_ROOM) return 0;
	A_Rooms[roomid][ARoomTaskType][A_Rooms[roomid][ARoomTasksCount]] = tasktype;
	A_Rooms[roomid][ARoomTaskPlaceX][A_Rooms[roomid][ARoomTasksCount]] = X;
	A_Rooms[roomid][ARoomTaskPlaceY][A_Rooms[roomid][ARoomTasksCount]] = Y;
	A_Rooms[roomid][ARoomTaskPlaceZ][A_Rooms[roomid][ARoomTasksCount]] = Z;
	A_Rooms[roomid][ARoomTasksCount]++;
	
	CreateDynamicMapIcon(X, Y, Z, 0, 0xFFFFFFFF);
	
	format(global_str, 144, "{FFFFFF}[ %s ]\n\n{AFAFAF}%s", A_Room_GetName(roomid), A_TaskGetDesc(tasktype));
	CreateDynamic3DTextLabel(global_str, -1, X, Y, Z, 3.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID);
	return 1;
}

stock A_StartSabotage(lobbyid, sabotagetype)
{
	switch(sabotagetype)
	{
		case A_SABOTAGE_LIGHT:
		{
			for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
			{
				if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID) 
				{
					SendClientMessage(A_Lobby[lobbyid][APlayers][i], 0xFF0000FF, "( Саботаж ) {FFFFFF}В комплексе произошел сбой со светом! Вам нужно включить свет!");
					
					if(!Player[A_Lobby[lobbyid][APlayers][i]][AIsImpostor] && !Player[A_Lobby[lobbyid][APlayers][i]][AIsDead]) 
					{
						SetPlayerTime(A_Lobby[lobbyid][APlayers][i], 0, 0);
						PlayerTextDrawShow(A_Lobby[lobbyid][APlayers][i], Player[A_Lobby[lobbyid][APlayers][i]][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-3]);
					}
				}
			}
			A_Lobby[lobbyid][AGlobalState] = 1;
			A_Lobby[lobbyid][ASabotageMapIcon][sabotagetype] = CreateDynamicMapIcon(893.0752,-907.0934,1101.2266, 0, 0xFF0000FF, lobbyid+2); // Делаем иконку саботажа на радаре, в определенном вирт мире
		}
		case A_SABOTAGE_REACTOR:
		{
			for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
			{
				if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID) 
				{
					SendClientMessage(A_Lobby[lobbyid][APlayers][i], 0xFF0000FF, "( Саботаж ) {FFFFFF}В комплексе перегрелся реактор! Скорее охладите его! У вас есть примерно 15 секунд!");
					SetTimerEx("A_SabotageEvent", random(3000)+14000, 0, "dd", lobbyid, sabotagetype);
					//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Длительный звук саботажа реактора (5 сек)
				}
			}
			A_Lobby[lobbyid][AGlobalState] = 2;
			A_Lobby[lobbyid][ASabotageMapIcon][sabotagetype] = CreateDynamicMapIcon(877.6080,-901.2388,1101.2188, 0, 0xFF0000FF, lobbyid+2); // Делаем иконку саботажа на радаре, в определенном вирт мире
		}
	}
}
stock A_StartVoting(lobbyid)
{
	for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
	{
		if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID) 
		{
			if(!Player[A_Lobby[lobbyid][APlayers][i]][AIsDead])
			{
				A_PlayerChangeState(A_Lobby[lobbyid][APlayers][i], lobbyid, A_STATE_PLAYING, 0);
				//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Звук репорта PlayerPlaySound(A_Lobby[lobbyid][APlayers][i], 3201, 0.0, 0.0, 0.0);
				PlayerTextDrawHide(A_Lobby[lobbyid][APlayers][i], Player[A_Lobby[lobbyid][APlayers][i]][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-3]);
				
				A_CreateVotingForPlayer(A_Lobby[lobbyid][APlayers][i], lobbyid);
				SelectTextDraw(A_Lobby[lobbyid][APlayers][i], 0xAFAFAFFF);
			}
		}
	}
	A_Lobby[lobbyid][AVotingTimer] = gettime()+A_VOTING_TIME;
}

stock A_ClearLobby(lobbyid, bool:OnlyBodies = false)
{
	if(!OnlyBodies)
	{
		A_Lobby[lobbyid][AMainPlayer] = INVALID_PLAYER_ID;
		A_Lobby[lobbyid][APlayersCount] = 0;
		A_Lobby[lobbyid][ATasksSuccessed] = 0;
		A_Lobby[lobbyid][AVotingTimer] = 0;
		A_Lobby[lobbyid][ATimer] = 0;
		A_Lobby[lobbyid][AGlobalState] = 0;
		A_Lobby[lobbyid][AStarted] = false;
		A_Lobby[lobbyid][AMatchIsStart] = false;
		A_Lobby[lobbyid][AImpostorsDeadCount] = 0;
		A_Lobby[lobbyid][ADeadCount] = 0;
		A_Lobby[lobbyid][AVotePlayersCount] = 0;
		A_Lobby[lobbyid][AVoteSkips] = 0;
		for(new i; i < A_MAX_SABOTAGES_TYPES; i++)
		{
			if(A_Lobby[lobbyid][ASabotageMapIcon][i] != 0)
			{
				DestroyDynamicMapIcon(A_Lobby[lobbyid][ASabotageMapIcon][i]);
				A_Lobby[lobbyid][ASabotageMapIcon][i] = 0;
			}
		}
		for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
		{
			if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID) 
			{
				for(new a; a < A_MAX_TASKS; a++)
				{
					Player[A_Lobby[lobbyid][APlayers][i]][ATasks][a] = 0;
					Player[A_Lobby[lobbyid][APlayers][i]][ATasksRoom][a] = 0;
					Player[A_Lobby[lobbyid][APlayers][i]][ATasksState][a] = 0;
				}
				Player[A_Lobby[lobbyid][APlayers][i]][AIsImpostor] = false;
				Player[A_Lobby[lobbyid][APlayers][i]][AIsDead] = false;
				Player[A_Lobby[lobbyid][APlayers][i]][AIsSpectating] = false;
				Player[A_Lobby[lobbyid][APlayers][i]][ASabotageTimer] = 0;
				Player[A_Lobby[lobbyid][APlayers][i]][AEventDataTimer] = 0;
				Player[A_Lobby[lobbyid][APlayers][i]][AEventDataTicks] = 0;
				Player[A_Lobby[lobbyid][APlayers][i]][AStaticTimer] = 0;
				Player[A_Lobby[lobbyid][APlayers][i]][AVotesCount] = 0;
				Player[A_Lobby[lobbyid][APlayers][i]][AUsedReport] = false;
				Player[A_Lobby[lobbyid][APlayers][i]][AKillCooldown] = 0;
				Player[A_Lobby[lobbyid][APlayers][i]][APreviousClickedVoteTextdraw] = -1;
				A_Lobby[lobbyid][APlayers][i] = INVALID_PLAYER_ID;
			}
		}
	}
	for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
	{
		if(A_Lobby[lobbyid][ADeadBodies][i] != INVALID_ACTOR_ID)
		{
			DestroyActor(A_Lobby[lobbyid][ADeadBodies][i]);
			A_Lobby[lobbyid][ADeadBodies][i] = INVALID_ACTOR_ID;
		}
	}
	return 1;
}
stock A_PlayerAddTask(playerid, id, task)
{
	// Определяем случайную комнату для задания
	new ARoomMass[A_MAX_ROOMS];
	new ARoomsCount=0;
	for(new i; i < A_MAX_ROOMS; i++)
	{
		for(new a; a < A_Rooms[i][ARoomTasksCount]; a++)
		{
			if(A_Rooms[i][ARoomTaskType][a] == task)
			{
				ARoomMass[ARoomsCount] = i;
				ARoomsCount++;
				break;
			}
		}
	}
	if(ARoomsCount != 0) 
	{
		Player[playerid][ATasksRoom][id] = ARoomMass[random(ARoomsCount)];
		for(new a; a < A_Rooms[Player[playerid][ATasksRoom][id]][ARoomTasksCount]; a++)
		{
			if(A_Rooms[Player[playerid][ATasksRoom][id]][ARoomTaskType][a] == task)
			{	
				Player[playerid][ATasks][id] = a;
				break;
			}
		}
		return 1;
	}
	return 0;
}
stock A_GoCameras(playerid, cameraid)
{
	TogglePlayerSpectating(playerid, true);
	InterpolateCameraPos(playerid, A_Camera[cameraid][0], A_Camera[cameraid][1], A_Camera[cameraid][2], A_Camera[cameraid][0], A_Camera[cameraid][1], A_Camera[cameraid][2], 100);
	InterpolateCameraLookAt(playerid, A_Camera[cameraid][3], A_Camera[cameraid][4], A_Camera[cameraid][5], A_Camera[cameraid][3], A_Camera[cameraid][4], A_Camera[cameraid][5], 100);
}
stock A_PlayerChangeState(playerid, lobbyid, astate, comma = 0)
{
	switch(astate)
	{
		case A_STATE_WAITING:
		{
			SetPlayerTime(playerid, 17, 0);
			SetPlayerPos(playerid, A_Waiting_Place[0], A_Waiting_Place[1], A_Waiting_Place[2]);
			SetPlayerVirtualWorld(playerid, lobbyid+2);
			Player[playerid][APreviousSkin] = GetPlayerSkin(playerid);
			Player[playerid][APreviousColor] = GetPlayerColor(playerid);
			SetPlayerColor(playerid, 0xFFFFFF00);
			for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
			{
				if(A_Lobby[lobbyid][APlayers][i] == playerid)
				{
					SetPlayerSkin(playerid, A_Skins[i]);
					break;
				}
			}
		}
		case A_STATE_PLAYING:
		{
			SetPlayerTime(playerid, 17, 0);
			for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
			{
				if(A_Lobby[lobbyid][APlayers][i] == playerid)
				{
					SetPlayerPos(playerid, A_Voting_Place[i][0], A_Voting_Place[i][1], A_Voting_Place[i][2]);
					SetPlayerFacingAngle(playerid, A_Voting_Place[i][3]);
					TogglePlayerControllable(playerid, !!comma);
					/*for(new a; a < A_MAX_PLAYERS_IN_LOBBY; a++) // Скрываем теги игроков
					{
						if(A_Lobby[lobbyid][APlayers][a] != INVALID_PLAYER_ID && a != i) 
						{
							ShowPlayerNameTagForPlayer(A_Lobby[lobbyid][APlayers][i], A_Lobby[lobbyid][APlayers][a], 0);
							ShowPlayerNameTagForPlayer(A_Lobby[lobbyid][APlayers][a], A_Lobby[lobbyid][APlayers][i], 0);
						}
					}*/
					break;
				}
			}
			if(comma == A_END_MATCH || comma == A_END_MATCH+99)
			{
				// Определяем выиграл ли игрок и показываем ему
				if(comma == A_END_MATCH+99) 
				{
					Player[playerid][AEventData] = !Player[playerid][AIsImpostor];
					SendClientMessage(playerid, 0xAFAFAFFF, "( Игра ) {FFFFFF}Персонал выполнил все задания, игра закончена.");
				}
				else if(A_Lobby[lobbyid][AImpostorsDeadCount] >= A_Lobby[lobbyid][AMaxImpostors]) 
				{
					Player[playerid][AEventData] = !Player[playerid][AIsImpostor];
					SendClientMessage(playerid, 0xAFAFAFFF, "( Игра ) {FFFFFF}Все предатели мертвы, игра закончена.");
				}
				else if(A_Lobby[lobbyid][ADeadCount] >= A_Lobby[lobbyid][APlayersCount]-A_Lobby[lobbyid][AMaxImpostors] || A_Lobby[lobbyid][APlayersCount]-A_Lobby[lobbyid][ADeadCount]-A_Lobby[lobbyid][AMaxImpostors] < 2) 
				{
					Player[playerid][AEventData] = Player[playerid][AIsImpostor];
					SendClientMessage(playerid, 0xAFAFAFFF, "( Игра ) {FFFFFF}Предатели убили весь персонал, игра закончена.");
				}
				else Player[playerid][AEventData] = !Player[playerid][AIsImpostor];
				
				DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
				DestroyAmongusTextdraws(playerid, A_DATA_TEXTDRAW_TYPE);
				DestroyAmongusTextdraws(playerid, A_STATIC_TEXTDRAW_TYPE);
				DestroyAmongusTextdraws(playerid, A_VOTE_TEXTDRAW_TYPE);
				
				SetPlayerVirtualWorld(playerid, 100);
				A_PlayerEvent(playerid, lobbyid, A_EVENT_BUTTONS, A_EVENT_INTERNAL_UPDATE);
				TogglePlayerSpectating(playerid, false);
			}
		}
		case A_STATE_SPECTATE:
		{
			A_PlayerEvent(playerid, Player[playerid][ALobby], A_EVENT_NEAR_CAMERA, A_EVENT_INTERNAL_UPDATE); // Создаем
			A_PlayerEvent(playerid, Player[playerid][ALobby], A_EVENT_NEAR_CAMERA, A_EVENT_STATE_CLICK); // Открываем
		}
		case A_STATE_NULL:
		{
			for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
			{
				if(A_Lobby[lobbyid][APlayers][i] == playerid)
				{
					for(new a; a < A_MAX_PLAYERS_IN_LOBBY; a++)
					{
						if(A_Lobby[lobbyid][APlayers][a] != INVALID_PLAYER_ID && a != i)
						{
							if(Player[A_Lobby[lobbyid][APlayers][a]][AVotingTextdraws][(i*4)] != PlayerText:INVALID_TEXT_DRAW)
							{
								if(Player[A_Lobby[lobbyid][APlayers][a]][APreviousClickedVoteTextdraw] == i*4) A_OnPlayerVoteTextdraw(A_Lobby[lobbyid][APlayers][a], lobbyid, 45);
								PlayerTextDrawSetSelectable(A_Lobby[lobbyid][APlayers][a], Player[A_Lobby[lobbyid][APlayers][a]][AVotingTextdraws][i*4], 0);
								PlayerTextDrawColor(A_Lobby[lobbyid][APlayers][a], Player[A_Lobby[lobbyid][APlayers][a]][AVotingTextdraws][i*4], 0xAFAFAFFF);
								PlayerTextDrawShow(A_Lobby[lobbyid][APlayers][a], Player[A_Lobby[lobbyid][APlayers][a]][AVotingTextdraws][i*4]);
							}
						}
					}
					
					if(A_Lobby[lobbyid][AMainPlayer] == A_Lobby[lobbyid][APlayers][i])
					{
						for(new a; a < A_MAX_PLAYERS_IN_LOBBY; a++)
						{
							if(A_Lobby[lobbyid][APlayers][a] != INVALID_PLAYER_ID && a != i)
							{
								A_Lobby[lobbyid][AMainPlayer] = A_Lobby[lobbyid][APlayers][a];
								break;
							}
						}
					}
					A_Lobby[lobbyid][APlayersCount]--;
					
					A_KillPlayer(lobbyid, i, false, false);
					A_Lobby[lobbyid][APlayers][i] = INVALID_PLAYER_ID;
					
					if(A_Lobby[lobbyid][ATasksSuccessed] >= A_Lobby[lobbyid][AMaxTasks]*(A_Lobby[lobbyid][APlayersCount]-A_Lobby[lobbyid][AMaxImpostors]-A_Lobby[lobbyid][ADeadCount])) A_OnMatchEnd(lobbyid, A_END_MATCH+99);
					break;
				}
			}
			Player[playerid][ALobby] = A_INVALID_LOBBY_ID;
			
			Player[playerid][AIsImpostor] = false;
			Player[playerid][AIsDead] = false;
			Player[playerid][AIsSpectating] = false;
			Player[playerid][ASabotageTimer] = 0;
			Player[playerid][AEventDataTimer] = 0;
			Player[playerid][AEventDataTicks] = 0;
			Player[playerid][AStaticTimer] = 0;
			Player[playerid][AVotesCount] = 0;
			Player[playerid][AUsedReport] = false;
			Player[playerid][APreviousClickedVoteTextdraw] = -1;
			Player[playerid][AKillCooldown] = 0;
		
			DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
			DestroyAmongusTextdraws(playerid, A_DATA_TEXTDRAW_TYPE);
			DestroyAmongusTextdraws(playerid, A_STATIC_TEXTDRAW_TYPE);
			DestroyAmongusTextdraws(playerid, A_VOTE_TEXTDRAW_TYPE);
			
			TogglePlayerSpectating(playerid, false);
			TogglePlayerControllable(playerid, true);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerPos(playerid, 904.7440,-892.4892,1101.2266);
			SetPlayerSkin(playerid, Player[playerid][APreviousSkin]);
			SetPlayerColor(playerid, Player[playerid][APreviousColor]);
			CancelSelectTextDraw(playerid);
		}
	}
	return 1;
}
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(Player[playerid][ALobby] != A_INVALID_LOBBY_ID)
	{
		for(new i; i < A_MAX_DATA_TEXTDRAWS; i++)
		{
			if(playertextid == Player[playerid][AEventDataTextdraws][i])
			{
				A_PlayerEvent(playerid, Player[playerid][ALobby], Player[playerid][ACurrentEvent], A_EVENT_STATE_CLICK, Player[playerid][AEventDataTextdraws][i]);
				return 1;
			}
		}
		for(new i; i < A_MAX_STATE_TEXTDRAWS; i++)
		{
			if(playertextid == Player[playerid][AEventStateTextdraws][i])
			{
				A_PlayerEvent(playerid, Player[playerid][ALobby], Player[playerid][ACurrentEvent], A_EVENT_STATE_CLICK, Player[playerid][AEventStateTextdraws][i]);
				A_PlayerEvent(playerid, Player[playerid][ALobby], A_EVENT_BUTTONS, A_EVENT_STATE_CLICK, Player[playerid][AEventStateTextdraws][i]);
				A_PlayerEvent(playerid, Player[playerid][ALobby], A_EVENT_MAIN_PLAYER, A_EVENT_STATE_CLICK, Player[playerid][AEventStateTextdraws][i]);
				return 1;
			}
		}
		for(new i; i < A_MAX_STATIC_TEXTDRAWS; i++)
		{
			if(playertextid == Player[playerid][AStaticTextdraws][i])
			{
				A_PlayerEvent(playerid, Player[playerid][ALobby], A_EVENT_EXIT, A_EVENT_STATE_CLICK, Player[playerid][AStaticTextdraws][i]);
				return 1;
			}
		}
		for(new i; i < A_MAX_VOTING_TEXTDRAWS; i++)
		{
			if(playertextid == Player[playerid][AVotingTextdraws][i])
			{
				A_OnPlayerVoteTextdraw(playerid, Player[playerid][ALobby], i, Player[playerid][AVotingTextdraws][i]);
				return 1;
			}
		}
	}
	return true;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(Player[playerid][ALobby] != A_INVALID_LOBBY_ID)
	{
		switch(oldkeys)
		{
			case KEY_JUMP:
			{
				if(A_DISABLE_JUMP)
				{
					if(IsPlayerControllable(playerid)) 
					{
						TogglePlayerControllable(playerid, true);
						SendClientMessage(playerid, 0xAFAFAFFF, "( Игра ) {FFFFFF}Вы не можете прыгать!");
					}
				}
			}
			case KEY_SECONDARY_ATTACK:
			{
				if(Player[playerid][ACurrentEvent] != A_EVENT_NULL && !A_IsVotingTime(Player[playerid][ALobby])) A_PlayerEvent(playerid, Player[playerid][ALobby], Player[playerid][ACurrentEvent], A_EVENT_STATE_CLICK);
			}
			case KEY_YES: SelectTextDraw(playerid, 0xAFAFAFFF);
		}
	}
}

forward A_OnPlayerRequestJoin(playerid, lobbyid);
public A_OnPlayerRequestJoin(playerid, lobbyid)
{
	if(Player[playerid][ALobby] != A_INVALID_LOBBY_ID) return 0;
	return !A_IsMatchStarted(lobbyid);
}
forward A_OnPlayerJoinToMatch(playerid, lobbyid);
public A_OnPlayerJoinToMatch(playerid, lobbyid)
{
	for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
	{
		if(A_Lobby[lobbyid][APlayers][i] == INVALID_PLAYER_ID)
		{
			A_Lobby[lobbyid][APlayers][i] = playerid;
			break;
		}
	}
	A_Lobby[lobbyid][APlayersCount]++;
	if(A_Lobby[lobbyid][APlayersCount] == 1) A_Lobby[lobbyid][AMainPlayer] = playerid;
	Player[playerid][ALobby] = lobbyid;
	A_PlayerChangeState(playerid, lobbyid, A_STATE_WAITING);
	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "{AFAFAF}Информация", "{FFFFFF}Игра {FF0000}''Among Us''\n\n\
	{FFFFFF}Правила игры за {FF0000}предателя:\n\
	{FFFFFF}Если вы играете за предателя, то вы должны скрытно убить весь персонал комплекса.\n\
	У вас имеется кнопка {FF0000}SABOTAGE{FFFFFF} и кнопка {FF0000}KILL\n\
	{FFFFFF}Вы должны нажать на кнопку {FF0000}F{FFFFFF} чтобы вызвать саботаж. После активации саботажа имеется кулдаун для всех предателей\n\
	2 минуты, после вы можете снова активировать саботаж. Постарайтесь не выполнять задания, так как они тоже засчитываются за выполненные персоналом.\n\
	После убийства игрока имеется кулдаун 15 секунд.\n\
	При выключении света предатель может видеть, а у персонала темнеет экран.\n\n\
	Правила игры за {0064ff}персонал{FFFFFF}:\n\
	Вы должны выполнить все задания чтобы выиграть. Время от времени предатели могут вызывать саботаж. Вы должны предотвращать это каждый раз.\n\
	Имеется два типа саботажа: {FF0000}Саботаж реактора {FFFFFF}и{FF0000} Саботаж света.\n\n\
	{FFFFFF}В игре имеется голосование, вы должны вычислить предателя и проголосовать за него, чтобы его выгнать.\n\
	{FFFFFF}Вы так же можете нажать на кнопку голосования в столовой.\n\
	{FFFFFF}Если у вас пропал курсор в камерах наблюдения, нажмите на F.\n\
	{FFFFFF}Вы можете переключаться между камерами стрелочками на экране или стрелочками на клавиатуре\n\n\n{FFFFFF}Чтобы появился курсор, нажмите на {0064ff}Y\n{FFFFFF}Чтобы переключать камеры нажимайте на {0064ff}стрелочки\n{FFFFFF}Чтобы использовать кнопку нажимайте на {0064ff}F\n\n", "Ок", "");
	return 1;
}
forward A_OnPlayerCompleteTask(playerid, lobbyid);
public A_OnPlayerCompleteTask(playerid, lobbyid)
{
	if(A_Lobby[lobbyid][AMatchIsStart])
	{
		//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Звук когда выполнил задание
		for(new i; i < A_Lobby[lobbyid][AMaxTasks]; i++)
		{
			if(Player[playerid][AStaticTextdraws][i] != PlayerText:INVALID_TEXT_DRAW)
			{
				if(Player[playerid][ATasksState][i] == A_TASK_DONE)
				{
					PlayerTextDrawColor(playerid, Player[playerid][AStaticTextdraws][i], 0x32c800FF);
					PlayerTextDrawShow(playerid, Player[playerid][AStaticTextdraws][i]);
				}
			}
		}
		A_Lobby[lobbyid][ATasksSuccessed]++;
		CancelSelectTextDraw(playerid);
		// Если задания от не импосторов выполнены 
		if(A_Lobby[lobbyid][ATasksSuccessed] >= A_Lobby[lobbyid][AMaxTasks]*(A_Lobby[lobbyid][APlayersCount]-A_Lobby[lobbyid][AMaxImpostors]-A_Lobby[lobbyid][ADeadCount])) A_OnMatchEnd(lobbyid, A_END_MATCH+99);
	}
}
forward A_OnMatchEnd(lobbyid, comma);
public A_OnMatchEnd(lobbyid, comma)
{
	if(A_Lobby[lobbyid][AMatchIsStart])
	{
		for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
		{
			if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID) A_PlayerChangeState(A_Lobby[lobbyid][APlayers][i], lobbyid, A_STATE_PLAYING, comma);
		}
		A_ClearLobby(lobbyid);
	}
}
forward A_OnMatchStart(lobbyid);
public A_OnMatchStart(lobbyid)
{
	A_Lobby[lobbyid][AMaxTasks] = 6;
	A_Lobby[lobbyid][AMaxImpostors] = 1;
	// Заносим игроков в массив, для справедливого рандома
	new APlayerMass[A_MAX_PLAYERS_IN_LOBBY];
	new PlayersCountA;
	for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
	{
		if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
		{
			APlayerMass[PlayersCountA] = A_Lobby[lobbyid][APlayers][i];
			PlayersCountA++;
		}
	}
	// Определяем импосторов
	new RandomValue;
	for(new i; i < A_Lobby[lobbyid][AMaxImpostors]; i++)
	{
		RandomValue = random(PlayersCountA);
		while(Player[APlayerMass[RandomValue]][AIsImpostor]) RandomValue = random(PlayersCountA);
		Player[APlayerMass[RandomValue]][AIsImpostor] = true;
	}
	// Определяем задания для всех игроков
	
	for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
	{
		if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
		{
			//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Локальный звук, когда начинается игра в Among Us
			new TasksMass[A_MAX_TASKS], TasksCount = A_MAX_TASKS, randtask;
	
			for(new TS; TS < TasksCount; TS++) TasksMass[TS] = TS+1;
			
			for(new a; a < A_Lobby[lobbyid][AMaxTasks]; a++) 
			{
				if(TasksCount > 0)
				{
					randtask = random(TasksCount);
					A_PlayerAddTask(A_Lobby[lobbyid][APlayers][i], a, TasksMass[randtask]);//random(A_MAX_TASKS));
					TasksMass[randtask] = TasksMass[TasksCount-1];
					TasksMass[TasksCount-1] = -1;
					TasksCount--;
				}
			}
			A_PlayerChangeState(A_Lobby[lobbyid][APlayers][i], lobbyid, A_STATE_PLAYING, 1);
			SendClientMessage(A_Lobby[lobbyid][APlayers][i], 0xAFAFAFFF, "( Игра ) {FFFFFF}Игра началась!");
		}
	}
	//
	A_Lobby[lobbyid][AVoteButtonTimer] = gettime()+10;
	A_Lobby[lobbyid][AMatchIsStart] = true;
}
forward A_Update(lobbyid);
public A_Update(lobbyid)
{
	if(!A_Lobby[lobbyid][AMatchIsStart] && !A_Lobby[lobbyid][AVotingTimer])
	{
		if(A_Lobby[lobbyid][AStarted])
		{
			if(A_Lobby[lobbyid][ATimer] == 0) A_Lobby[lobbyid][ATimer] = gettime()+3;
			if(A_Lobby[lobbyid][APlayersCount]-A_Lobby[lobbyid][AMaxImpostors] < A_MIN_PLAYERS_TO_START) 
			{
				A_Lobby[lobbyid][ATimer] = 0;
				A_Lobby[lobbyid][AStarted] = false;
			}
			else if(A_Lobby[lobbyid][ATimer] < gettime()) A_OnMatchStart(lobbyid);
		}
	}
	else if(A_Lobby[lobbyid][AVotingTimer])
	{
		for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
		{
			if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
			{
				if(Player[A_Lobby[lobbyid][APlayers][i]][AVotingTextdraws][42] != PlayerText:INVALID_TEXT_DRAW)
				{
					format(global_str, 30, "skip voting in: %s", ConvertToTime(A_Lobby[lobbyid][AVotingTimer]-gettime()));
					PlayerTextDrawSetString(A_Lobby[lobbyid][APlayers][i], Player[A_Lobby[lobbyid][APlayers][i]][AVotingTextdraws][42], global_str);
					PlayerTextDrawShow(A_Lobby[lobbyid][APlayers][i], Player[A_Lobby[lobbyid][APlayers][i]][AVotingTextdraws][42]);
				}
			}
		}
		if(A_Lobby[lobbyid][AVotePlayersCount]+A_Lobby[lobbyid][AVoteSkips] >= A_Lobby[lobbyid][APlayersCount]-A_Lobby[lobbyid][ADeadCount]-A_Lobby[lobbyid][AImpostorsDeadCount] || !A_IsVotingTime(lobbyid))
		{
			new HighPlayer = INVALID_PLAYER_ID;
			if(A_Lobby[lobbyid][AVoteSkips] < A_Lobby[lobbyid][AVotePlayersCount])
			{
				for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
				{
					if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
					{
						HighPlayer = i;
						for(new a; a < A_MAX_PLAYERS_IN_LOBBY; a++)
						{
							if(A_Lobby[lobbyid][APlayers][a] != INVALID_PLAYER_ID && a != i)
							{
								if(Player[A_Lobby[lobbyid][APlayers][i]][AVotesCount] <= Player[A_Lobby[lobbyid][APlayers][a]][AVotesCount])
								{
									HighPlayer = INVALID_PLAYER_ID;
									break;
								}
							}
						}
						if(HighPlayer != INVALID_PLAYER_ID) break;
					}
				}
			}
			if(HighPlayer != INVALID_PLAYER_ID)
			{
				global_str = "";
				GetPlayerName(A_Lobby[lobbyid][APlayers][HighPlayer], global_str, MAX_PLAYER_NAME);
				format(global_str, 60, "( Голосование ) {FFFFFF}Игрок %s %s. Игра возобновлена.", global_str, Player[A_Lobby[lobbyid][APlayers][HighPlayer]][AIsImpostor] ? ("оказался предателем") : ("не был предателем"));
				
				for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
				{
					if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID) SendClientMessage(A_Lobby[lobbyid][APlayers][i], 0x0064ffFF, global_str);
				}
				A_KillPlayer(lobbyid, HighPlayer);
				
				SendClientMessage(A_Lobby[lobbyid][APlayers][HighPlayer], 0x0064ffFF, "( Голосование ) {FFFFFF}Вас выгнали! Вы можете только наблюдать.");
			}
			else
			{
				for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
				{
					if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
					{
						SendClientMessage(A_Lobby[lobbyid][APlayers][i], 0x0064ffFF, "( Голосование ) {FFFFFF}Голос не был определен, игра возобновлена.");
					}
				}
			}
			A_StopVoting(lobbyid);
		}
	}
	for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
	{
		if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID) A_PlayerDefineEvent(A_Lobby[lobbyid][APlayers][i], lobbyid);
	}
}
stock A_StopVoting(lobbyid)
{
	if(A_Lobby[lobbyid][AMatchIsStart])
	{
		for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
		{
			if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
			{
				A_PlayerChangeState(A_Lobby[lobbyid][APlayers][i], lobbyid, A_STATE_PLAYING, 1);
				DestroyAmongusTextdraws(A_Lobby[lobbyid][APlayers][i], A_VOTE_TEXTDRAW_TYPE);
				Player[A_Lobby[lobbyid][APlayers][i]][AVotesCount] = 0;
				CancelSelectTextDraw(A_Lobby[lobbyid][APlayers][i]);
				//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Звук репорта PlayerPlaySound(A_Lobby[lobbyid][APlayers][i], 3201, 0.0, 0.0, 0.0);
			}
		}
		A_ClearLobby(lobbyid, true);
		A_Lobby[lobbyid][AVotingTimer] = 0;
		A_Lobby[lobbyid][AVotePlayersCount] = 0;
		A_Lobby[lobbyid][AVoteSkips] = 0;
		
		switch(A_Lobby[lobbyid][AGlobalState]) // Возобновляем саботажи
		{
			case 2:
			{
				SetTimerEx("A_SabotageEvent", 15000, 0, "dd", lobbyid, A_SABOTAGE_REACTOR);
				for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
				{
					if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID) {} //;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Длительный звук саботажа реактора (5 сек)
				}
			}
			case 1:
			{
				for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
				{
					if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID) 
					{
						SendClientMessage(A_Lobby[lobbyid][APlayers][i], 0xFF0000FF, "( Саботаж ) {FFFFFF}В комплексе произошел сбой со светом! Вам нужно включить свет!");
						
						SetPlayerTime(A_Lobby[lobbyid][APlayers][i], 0, 0);
						if(!Player[A_Lobby[lobbyid][APlayers][i]][AIsImpostor]) PlayerTextDrawShow(A_Lobby[lobbyid][APlayers][i], Player[A_Lobby[lobbyid][APlayers][i]][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-3]);
					}
				}
			}
		}
	}
}
public OnPlayerText(playerid, text[])
{
	if(Player[playerid][ALobby] != A_INVALID_LOBBY_ID)
	{
		if(A_IsVotingTime(Player[playerid][ALobby]))
		{
			new name[MAX_PLAYER_NAME];
			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			format(global_str, 60, "{AFAFAF}%s: {FFFFFF}%s", name, text);
			for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
			{
				if(A_Lobby[Player[playerid][ALobby]][APlayers][i] != INVALID_PLAYER_ID) SendClientMessage(A_Lobby[Player[playerid][ALobby]][APlayers][i], 0xAFAFAFFF, global_str);
			}
		}
	}
	return 0;
}
forward A_PlayerDefineEvent(playerid, lobbyid);
public A_PlayerDefineEvent(playerid, lobbyid)
{
	
// Определяем возле чего стоит игрок, по приоритету
	new PreviousEvent = Player[playerid][ACurrentEvent];
	new PreviousEventData = Player[playerid][AEventData];
	new Float:X, Float:Y, Float:Z;
	Player[playerid][ACurrentEvent] = A_EVENT_NULL;
	if(!Player[playerid][AIsDead] && A_Lobby[lobbyid][AMatchIsStart]) // Игрок не мертв
	{
		// Если игрок импостор, то вызываем кнопку саботажа если кулдаун прошел
		if(Player[playerid][AIsImpostor] && Player[playerid][ASabotageTimer] < gettime()) Player[playerid][ACurrentEvent] = A_EVENT_SABOTAGE;
		// Если игрок импостор и он возле какого-либо игрока (не импостора)
		if(Player[playerid][AIsImpostor] && Player[playerid][AKillCooldown] < gettime())
		{
			for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
			{
				if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID && A_Lobby[lobbyid][APlayers][i] != playerid)
				{
					if(!Player[A_Lobby[lobbyid][APlayers][i]][AIsImpostor])
					{
						GetPlayerPos(A_Lobby[lobbyid][APlayers][i], X, Y, Z);
						if(IsPlayerInRangeOfPoint(playerid, 1.5, X, Y, Z))
						{
							Player[playerid][ACurrentEvent] = A_EVENT_NEAR_PLAYER;
							Player[playerid][AEventData] = i;
							break;
						}
					}
				}
			}
		}
		// Если игрок может нажать на кнопку
		if(!Player[playerid][AUsedReport] && A_Lobby[lobbyid][AVoteButtonTimer] < gettime())
		{
			if(IsPlayerInRangeOfPoint(playerid, 4.0, 902.3995,-892.8035,1102.0625)) Player[playerid][ACurrentEvent] = A_EVENT_VOTING; // Кнопка голосования 
		}
		// Если игрок возле его задания
		for(new i; i < A_Lobby[lobbyid][AMaxTasks]; i++)
		{
			if(Player[playerid][ATasksState][i] != A_TASK_DONE)
			{
				X = A_Rooms[Player[playerid][ATasksRoom][i]][ARoomTaskPlaceX][Player[playerid][ATasks][i]];
				Y = A_Rooms[Player[playerid][ATasksRoom][i]][ARoomTaskPlaceY][Player[playerid][ATasks][i]];
				Z = A_Rooms[Player[playerid][ATasksRoom][i]][ARoomTaskPlaceZ][Player[playerid][ATasks][i]];
				if(IsPlayerInRangeOfPoint(playerid, 1.5, X, Y, Z))
				{
					Player[playerid][ACurrentEvent] = A_EVENT_NEAR_TASK;
					Player[playerid][AEventData] = i;
					break;
				}
			}
		}
		
		if(IsPlayerInRangeOfPoint(playerid, 1.0, A_CameraPanelPos[0], A_CameraPanelPos[1], A_CameraPanelPos[2]) || Player[playerid][AIsSpectating]) Player[playerid][ACurrentEvent] = A_EVENT_NEAR_CAMERA; // Камеры
		else if(A_Lobby[lobbyid][AGlobalState] == 1 && IsPlayerInRangeOfPoint(playerid, 1.5, 893.0752,-907.0934,1101.2266)) Player[playerid][ACurrentEvent] = A_EVENT_NEAR_SABOTAGE_DISABLE; // Активируем ивент если выключен свет
		else if(A_Lobby[lobbyid][AGlobalState] == 2 && IsPlayerInRangeOfPoint(playerid, 1.5, 877.6080,-901.2388,1101.2188)) Player[playerid][ACurrentEvent] = A_EVENT_NEAR_SABOTAGE_DISABLE; // Активируем ивент если саботаж реактора
		
		// Если игрок возле трупа
		for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
		{
			if(A_Lobby[lobbyid][ADeadBodies][i] != INVALID_ACTOR_ID)
			{
				GetActorPos(A_Lobby[lobbyid][ADeadBodies][i], X, Y, Z);
				if(IsPlayerInRangeOfPoint(playerid, 1.0, X, Y, Z))
				{
					Player[playerid][ACurrentEvent] = A_EVENT_NEAR_BODY;
					Player[playerid][AEventData] = i;
					break;
				}
			}
		}
	}
	// Обновляем игрока
	if(!Player[playerid][AIsSpectating])
	{
		A_PlayerEvent(playerid, Player[playerid][ALobby], A_EVENT_EXIT, A_EVENT_INTERNAL_UPDATE);
		if(A_Lobby[lobbyid][AMatchIsStart])
		{
			if(!Player[playerid][AIsDead]) A_PlayerEvent(playerid, Player[playerid][ALobby], A_EVENT_CANT_USE, A_EVENT_INTERNAL_UPDATE);
			else A_PlayerEvent(playerid, Player[playerid][ALobby], A_EVENT_NEAR_CAMERA, A_EVENT_INTERNAL_UPDATE);
		}
		else if(A_Lobby[lobbyid][AMainPlayer] == playerid) A_PlayerEvent(playerid, Player[playerid][ALobby], A_EVENT_MAIN_PLAYER, A_EVENT_INTERNAL_UPDATE);
		else A_PlayerEvent(playerid, Player[playerid][ALobby], A_EVENT_LOBBY, A_EVENT_INTERNAL_UPDATE);
	}
	else Player[playerid][ACurrentEvent] = A_EVENT_NEAR_CAMERA;
	
	A_PlayerEvent(playerid, Player[playerid][ALobby], Player[playerid][ACurrentEvent], A_EVENT_INTERNAL_UPDATE);
	
	if(PreviousEvent != Player[playerid][ACurrentEvent] && PreviousEvent == A_EVENT_NEAR_TASK)
	{
		if(Player[playerid][ATasksState][PreviousEventData] != A_TASK_DONE)
		{
			DestroyAmongusTextdraws(playerid, A_DATA_TEXTDRAW_TYPE);
			Player[playerid][ATasksState][PreviousEventData] = 0;
			Player[playerid][AEventDataTicks] = 0;
		}
	}
}
forward A_SabotageEvent(lobbyid, sabotagetype);
public A_SabotageEvent(lobbyid, sabotagetype)
{
	if(A_Lobby[lobbyid][AMatchIsStart] && !A_IsVotingTime(lobbyid) && A_Lobby[lobbyid][AGlobalState])
	{
		switch(sabotagetype)
		{
			case A_SABOTAGE_REACTOR:
			{
				// если реакторы взорвались
				for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
				{
					if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
					{
						SendClientMessage(A_Lobby[lobbyid][APlayers][i], 0xFF0000FF, "( Саботаж ) {FFFFFF}Реактор взорвался от перегрева!");
						if(!Player[A_Lobby[lobbyid][APlayers][i]][AIsImpostor]) A_KillPlayer(lobbyid, i);
					}
				}
				A_OnMatchEnd(lobbyid, A_END_MATCH);
			}
		}
	}
}
stock A_PlayerEvent(playerid, lobbyid, event, astate, PlayerText:statedata = PlayerText:INVALID_TEXT_DRAW)
{	
	switch(event)
	{
		case A_EVENT_NEAR_SABOTAGE_DISABLE:
		{
			if(Player[playerid][AEventState] != event && Player[playerid][AEventState] != 0)
			{
				DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
				Player[playerid][AEventState] = 0;
			}
			if(!Player[playerid][AEventState])
			{
				// Текстдравов не существует, создаем
				Player[playerid][AEventStateTextdraws][0] = CreatePlayerTextDraw(playerid, 557.333068, 362.044586, "amongus:use");
				PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][0], 0.000000, 0.000000);
				PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][0], 84.333389, 71.437076);
				PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][0], 1);
				PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -1);
				PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][0], 0);
				PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][0], 0);
				PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][0], 4);
				PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
				Player[playerid][AEventState] = event;
			}
			switch(astate)
			{
				case A_EVENT_STATE_CLICK: 
				{
					if(Player[playerid][AEventState] == event)
					{
						if(statedata == PlayerText:INVALID_TEXT_DRAW)
						{
							switch(A_Lobby[lobbyid][AGlobalState])
							{
								case 1:
								{
									for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
									{
										if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID) 
										{
											SendClientMessage(A_Lobby[lobbyid][APlayers][i], 0xAFAFAFFF, "( Игра ) {FFFFFF}В комплексе был включен свет!");
											
											SetPlayerTime(A_Lobby[lobbyid][APlayers][i], 17, 0);
											PlayerTextDrawHide(A_Lobby[lobbyid][APlayers][i], Player[A_Lobby[lobbyid][APlayers][i]][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-3]);
										}
									}
									DestroyDynamicMapIcon(A_Lobby[lobbyid][ASabotageMapIcon][A_Lobby[lobbyid][AGlobalState]-1]);
									A_Lobby[lobbyid][ASabotageMapIcon][A_Lobby[lobbyid][AGlobalState]-1] = 0;
									A_Lobby[lobbyid][AGlobalState] = 0;
								}
								
								case 2:
								{
									for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
									{
										if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID) SendClientMessage(A_Lobby[lobbyid][APlayers][i], 0xAFAFAFFF, "( Игра ) {FFFFFF}Реактор успешно охлажден!");
									}
									DestroyDynamicMapIcon(A_Lobby[lobbyid][ASabotageMapIcon][A_Lobby[lobbyid][AGlobalState]-1]);
									A_Lobby[lobbyid][ASabotageMapIcon][A_Lobby[lobbyid][AGlobalState]-1] = 0;
									A_Lobby[lobbyid][AGlobalState] = 0;
								}
							}
						}
					}
				}
			}
		}
		case A_EVENT_NEAR_CAMERA:
		{
			if(astate != A_EVENT_STATE_CLICK)
			{
				if(Player[playerid][AEventState] != event && Player[playerid][AEventState] != 0)
				{
					DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
					Player[playerid][AEventState] = 0;
				}
				if(!Player[playerid][AEventState])
				{
					// Текстдравов не существует, создаем
					Player[playerid][AEventStateTextdraws][0] = CreatePlayerTextDraw(playerid, 557.333068, 362.044586, "amongus:security");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][0], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][0], 84.333389, 71.437076);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][0], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][0], 4);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
					
					Player[playerid][AEventStateTextdraws][1] = CreatePlayerTextDraw(playerid, 600.000000, 203.674041, ">>>");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][1], 0.291333, 1.894517);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][1], 650.0, 223.0);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][1], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][1], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][1], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][1], 1);
					PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventStateTextdraws][1], 51);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][1], 2);
					PlayerTextDrawSetProportional(playerid, Player[playerid][AEventStateTextdraws][1], 1);
					PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventStateTextdraws][1], true);
					
					Player[playerid][AEventStateTextdraws][2] = CreatePlayerTextDraw(playerid, 12.999893, 193.888809, "<<<");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][2], 0.291333, 1.894517);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][2], 50.0, 20.0);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][2], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][2], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][2], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][2], 1);
					PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventStateTextdraws][2], 51);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][2], 2);
					PlayerTextDrawSetProportional(playerid, Player[playerid][AEventStateTextdraws][2], 1);
					PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventStateTextdraws][2], true);
					
					Player[playerid][AEventState] = event;
					Player[playerid][AEventData] = 0;
				}
			}
			switch(astate)
			{
				case A_EVENT_STATE_CLICK: 
				{
					if(Player[playerid][AEventState] == event)
					{
						if(statedata == PlayerText:INVALID_TEXT_DRAW) 
						{
							
							Player[playerid][AEventData] = 0;
							if(Player[playerid][AIsDead])
							{
								PlayerTextDrawHide(playerid, Player[playerid][AEventStateTextdraws][0]);
								for(new i; i < A_Lobby[lobbyid][AMaxTasks]; i++)
								{
									if(Player[playerid][AStaticTextdraws][i] != PlayerText:INVALID_TEXT_DRAW) PlayerTextDrawHide(playerid, Player[playerid][AStaticTextdraws][i]);
								}
								if(IsPlayerPaused(playerid))
								{
									if(GetPlayerVirtualWorld(playerid) != 100) SetPlayerVirtualWorld(playerid, 100);
								}
								else if(GetPlayerVirtualWorld(playerid) != lobbyid+2) SetPlayerVirtualWorld(playerid, lobbyid+2);
									
							}
							PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][1]);
							PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][2]);
							PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][3]);
							A_GoCameras(playerid, Player[playerid][AEventData]);
							if(Player[playerid][AEventData] >= A_MAX_CAMERAS) Player[playerid][AEventData] = 0;
							Player[playerid][AIsSpectating] = true;
							SelectTextDraw(playerid, 0xAFAFAFFF);
							Player[playerid][AEventDataTicks] = 1;
						}
						else if(statedata == Player[playerid][AEventStateTextdraws][1])
						{
							Player[playerid][AEventData]++;
							if(Player[playerid][AEventData] >= A_MAX_CAMERAS) Player[playerid][AEventData] = 0;
							A_GoCameras(playerid, Player[playerid][AEventData]);
						}
						else if(statedata == Player[playerid][AEventStateTextdraws][2])
						{
							Player[playerid][AEventData]--;
							if(Player[playerid][AEventData] < 0) Player[playerid][AEventData] = A_MAX_CAMERAS-1;
							A_GoCameras(playerid, Player[playerid][AEventData]);
						}
					}
				}
				case A_EVENT_INTERNAL_UPDATE:
				{
					if(Player[playerid][AEventState] == event && Player[playerid][AIsDead]) // Фикс игрока после смерти если он в афк
					{
						if(IsPlayerPaused(playerid))
						{
							if(GetPlayerVirtualWorld(playerid) != 100) SetPlayerVirtualWorld(playerid, 100);
						}
						else if(GetPlayerVirtualWorld(playerid) != lobbyid+2) 
						{
							SetPlayerVirtualWorld(playerid, lobbyid+2);
							Player[playerid][AEventData] = 0;
							A_GoCameras(playerid, Player[playerid][AEventData]);
						}
					}
				}
			}
		}
		case A_EVENT_LOBBY:
		{
			if(astate != A_EVENT_STATE_CLICK)
			{
				if(Player[playerid][AEventState] != event && Player[playerid][AEventState] != 0)
				{
					DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
					Player[playerid][AEventState] = 0;
				}
				if(!Player[playerid][AEventState])
				{
					// Текстдравов не существует, создаем
					Player[playerid][AEventStateTextdraws][0] = CreatePlayerTextDraw(playerid, 396.333374, 338.074066, "amongus:amogus");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][0], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][0], 45.333343, 44.800003);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][0], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][0], 4);

					Player[playerid][AEventStateTextdraws][1] = CreatePlayerTextDraw(playerid, 429.333374, 353.836975, "0/10");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][1], 0.159999, 0.986074);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][1], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][1], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][1], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][1], 1);
					PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventStateTextdraws][1], 51);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][1], 2);
					PlayerTextDrawSetProportional(playerid, Player[playerid][AEventStateTextdraws][1], 1);

					Player[playerid][AEventStateTextdraws][2] = CreatePlayerTextDraw(playerid, 324.666656, 380.385284, " ");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][2], 0.225000, 1.421629);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][2], 2);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][2], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][2], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][2], 1);
					PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventStateTextdraws][2], 51);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][2], 2);
					PlayerTextDrawSetProportional(playerid, Player[playerid][AEventStateTextdraws][2], 1);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][1]);
					Player[playerid][AEventState] = event;
				}
			}
			switch(astate)
			{
				case A_EVENT_INTERNAL_UPDATE:
				{
					format(global_str, 8, "%d/%d", A_Lobby[lobbyid][APlayersCount], A_MAX_PLAYERS_IN_LOBBY);
					PlayerTextDrawSetString(playerid, Player[playerid][AEventStateTextdraws][1], global_str);
					if(A_Lobby[lobbyid][ATimer] != 0) format(global_str, 50, "Game start in: %s", ConvertToTime(A_Lobby[lobbyid][ATimer]-gettime()));
					else SetString(global_str, "");
					PlayerTextDrawSetString(playerid, Player[playerid][AEventStateTextdraws][2], global_str);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][1]);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][2]);
				}
			}
		}
		case A_EVENT_MAIN_PLAYER:
		{
			if(astate != A_EVENT_STATE_CLICK)
			{
				if(Player[playerid][AEventState] != event && Player[playerid][AEventState] != 0)
				{
					DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
					Player[playerid][AEventState] = 0;
				}
				if(!Player[playerid][AEventState])
				{
					// Текстдравов не существует, создаем
					Player[playerid][AEventStateTextdraws][0] = CreatePlayerTextDraw(playerid, 275.333343, 311.525939, "amongus:start");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][0], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][0], 84.333328, 66.785194);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][0], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][0], 4);
					PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventStateTextdraws][0], false);
					
					Player[playerid][AEventStateTextdraws][1] = CreatePlayerTextDraw(playerid, 396.333374, 338.074066, "amongus:amogus");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][1], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][1], 45.333343, 44.800003);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][1], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][1], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][1], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][1], 0);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][1], 4);

					Player[playerid][AEventStateTextdraws][2] = CreatePlayerTextDraw(playerid, 429.333374, 353.836975, "0/10");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][2], 0.159999, 0.986074);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][2], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][2], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][2], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][2], 1);
					PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventStateTextdraws][2], 51);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][2], 2);
					PlayerTextDrawSetProportional(playerid, Player[playerid][AEventStateTextdraws][2], 1);

					Player[playerid][AEventStateTextdraws][3] = CreatePlayerTextDraw(playerid, 324.666656, 380.385284, " ");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][3], 0.225000, 1.421629);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][3], 2);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][3], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][3], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][3], 1);
					PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventStateTextdraws][3], 51);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][3], 2);
					PlayerTextDrawSetProportional(playerid, Player[playerid][AEventStateTextdraws][3], 1);
					
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][1]);

					Player[playerid][AEventState] = event;
				}
			}
			switch(astate)
			{
				case A_EVENT_STATE_CLICK:
				{
					if(Player[playerid][AEventState] == event)
					{
						if(statedata == Player[playerid][AEventStateTextdraws][0])
						{
							if(A_Lobby[lobbyid][APlayersCount]-A_Lobby[lobbyid][AMaxImpostors] >= A_MIN_PLAYERS_TO_START) A_Lobby[lobbyid][AStarted] = true;
							else SendClientMessagef(playerid, 0xAFAFAFFF, "( Игра ) {FFFFFF}Необходимо больше %d игроков для начала игры.", A_MIN_PLAYERS_TO_START);
						}
					}
				}
				case A_EVENT_INTERNAL_UPDATE:
				{
					format(global_str, 8, "%d/%d", A_Lobby[lobbyid][APlayersCount], A_MAX_PLAYERS_IN_LOBBY);
					PlayerTextDrawSetString(playerid, Player[playerid][AEventStateTextdraws][2], global_str);
					if(A_Lobby[lobbyid][ATimer] != 0) format(global_str, 50, "Game start in: %s", ConvertToTime(A_Lobby[lobbyid][ATimer]-gettime()));
					else SetString(global_str, "");
					PlayerTextDrawSetString(playerid, Player[playerid][AEventStateTextdraws][3], global_str);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][2]);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][3]);
					
					//if(1)//A_Lobby[lobbyid][APlayersCount]-A_Lobby[lobbyid][AMaxImpostors] >= 3) 
					//{
					PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventStateTextdraws][0], true);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -1);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
					//}
					/*else
					{
						PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventStateTextdraws][0], false);
						PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -186);
						PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
					}*/
					
				}
			}
		}
		case A_EVENT_EXIT:
		{
			if(Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1] == PlayerText:INVALID_TEXT_DRAW)
			{
				Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-3] = CreatePlayerTextDraw(playerid, -12, -10.3555, "Box");
				PlayerTextDrawLetterSize(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-3], 0.0, 53.6333);
				PlayerTextDrawTextSize(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-3], 680.0, 0.0);
				PlayerTextDrawUseBox(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-3], 1);
				PlayerTextDrawBoxColor(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-3], 230);
				
				Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1] = CreatePlayerTextDraw(playerid, 596.666625, 130.666671, "amongus:close_icon");
				PlayerTextDrawLetterSize(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1], 0.000000, 0.000000);
				PlayerTextDrawTextSize(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1], 36.333347, 29.451848);
				PlayerTextDrawAlignment(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1], 1);
				PlayerTextDrawColor(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1], -1);
				PlayerTextDrawSetShadow(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1], 0);
				PlayerTextDrawSetOutline(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1], 0);
				PlayerTextDrawFont(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1], 4);
				PlayerTextDrawSetSelectable(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1], true);
				PlayerTextDrawShow(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1]);
			}
			else
			{
				if(A_Lobby[lobbyid][AMatchIsStart] && !Player[playerid][AIsDead])
				{
					for(new i; i < A_Lobby[lobbyid][AMaxTasks]; i++)
					{
						if(Player[playerid][AStaticTextdraws][i] == PlayerText:INVALID_TEXT_DRAW)
						{
							format(global_str, 60, "%s ( %s )", A_TaskGetDesc(A_Rooms[Player[playerid][ATasksRoom][i]][ARoomTaskType][Player[playerid][ATasks][i]]), 
							A_Room_GetName(Player[playerid][ATasksRoom][i]));

							Player[playerid][AStaticTextdraws][i] = CreatePlayerTextDraw(playerid, 12.999893, 233.674041+(15*i), global_str);
							PlayerTextDrawLetterSize(playerid, Player[playerid][AStaticTextdraws][i], 0.291333/2, 1.894517/2);
							PlayerTextDrawAlignment(playerid, Player[playerid][AStaticTextdraws][i], 1);
							PlayerTextDrawColor(playerid, Player[playerid][AStaticTextdraws][i], -1);
							PlayerTextDrawSetShadow(playerid, Player[playerid][AStaticTextdraws][i], 0);
							PlayerTextDrawSetOutline(playerid, Player[playerid][AStaticTextdraws][i], 1);
							PlayerTextDrawBackgroundColor(playerid, Player[playerid][AStaticTextdraws][i], 51);
							PlayerTextDrawFont(playerid, Player[playerid][AStaticTextdraws][i], 2);
							PlayerTextDrawSetProportional(playerid, Player[playerid][AStaticTextdraws][i], 1);
							PlayerTextDrawSetSelectable(playerid, Player[playerid][AStaticTextdraws][i], false);
							PlayerTextDrawShow(playerid, Player[playerid][AStaticTextdraws][i]);
						}
					}
					if(Player[playerid][AStaticTimer] == 0)
					{
						Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-2] = CreatePlayerTextDraw(playerid, 245.333312, 64.296279, Player[playerid][AIsImpostor] ? "amongus:impostor" : "amongus:crewmate");
						PlayerTextDrawLetterSize(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-2], 0.000000, 0.000000);
						PlayerTextDrawTextSize(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-2], 152.333328, 93.333267);
						PlayerTextDrawAlignment(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-2], 1);
						PlayerTextDrawColor(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-2], -1);
						PlayerTextDrawSetShadow(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-2], 0);
						PlayerTextDrawSetOutline(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-2], 0);
						PlayerTextDrawFont(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-2], 4);
						PlayerTextDrawShow(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-2]);
						Player[playerid][AStaticTimer] = gettime()+5;
					}
					else if(Player[playerid][AStaticTimer] < gettime()) DestroyPlayerTextdraw(playerid, Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-2]);
				}
				
				
			}
			switch(astate)
			{
				case A_EVENT_STATE_CLICK: 
				{
					if(statedata == Player[playerid][AStaticTextdraws][A_MAX_STATIC_TEXTDRAWS-1])
					{
						if(Player[playerid][AEventState] == A_EVENT_NEAR_TASK && Player[playerid][ATasksState][Player[playerid][AEventData]])
						{
							DestroyAmongusTextdraws(playerid, A_DATA_TEXTDRAW_TYPE);
							Player[playerid][ATasksState][Player[playerid][AEventData]] = 0;
							Player[playerid][AEventDataTicks] = 0;
							CancelSelectTextDraw(playerid);
						}
						else if(Player[playerid][AEventState] == A_EVENT_NEAR_CAMERA && Player[playerid][AEventDataTicks] && !Player[playerid][AIsDead])
						{
							PlayerTextDrawHide(playerid, Player[playerid][AEventStateTextdraws][1]);
							PlayerTextDrawHide(playerid, Player[playerid][AEventStateTextdraws][2]);
							PlayerTextDrawHide(playerid, Player[playerid][AEventStateTextdraws][3]);
							TogglePlayerSpectating(playerid, false);
							CancelSelectTextDraw(playerid);
						}
						else ShowPlayerDialog(playerid, 1, DIALOG_STYLE_MSGBOX, "{AFAFAF}Информация", "{FFFFFF}Вы действительно хотите выйти из игры?", "Да", "Нет");
					}
				}
			}
		}
		case A_EVENT_CANT_USE:
		{
			if(astate != A_EVENT_STATE_CLICK)
			{
				if(Player[playerid][AEventState] != event && Player[playerid][AEventState] != 0)
				{
					DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
					Player[playerid][AEventState] = 0;
				}
				if(!Player[playerid][AEventState])
				{
					// Текстдравов не существует, создаем
					Player[playerid][AEventStateTextdraws][0] = CreatePlayerTextDraw(playerid, 557.333068, 362.044586, "amongus:use");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][0], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][0], 84.333389, 71.437076);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][0], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -186);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][0], 4);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
					Player[playerid][AEventState] = event;
				}
			}
		}
		case A_EVENT_BUTTONS:
		{
			if(astate != A_EVENT_STATE_CLICK)
			{
				if(Player[playerid][AEventState] != event && Player[playerid][AEventState] != 0)
				{
					DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
					Player[playerid][AEventState] = 0;
				}
				if(!Player[playerid][AEventState])
				{
					// Текстдравов не существует, создаем
					Player[playerid][AEventStateTextdraws][3] = CreatePlayerTextDraw(playerid, -12, -10.3555, "Box");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][3], 0.0, 53.6333);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][3], 680.0, 0.0);
					PlayerTextDrawUseBox(playerid, Player[playerid][AEventStateTextdraws][3], 1);
					PlayerTextDrawBoxColor(playerid, Player[playerid][AEventStateTextdraws][3], 255);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][3]);
					
					Player[playerid][AEventStateTextdraws][0] = CreatePlayerTextDraw(playerid, 596.666625, 130.666671, "amongus:close_icon");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][0], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][0], 36.333347, 29.451848);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][0], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][0], 4);
					PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventStateTextdraws][0], true);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
				
					Player[playerid][AEventStateTextdraws][1] = CreatePlayerTextDraw(playerid, 557.333068, 362.044586, "amongus:playagain");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][1], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][1], 84.333389, 71.437076);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][1], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][1], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][1], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][1], 0);
					PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventStateTextdraws][1], true);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][1], 4);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][1]);
					
					Player[playerid][AEventStateTextdraws][2] = CreatePlayerTextDraw(playerid, 245.333312, 64.296279, Player[playerid][AEventData] ? "amongus:victory" : "amongus:defeat");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][2], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][2], 152.333328, 93.333267);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][2], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][2], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][2], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][2], 0);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][2], 4);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][2]);
					
					Player[playerid][AEventState] = event;
				}
			}
			switch(astate)
			{
				case A_EVENT_STATE_CLICK:
				{
					if(Player[playerid][AEventState] == event)
					{
						if(statedata == Player[playerid][AEventStateTextdraws][0]) A_PlayerChangeState(playerid, lobbyid, A_STATE_NULL);
						else if(statedata == Player[playerid][AEventStateTextdraws][1])
						{
							A_PlayerChangeState(playerid, lobbyid, A_STATE_NULL);
							if(A_OnPlayerRequestJoin(playerid, lobbyid)) A_OnPlayerJoinToMatch(playerid, lobbyid);
							else A_PlayerChangeState(playerid, lobbyid, A_STATE_NULL);
						}
					}
				}
			}
		}
		case A_EVENT_SABOTAGE:
		{
			if(astate != A_EVENT_STATE_CLICK)
			{
				if(Player[playerid][AEventState] != event && Player[playerid][AEventState] != 0)
				{
					DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
					Player[playerid][AEventState] = 0;
				}
				if(!Player[playerid][AEventState])
				{
					// Текстдравов не существует, создаем
					Player[playerid][AEventStateTextdraws][0] = CreatePlayerTextDraw(playerid, 557.333068, 362.044586, "amongus:sabotage");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][0], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][0], 84.333389, 71.437076);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][0], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][0], 4);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
					Player[playerid][AEventState] = event;
				}
			}
			switch(astate)
			{
				case A_EVENT_STATE_CLICK: 
				{
					if(Player[playerid][AEventState] == event && Player[playerid][ASabotageTimer] < gettime())
					{
						A_StartSabotage(lobbyid, random(A_MAX_SABOTAGES_TYPES));
						for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++) // Активируем кулдаун саботажа для всех импосторов
						{
							if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
							{
								if(Player[A_Lobby[lobbyid][APlayers][i]][AIsImpostor])
								{
									Player[playerid][ASabotageTimer] = gettime()+A_SABOTAGE_COOLDOWN;
									SendClientMessage(A_Lobby[lobbyid][APlayers][i], 0xFF0000FF, "( Предатель ) {FFFFFF}Один из предателей вызвал саботаж, подождите 2 минуты для повторного вызова саботажа.");
								}
							}
						}
					}
				}
			}
		}
		case A_EVENT_VOTING:
		{
			if(astate != A_EVENT_STATE_CLICK)
			{
				if(Player[playerid][AEventState] != event && Player[playerid][AEventState] != 0)
				{
					DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
					Player[playerid][AEventState] = 0;
				}
				if(!Player[playerid][AEventState])
				{
					// Текстдравов не существует, создаем
					Player[playerid][AEventStateTextdraws][0] = CreatePlayerTextDraw(playerid, 557.333068, 362.044586, "amongus:report");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][0], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][0], 84.333389, 71.437076);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][0], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][0], 4);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
					Player[playerid][AEventState] = event;
				}
			}
			switch(astate)
			{
				case A_EVENT_STATE_CLICK: 
				{
					if(Player[playerid][AEventState] == event && !Player[playerid][AUsedReport]) 
					{
						A_StartVoting(lobbyid);
						Player[playerid][AUsedReport] = true; // Больше не сможет использовать кнопку
					}
				}
			}
		}
		case A_EVENT_NEAR_PLAYER:
		{
			if(astate != A_EVENT_STATE_CLICK)
			{
				if(Player[playerid][AEventState] != event && Player[playerid][AEventState] != 0)
				{
					DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
					Player[playerid][AEventState] = 0;
				}
				if(!Player[playerid][AEventState])
				{
					// Текстдравов не существует, создаем
					Player[playerid][AEventStateTextdraws][0] = CreatePlayerTextDraw(playerid, 557.333068, 362.044586, "amongus:kill");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][0], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][0], 84.333389, 71.437076);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][0], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][0], 4);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
					Player[playerid][AEventState] = event;
				}
			}
			switch(astate)
			{
				case A_EVENT_STATE_CLICK:
				{
					if(Player[playerid][AEventState] == event && Player[playerid][AKillCooldown] < gettime())
					{
						new Float:X, Float:Y, Float:Z;
						GetPlayerPos(A_Lobby[lobbyid][APlayers][Player[playerid][AEventData]], X, Y, Z);
						A_KillPlayer(lobbyid, Player[playerid][AEventData], true);
						SetPlayerPos(playerid, X, Y, Z);
						SendClientMessage(A_Lobby[lobbyid][APlayers][Player[playerid][AEventData]], 0xAFAFAFFF, "( Игра ) {FFFFFF}Вас убил предатель! Вы можете только наблюдать.");
						SendClientMessage(playerid, 0xAFAFAFFF, "( Игра ) {FFFFFF}Вы убили персонал! Скорее убегите от трупа или сообщите о трупе! Активирован кулдаун на 15 секунд.");
						Player[playerid][AKillCooldown] = gettime()+15;
						
						//;;;;;;;;;;;;;;;;;;;;;;; Обычный локальный звук убийства игрока убийце
						//;;;;;;;;;;;;;;;;;;;;;;; Локальный звук когда игрока убивает импостор
					}
				}
			}
		}
		case A_EVENT_NEAR_BODY:
		{
			if(astate != A_EVENT_STATE_CLICK)
			{
				if(Player[playerid][AEventState] != event && Player[playerid][AEventState] != 0)
				{
					DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
					Player[playerid][AEventState] = 0;
				}
				if(!Player[playerid][AEventState])
				{
					// Текстдравов не существует, создаем
					Player[playerid][AEventStateTextdraws][0] = CreatePlayerTextDraw(playerid, 557.333068, 362.044586, "amongus:report");
					PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][0], 0.000000, 0.000000);
					PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][0], 84.333389, 71.437076);
					PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][0], 1);
					PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -1);
					PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][0], 0);
					PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][0], 4);
					PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
					Player[playerid][AEventState] = event;
				}
			}
			switch(astate)
			{
				case A_EVENT_STATE_CLICK: if(Player[playerid][AEventState] == event) A_StartVoting(lobbyid);
			}
		}
		case A_EVENT_NEAR_TASK:
		{
			switch(astate)
			{
				case A_EVENT_STATE_CLICK:
				{
					if(Player[playerid][AEventState] == event)
					{
						if(statedata != PlayerText:INVALID_TEXT_DRAW)
						{
							switch(A_Rooms[Player[playerid][ATasksRoom][Player[playerid][AEventData]]][ARoomTaskType][Player[playerid][ATasks][Player[playerid][AEventData]]])
							{
								case A_EVENT_ASTEROID:
								{
									if(statedata == Player[playerid][AEventDataTextdraws][1])
									{
										//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Звук взрыва камня
										DestroyPlayerTextdraw(playerid, Player[playerid][AEventDataTextdraws][1]);
										Player[playerid][AEventDataTicks]++;
										if(Player[playerid][AEventDataTicks] >= 6)
										{
											DestroyAmongusTextdraws(playerid, A_DATA_TEXTDRAW_TYPE);
											Player[playerid][ATasksState][Player[playerid][AEventData]] = A_TASK_DONE;
											A_OnPlayerCompleteTask(playerid, Player[playerid][ALobby]);
										}
									}
								}
								case A_EVENT_KEYCARD:
								{
									if(statedata == Player[playerid][AEventDataTextdraws][2])
									{
										Player[playerid][AEventDataTicks]++;
										if(Player[playerid][AEventDataTicks] >= 4)
										{
											//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Звук принятия карточки
											DestroyAmongusTextdraws(playerid, A_DATA_TEXTDRAW_TYPE);
											Player[playerid][ATasksState][Player[playerid][AEventData]] = A_TASK_DONE;
											A_OnPlayerCompleteTask(playerid, Player[playerid][ALobby]);
										}
										else 
										{
											//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Звук отклонения карточки
											DestroyPlayerTextdraw(playerid, Player[playerid][AEventDataTextdraws][3]);
										
											format(global_str,15, "%d%% / 100%%", Player[playerid][AEventDataTicks]*25);
											Player[playerid][AEventDataTextdraws][3] = CreatePlayerTextDraw(playerid, 312.333343, 271.288787, global_str);
											PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][3], 0.129333, 1.197630);
											PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][3], 2);
											PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][3], -1);
											PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][3], -1);
											PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][3], 0);
											PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventDataTextdraws][3], 51);
											PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][3], 2);
											PlayerTextDrawSetProportional(playerid, Player[playerid][AEventDataTextdraws][3], 1);
											PlayerTextDrawShow(playerid,Player[playerid][AEventDataTextdraws][3]);
										}
									}
								}
								case A_EVENT_DOWNLOAD,A_EVENT_UPLOAD:
								{
									if(statedata == Player[playerid][AEventDataTextdraws][3] && !Player[playerid][AEventDataTicks]) Player[playerid][AEventDataTicks] = 1;
								}
								case A_EVENT_GIVE_ENERGY,A_EVENT_SLIDE_ENERGY,A_EVENT_TRASH:
								{
									if(statedata == Player[playerid][AEventDataTextdraws][1])
									{
										DestroyAmongusTextdraws(playerid, A_DATA_TEXTDRAW_TYPE);
										Player[playerid][ATasksState][Player[playerid][AEventData]] = A_TASK_DONE;
										A_OnPlayerCompleteTask(playerid, Player[playerid][ALobby]);
									}
								}
								case A_EVENT_WIRE:
								{
									for(new i = 1; i <= 4; i++)
									{
										if(statedata == Player[playerid][AEventDataTextdraws][i])
										{
											PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][i], false);
											PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][i], 167.666610, 8.711117);
											PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][i]);
											Player[playerid][AEventDataTicks]++;
											if(Player[playerid][AEventDataTicks] >= 4)
											{
												DestroyAmongusTextdraws(playerid, A_DATA_TEXTDRAW_TYPE);
												Player[playerid][ATasksState][Player[playerid][AEventData]] = A_TASK_DONE;
												A_OnPlayerCompleteTask(playerid, Player[playerid][ALobby]);
											}
										}
									}
								}
								case A_EVENT_FUEL_ENGINE,A_EVENT_FUEL_MOTOR:
								{
									if(statedata == Player[playerid][AEventDataTextdraws][1])
									{
										Player[playerid][AEventDataTicks]++;
										DestroyPlayerTextdraw(playerid, Player[playerid][AEventDataTextdraws][2]);
										
										format(global_str,15, "%d%% / 100%%", Player[playerid][AEventDataTicks]*20);
										Player[playerid][AEventDataTextdraws][2] = CreatePlayerTextDraw(playerid, 320.333435, 290.985107, global_str);
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][2], 0.162000, 0.927999);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][2], 2);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][2], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][2], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][2], 1);
										PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventDataTextdraws][2], 51);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][2], 1);
										PlayerTextDrawSetProportional(playerid, Player[playerid][AEventDataTextdraws][2], 1);
										PlayerTextDrawShow(playerid,Player[playerid][AEventDataTextdraws][2]);
										
										if(Player[playerid][AEventDataTicks] >= 5)
										{
											DestroyAmongusTextdraws(playerid, A_DATA_TEXTDRAW_TYPE);
											Player[playerid][ATasksState][Player[playerid][AEventData]] = A_TASK_DONE;
											A_OnPlayerCompleteTask(playerid, Player[playerid][ALobby]);
										}
									}
								}
							}
						}
						else
						{
							if(!Player[playerid][ATasksState][Player[playerid][AEventData]] && Player[playerid][ATasksState][Player[playerid][AEventData]] != A_TASK_DONE)
							{
								DestroyAmongusTextdraws(playerid, A_DATA_TEXTDRAW_TYPE);
								Player[playerid][AEventDataTicks] = 0;
								
								switch(A_Rooms[Player[playerid][ATasksRoom][Player[playerid][AEventData]]][ARoomTaskType][Player[playerid][ATasks][Player[playerid][AEventData]]])
								{
									case A_EVENT_ASTEROID:
									{
										Player[playerid][AEventDataTextdraws][0] = CreatePlayerTextDraw(playerid, 197.666702, 363.633300, "usebox");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][0], 0.000000, -26.217075);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][0], 447.666625, 0.000000);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][0], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawUseBox(playerid, Player[playerid][AEventDataTextdraws][0], true);
										PlayerTextDrawBoxColor(playerid, Player[playerid][AEventDataTextdraws][0], 3211364);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][0]);

									}
									case A_EVENT_KEYCARD:
									{
										Player[playerid][AEventDataTextdraws][0] = CreatePlayerTextDraw(playerid, 471.666687, 94.418518, "usebox");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][0], 0.000000, 22.959053);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][0], 176.666671, 0.000000);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][0], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][0], 1684301000);
										PlayerTextDrawUseBox(playerid, Player[playerid][AEventDataTextdraws][0], true);
										PlayerTextDrawBoxColor(playerid, Player[playerid][AEventDataTextdraws][0], 1684301000);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][0], 0);

										Player[playerid][AEventDataTextdraws][1] = CreatePlayerTextDraw(playerid, 230.666671, 106.192588, "amongus:card_insert");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][1], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][1], 178.666671, 95.407402);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][1], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][1], 4);

										Player[playerid][AEventDataTextdraws][2] = CreatePlayerTextDraw(playerid, 268.333435, 207.992614, "amongus:card");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][2], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][2], 91.333366, 49.777763);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][2], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][2], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][2], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][2], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][2], 4);
										PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][2], true);

										Player[playerid][AEventDataTextdraws][3] = CreatePlayerTextDraw(playerid, 312.333343, 271.288787, "0%/100%");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][3], 0.129333, 1.197630);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][3], 2);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][3], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][3], -1);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][3], 0);
										PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventDataTextdraws][3], 51);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][3], 2);
										PlayerTextDrawSetProportional(playerid, Player[playerid][AEventDataTextdraws][3], 1);
										
										//PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][0]); с серым боксом выглядит не красиво, но вы можете вернуть
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][1]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][2]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][3]);

									}
									case A_EVENT_DOWNLOAD,A_EVENT_UPLOAD:
									{
										Player[playerid][AEventDataTextdraws][0] = CreatePlayerTextDraw(playerid, 178.666656, 107.437049, "amongus:download");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][0], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][0], 307.666687, 243.911178);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][0], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][0], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][0], 4);

										Player[playerid][AEventDataTextdraws][1] = CreatePlayerTextDraw(playerid, 249.000000, 234.370361, "Communications");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][1], 0.235999, 1.591703);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][1], 2);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][1], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventDataTextdraws][1], 51);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										PlayerTextDrawSetProportional(playerid, Player[playerid][AEventDataTextdraws][1], 1);

										Player[playerid][AEventDataTextdraws][2] = CreatePlayerTextDraw(playerid, 418.666625, 233.711090, "My tablet");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][2], 0.235999, 1.591703);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][2], 2);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][2], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][2], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][2], 1);
										PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventDataTextdraws][2], 51);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][2], 1);
										PlayerTextDrawSetProportional(playerid, Player[playerid][AEventDataTextdraws][2], 1);

										Player[playerid][AEventDataTextdraws][3] = CreatePlayerTextDraw(playerid, 296.000000, 270.044433, "amongus:nameframe");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][3], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][3], 74.333358, 14.103709);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][3], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][3], -926365496);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][3], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][3], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][3], 4);
										PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][3], true);

										Player[playerid][AEventDataTextdraws][4] = CreatePlayerTextDraw(playerid, 331.666687, 272.118469, (A_Rooms[Player[playerid][ATasksRoom][Player[playerid][AEventData]]][ARoomTaskType][Player[playerid][ATasks][Player[playerid][AEventData]]] == A_EVENT_DOWNLOAD) ? "Download" : "Upload");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][4], 0.162000, 0.927999);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][4], 2);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][4], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][4], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][4], 1);
										PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventDataTextdraws][4], 51);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][4], 1);
										PlayerTextDrawSetProportional(playerid, Player[playerid][AEventDataTextdraws][4], 1);
										
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][0]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][1]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][2]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][3]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][4]);
									}
									case A_EVENT_MEDSCAN:
									{
										//;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;3Д звук сканирования
										
										Player[playerid][AEventDataTextdraws][0] = CreatePlayerTextDraw(playerid, 229.333328, 95.407455, "amongus:medscan");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][0], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][0], 179.333312, 248.888885);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][0], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][0], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][0], 4);

										Player[playerid][AEventDataTextdraws][1] = CreatePlayerTextDraw(playerid, 243.333328, 313.185119, "Scan Complete in 3");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][1], 0.244333, 1.583408);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][1], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventDataTextdraws][1], 51);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										PlayerTextDrawSetProportional(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][0]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][1]);

									}
									case A_EVENT_TRASH:
									{
										Player[playerid][AEventDataTextdraws][0] = CreatePlayerTextDraw(playerid, 215.666641, 104.948135, "amongus:trashtask");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][0], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][0], 221.999908, 266.311157);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][0], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][0], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][0], 4);

										Player[playerid][AEventDataTextdraws][1] = CreatePlayerTextDraw(playerid, 379.000091, 223.170394, "amongus:trashlever");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][1], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][1], 48.666687, 57.659271);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][1], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][1], 4);
										PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][1], true);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][0]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][1]);
									}
									case A_EVENT_SLIDE_ENERGY:
									{
										Player[playerid][AEventDataTextdraws][0] = CreatePlayerTextDraw(playerid, 226.666671, 134.400009, "amongus:energy");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][0], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][0], 187.999984, 189.985107);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][0], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][0], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][0], 4);

										Player[playerid][AEventDataTextdraws][1] = CreatePlayerTextDraw(playerid, 301.333312, 275.851867, "amongus:energybutton");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][1], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][1], 18.000017, 14.103720);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][1], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][1], 4);
										PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][1], true);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][0]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][1]);
									}
									case A_EVENT_GIVE_ENERGY:
									{
										Player[playerid][AEventDataTextdraws][0] = CreatePlayerTextDraw(playerid, 227.999969, 171.318572, "amongus:energy2");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][0], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][0], 182.999923, 126.933319);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][0], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][0], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][0], 4);

										Player[playerid][AEventDataTextdraws][1] = CreatePlayerTextDraw(playerid, 315.333312, 220.266662, "amongus:energybutton2");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][1], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][1], 7.666667, 31.940719);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][1], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][1], 4);
										PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][1], true);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][0]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][1]);
									}
									case A_EVENT_WIRE:
									{
										Player[playerid][AEventDataTextdraws][0] = CreatePlayerTextDraw(playerid, 199.666656, 103.703727, "amongus:wire");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][0], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][0], 235.666687, 262.577789);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][0], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][0], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][0], 4);

										Player[playerid][AEventDataTextdraws][1] = CreatePlayerTextDraw(playerid, 229.000000, 153.066665, "amongus:wireframe");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][1], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][1], 5.9999, 8.711117);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][1], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][1], 4);
										PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][1], true);

										Player[playerid][AEventDataTextdraws][2] = CreatePlayerTextDraw(playerid, 230.000000, 207.163024, "amongus:wireframe");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][2], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][2], 5.9999, 8.711117);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][2], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][2], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][2], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][2], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][2], 4);
										PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][2], true);

										Player[playerid][AEventDataTextdraws][3] = CreatePlayerTextDraw(playerid, 229.333358, 260.844512, "amongus:wireframe");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][3], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][3], 5.9999, 8.711117);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][3], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][3], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][3], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][3], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][3], 4);
										PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][3], true);

										Player[playerid][AEventDataTextdraws][4] = CreatePlayerTextDraw(playerid, 227.666687, 314.111236, "amongus:wireframe");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][4], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][4], 5.9999, 8.711117);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][4], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][4], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][4], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][4], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][4], 4);
										PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][4], true);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][0]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][1]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][2]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][3]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][4]);
									}
									case A_EVENT_FUEL_ENGINE,A_EVENT_FUEL_MOTOR:
									{
										Player[playerid][AEventDataTextdraws][0] = CreatePlayerTextDraw(playerid, 262.333374, 122.785179, "amongus:fuel");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][0], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][0], 112.999969, 214.459167);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][0], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][0], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][0], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][0], 4);

										Player[playerid][AEventDataTextdraws][1] = CreatePlayerTextDraw(playerid, 382.333435, 301.985107, "amongus:fuelbutton");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][1], 0.000000, 0.000000);
										PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][1], 31.333312, 33.600006);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][1], 1);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][1], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][1], 0);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][1], 4);
										PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][1], true);
										
										Player[playerid][AEventDataTextdraws][2] = CreatePlayerTextDraw(playerid, 320.333435, 290.985107, "0%/100%");
										PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][2], 0.162000, 0.927999);
										PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][2], 2);
										PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][2], -1);
										PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][2], 0);
										PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][2], 1);
										PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventDataTextdraws][2], 51);
										PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][2], 1);
										PlayerTextDrawSetProportional(playerid, Player[playerid][AEventDataTextdraws][2], 1);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][0]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][1]);
										PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][2]);
									}
								}
								Player[playerid][ATasksState][Player[playerid][AEventData]] = 1;
								SelectTextDraw(playerid, 0xAFAFAFFF);
							}
						}
					}
				}
				case A_EVENT_INTERNAL_UPDATE:
				{
					if(Player[playerid][AEventState] != event && Player[playerid][AEventState] != 0)
					{
						DestroyAmongusTextdraws(playerid, A_STATE_TEXTDRAW_TYPE);
						Player[playerid][AEventState] = 0;
					}
					if(!Player[playerid][AEventState])
					{
						// Текстдравов не существует, создаем
						Player[playerid][AEventStateTextdraws][0] = CreatePlayerTextDraw(playerid, 557.333068, 362.044586, "amongus:use");
						PlayerTextDrawLetterSize(playerid, Player[playerid][AEventStateTextdraws][0], 0.000000, 0.000000);
						PlayerTextDrawTextSize(playerid, Player[playerid][AEventStateTextdraws][0], 84.333389, 71.437076);
						PlayerTextDrawAlignment(playerid, Player[playerid][AEventStateTextdraws][0], 1);
						PlayerTextDrawColor(playerid, Player[playerid][AEventStateTextdraws][0], -1);
						PlayerTextDrawSetShadow(playerid, Player[playerid][AEventStateTextdraws][0], 0);
						PlayerTextDrawSetOutline(playerid, Player[playerid][AEventStateTextdraws][0], 0);
						PlayerTextDrawFont(playerid, Player[playerid][AEventStateTextdraws][0], 4);
						PlayerTextDrawShow(playerid, Player[playerid][AEventStateTextdraws][0]);
						Player[playerid][AEventState] = event;
					}
					if(Player[playerid][ATasksState][Player[playerid][AEventData]] && Player[playerid][ATasksState][Player[playerid][AEventData]] != A_TASK_DONE)
					{
						switch(A_Rooms[Player[playerid][ATasksRoom][Player[playerid][AEventData]]][ARoomTaskType][Player[playerid][ATasks][Player[playerid][AEventData]]])
						{
							case A_EVENT_ASTEROID:
							{
								DestroyPlayerTextdraw(playerid, Player[playerid][AEventDataTextdraws][1]);
								Player[playerid][AEventDataTextdraws][1] = CreatePlayerTextDraw(playerid, 205.000091+frand(0.0,150.0), 137.718566+frand(0.0,150.0), "LD_SPAC:white");
								PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][1], 0.000000, 0.000000);
								PlayerTextDrawTextSize(playerid, Player[playerid][AEventDataTextdraws][1], 27.666671, 30.281486);
								PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][1], 1);
								PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][1], -1);
								PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventDataTextdraws][1], 3211364);
								PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][1], 0);
								PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][1], 0);
								PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][1], 5);
								PlayerTextDrawSetSelectable(playerid, Player[playerid][AEventDataTextdraws][1], true);
								PlayerTextDrawSetPreviewModel(playerid, Player[playerid][AEventDataTextdraws][1], 1454);
								PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][1]);
							}
							case A_EVENT_DOWNLOAD,A_EVENT_UPLOAD:
							{
								if(Player[playerid][AEventDataTicks] > 0)
								{
									Player[playerid][AEventDataTicks]++;
									format(global_str, 15, "%d%% / 100%", (Player[playerid][AEventDataTicks]-1)*17);
									DestroyPlayerTextdraw(playerid, Player[playerid][AEventDataTextdraws][4]);
									Player[playerid][AEventDataTextdraws][4] = CreatePlayerTextDraw(playerid, 331.666687, 272.118469, global_str);
									PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][4], 0.162000, 0.927999);
									PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][4], 2);
									PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][4], -1);
									PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][4], 0);
									PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][4], 1);
									PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventDataTextdraws][4], 51);
									PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][4], 1);
									PlayerTextDrawSetProportional(playerid, Player[playerid][AEventDataTextdraws][4], 1);
									PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][4]);
									
									if(Player[playerid][AEventDataTicks] > 6)
									{
										for(new i; i < A_MAX_DATA_TEXTDRAWS; i++)
										{
											if(Player[playerid][AEventDataTextdraws][i] != PlayerText:INVALID_TEXT_DRAW) DestroyPlayerTextdraw(playerid, Player[playerid][AEventDataTextdraws][i]);
										}
										Player[playerid][ATasksState][Player[playerid][AEventData]] = A_TASK_DONE;
										A_OnPlayerCompleteTask(playerid, Player[playerid][ALobby]);
									}
								}
							}
							case A_EVENT_MEDSCAN:
							{
								Player[playerid][AEventDataTicks]++;
								format(global_str, 20, "Scan Complete in %d", 3-Player[playerid][AEventDataTicks]);
								DestroyPlayerTextdraw(playerid, Player[playerid][AEventDataTextdraws][1]);
								Player[playerid][AEventDataTextdraws][1] = CreatePlayerTextDraw(playerid, 243.333328, 313.185119, global_str);
								PlayerTextDrawLetterSize(playerid, Player[playerid][AEventDataTextdraws][1], 0.244333, 1.583408);
								PlayerTextDrawAlignment(playerid, Player[playerid][AEventDataTextdraws][1], 1);
								PlayerTextDrawColor(playerid, Player[playerid][AEventDataTextdraws][1], -1);
								PlayerTextDrawSetShadow(playerid, Player[playerid][AEventDataTextdraws][1], 0);
								PlayerTextDrawSetOutline(playerid, Player[playerid][AEventDataTextdraws][1], 1);
								PlayerTextDrawBackgroundColor(playerid, Player[playerid][AEventDataTextdraws][1], 51);
								PlayerTextDrawFont(playerid, Player[playerid][AEventDataTextdraws][1], 1);
								PlayerTextDrawSetProportional(playerid, Player[playerid][AEventDataTextdraws][1], 1);
								PlayerTextDrawShow(playerid, Player[playerid][AEventDataTextdraws][1]);
								
								if(Player[playerid][AEventDataTicks] >= 3)
								{
									DestroyAmongusTextdraws(playerid, A_DATA_TEXTDRAW_TYPE);
									Player[playerid][ATasksState][Player[playerid][AEventData]] = A_TASK_DONE;
									A_OnPlayerCompleteTask(playerid, Player[playerid][ALobby]);
								}
							}
						}
					}
				}
			}
		}
	}
	return 1;
}
stock A_KillPlayer(lobbyid, i, bool:CreateBody = false, bool:AddToDeadCount = true)
{
	new killedid = A_Lobby[lobbyid][APlayers][i];
	if(!Player[killedid][AIsDead])
	{
		new Float:X, Float:Y, Float:Z, Float:A;
		GetPlayerPos(killedid, X, Y, Z);
		GetPlayerFacingAngle(killedid, A);
		
		Player[killedid][AIsDead] = true;
		if(CreateBody)
		{
			// Создаем труп
			if(A_Lobby[lobbyid][ADeadBodies][i] == INVALID_ACTOR_ID) 
			{
				A_Lobby[lobbyid][ADeadBodies][i] = CreateActor(GetPlayerSkin(killedid), X, Y, Z, A);
				SetActorInvulnerable(A_Lobby[lobbyid][ADeadBodies][i], false);
				SetActorHealth(A_Lobby[lobbyid][ADeadBodies][i], 0.0);
				SetActorVirtualWorld(A_Lobby[lobbyid][ADeadBodies][i], lobbyid+2);
			}
		}
		
		A_PlayerChangeState(killedid, Player[killedid][ALobby], A_STATE_SPECTATE);
		
		if(Player[A_Lobby[lobbyid][APlayers][i]][AIsImpostor]) A_Lobby[lobbyid][AImpostorsDeadCount]++;
		else if(AddToDeadCount) A_Lobby[lobbyid][ADeadCount]++;
		
		if(A_Lobby[lobbyid][ADeadCount] >= A_Lobby[lobbyid][APlayersCount]-A_Lobby[lobbyid][AMaxImpostors] || A_Lobby[lobbyid][AImpostorsDeadCount] >= A_Lobby[lobbyid][AMaxImpostors] || A_Lobby[lobbyid][APlayersCount]-A_Lobby[lobbyid][ADeadCount]-A_Lobby[lobbyid][AMaxImpostors] < 2) A_OnMatchEnd(lobbyid, A_END_MATCH);
	}
	return 1;
}
stock A_CreateVotingForPlayer(playerid, lobbyid)
{
	Player[playerid][AVotingTextdraws][40] = CreatePlayerTextDraw(playerid, 173.666687, 96.237030, "amongus:votingscreen");
	PlayerTextDrawLetterSize(playerid, Player[playerid][AVotingTextdraws][40], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player[playerid][AVotingTextdraws][40], 305.666870, 270.459289);
	PlayerTextDrawAlignment(playerid, Player[playerid][AVotingTextdraws][40], 1);
	PlayerTextDrawColor(playerid, Player[playerid][AVotingTextdraws][40], -1);
	PlayerTextDrawSetShadow(playerid, Player[playerid][AVotingTextdraws][40], 0);
	PlayerTextDrawSetOutline(playerid, Player[playerid][AVotingTextdraws][40], 0);
	PlayerTextDrawFont(playerid, Player[playerid][AVotingTextdraws][40], 4);

	Player[playerid][AVotingTextdraws][41] = CreatePlayerTextDraw(playerid, 192.000015, 321.481475, "amongus:skip_vote");
	PlayerTextDrawLetterSize(playerid, Player[playerid][AVotingTextdraws][41], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player[playerid][AVotingTextdraws][41], 54.666687, 15.762969);
	PlayerTextDrawAlignment(playerid, Player[playerid][AVotingTextdraws][41], 1);
	PlayerTextDrawColor(playerid, Player[playerid][AVotingTextdraws][41], -1);
	PlayerTextDrawSetShadow(playerid, Player[playerid][AVotingTextdraws][41], 0);
	PlayerTextDrawSetOutline(playerid, Player[playerid][AVotingTextdraws][41], 0);
	PlayerTextDrawFont(playerid, Player[playerid][AVotingTextdraws][41], 4);
	PlayerTextDrawSetSelectable(playerid, Player[playerid][AVotingTextdraws][41], true);

	Player[playerid][AVotingTextdraws][42] = CreatePlayerTextDraw(playerid, 399.000030, 322.725891, "skip voting in: 0:59");
	PlayerTextDrawLetterSize(playerid, Player[playerid][AVotingTextdraws][42], 0.171998, 1.172739);
	PlayerTextDrawAlignment(playerid, Player[playerid][AVotingTextdraws][42], 2);
	PlayerTextDrawColor(playerid, Player[playerid][AVotingTextdraws][42], -1);
	PlayerTextDrawSetShadow(playerid, Player[playerid][AVotingTextdraws][42], 1);
	PlayerTextDrawSetOutline(playerid, Player[playerid][AVotingTextdraws][42], 0);
	PlayerTextDrawBackgroundColor(playerid, Player[playerid][AVotingTextdraws][42], 51);
	PlayerTextDrawFont(playerid, Player[playerid][AVotingTextdraws][42], 2);
	PlayerTextDrawSetProportional(playerid, Player[playerid][AVotingTextdraws][42], 1);

	Player[playerid][AVotingTextdraws][43] = CreatePlayerTextDraw(playerid, 325.333343, 110.925857, "WHO IS IMPOSTOR?");
	PlayerTextDrawLetterSize(playerid, Player[playerid][AVotingTextdraws][43], 0.256998, 1.753481);
	PlayerTextDrawAlignment(playerid, Player[playerid][AVotingTextdraws][43], 2);
	PlayerTextDrawColor(playerid, Player[playerid][AVotingTextdraws][43], -1);
	PlayerTextDrawSetShadow(playerid, Player[playerid][AVotingTextdraws][43], 0);
	PlayerTextDrawSetOutline(playerid, Player[playerid][AVotingTextdraws][43], -1);
	PlayerTextDrawBackgroundColor(playerid, Player[playerid][AVotingTextdraws][43], 51);
	PlayerTextDrawFont(playerid, Player[playerid][AVotingTextdraws][43], 2);
	PlayerTextDrawSetProportional(playerid, Player[playerid][AVotingTextdraws][43], 1);

	PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][40]);
	PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][41]);
	PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][42]);
	PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][43]);
	
	new Float:OffsetX, Float:OffsetY, PlayersCount, str[MAX_PLAYER_NAME];
	for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
	{
		if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
		{
			if(!Player[A_Lobby[lobbyid][APlayers][i]][AIsDead])
			{
				Player[playerid][AVotingTextdraws][i*4] = CreatePlayerTextDraw(playerid, 187.666702+OffsetX, 130.592575+OffsetY, "amongus:nameframe");
				PlayerTextDrawLetterSize(playerid, Player[playerid][AVotingTextdraws][i*4], 0.000000, 0.000000);
				PlayerTextDrawTextSize(playerid, Player[playerid][AVotingTextdraws][i*4], 124.666709, 31.111148);
				PlayerTextDrawAlignment(playerid, Player[playerid][AVotingTextdraws][i*4], 1);
				PlayerTextDrawColor(playerid, Player[playerid][AVotingTextdraws][i*4], -56);
				PlayerTextDrawSetShadow(playerid, Player[playerid][AVotingTextdraws][i*4], 0);
				PlayerTextDrawSetOutline(playerid, Player[playerid][AVotingTextdraws][i*4], 0);
				PlayerTextDrawFont(playerid, Player[playerid][AVotingTextdraws][i*4], 4);
				PlayerTextDrawSetSelectable(playerid, Player[playerid][AVotingTextdraws][i*4], true);

				Player[playerid][AVotingTextdraws][(i*4)+1] = CreatePlayerTextDraw(playerid, 172.000030+OffsetX, 121.051826+OffsetY, "amongus:amogus");
				PlayerTextDrawLetterSize(playerid, Player[playerid][AVotingTextdraws][(i*4)+1], 0.000000, 0.000000);
				PlayerTextDrawTextSize(playerid, Player[playerid][AVotingTextdraws][(i*4)+1], 57.000015, 55.170402);
				PlayerTextDrawAlignment(playerid, Player[playerid][AVotingTextdraws][(i*4)+1], 1);
				PlayerTextDrawColor(playerid, Player[playerid][AVotingTextdraws][(i*4)+1], -1);
				PlayerTextDrawSetShadow(playerid, Player[playerid][AVotingTextdraws][(i*4)+1], 0);
				PlayerTextDrawSetOutline(playerid, Player[playerid][AVotingTextdraws][(i*4)+1], 0);
				PlayerTextDrawFont(playerid, Player[playerid][AVotingTextdraws][(i*4)+1], 4);
				
				GetPlayerName(A_Lobby[lobbyid][APlayers][i], str, MAX_PLAYER_NAME);
				Player[playerid][AVotingTextdraws][(i*4)+2] = CreatePlayerTextDraw(playerid, 211.666641+OffsetX, 138.548095+OffsetY, str);
				PlayerTextDrawLetterSize(playerid, Player[playerid][AVotingTextdraws][(i*4)+2], 0.138332, 1.425776);
				PlayerTextDrawAlignment(playerid, Player[playerid][AVotingTextdraws][(i*4)+2], 1);
				PlayerTextDrawColor(playerid, Player[playerid][AVotingTextdraws][(i*4)+2], -1);
				PlayerTextDrawSetShadow(playerid, Player[playerid][AVotingTextdraws][(i*4)+2], 1);
				PlayerTextDrawSetOutline(playerid, Player[playerid][AVotingTextdraws][(i*4)+2], 0);
				PlayerTextDrawBackgroundColor(playerid, Player[playerid][AVotingTextdraws][(i*4)+2], 51);
				PlayerTextDrawFont(playerid, Player[playerid][AVotingTextdraws][(i*4)+2], 2);
				PlayerTextDrawSetProportional(playerid, Player[playerid][AVotingTextdraws][(i*4)+2], 1);
				PlayersCount++;
				OffsetX += 134.666672;
				
				if(!(PlayersCount%2))
				{
					OffsetX = 0;
					OffsetY += 35;
				}
				
				PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][i*4]);
				PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][(i*4)+1]);
				PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][(i*4)+2]);
			}
		}
	}
	for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++) // Текстдравы перекрывают этот, создаем его после остальных
	{
		if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
		{
			if(!Player[A_Lobby[lobbyid][APlayers][i]][AIsDead])
			{
				Player[playerid][AVotingTextdraws][(i*4)+3] = CreatePlayerTextDraw(playerid, 0.0, 0.0, "amongus:amogus");
				PlayerTextDrawLetterSize(playerid, Player[playerid][AVotingTextdraws][(i*4)+3], 0.000000, 0.000000);
				PlayerTextDrawTextSize(playerid, Player[playerid][AVotingTextdraws][(i*4)+3], 24.333354, 24.888917);
				PlayerTextDrawAlignment(playerid, Player[playerid][AVotingTextdraws][(i*4)+3], 1);
				PlayerTextDrawColor(playerid, Player[playerid][AVotingTextdraws][(i*4)+3], -1);
				PlayerTextDrawSetShadow(playerid, Player[playerid][AVotingTextdraws][(i*4)+3], 0);
				PlayerTextDrawSetOutline(playerid, Player[playerid][AVotingTextdraws][(i*4)+3], 0);
				PlayerTextDrawFont(playerid, Player[playerid][AVotingTextdraws][(i*4)+3], 4);
			}
		}
	}
	
	Player[playerid][AVotingTextdraws][44] = CreatePlayerTextDraw(playerid, 0.0, 0.0, "amongus:yes");
	PlayerTextDrawLetterSize(playerid, Player[playerid][AVotingTextdraws][44], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player[playerid][AVotingTextdraws][44], 24.333354/1.5, 24.888917/1.5);
	PlayerTextDrawAlignment(playerid, Player[playerid][AVotingTextdraws][44], 1);
	PlayerTextDrawColor(playerid, Player[playerid][AVotingTextdraws][44], -1);
	PlayerTextDrawSetShadow(playerid, Player[playerid][AVotingTextdraws][44], 0);
	PlayerTextDrawSetOutline(playerid, Player[playerid][AVotingTextdraws][44], 0);
	PlayerTextDrawFont(playerid, Player[playerid][AVotingTextdraws][44], 4);
	
	Player[playerid][AVotingTextdraws][45] = CreatePlayerTextDraw(playerid, 0.0, 0.0, "amongus:no");
	PlayerTextDrawLetterSize(playerid, Player[playerid][AVotingTextdraws][45], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, Player[playerid][AVotingTextdraws][45], 24.333354/1.5, 24.888917/1.5);
	PlayerTextDrawAlignment(playerid, Player[playerid][AVotingTextdraws][45], 1);
	PlayerTextDrawColor(playerid, Player[playerid][AVotingTextdraws][45], -1);
	PlayerTextDrawSetShadow(playerid, Player[playerid][AVotingTextdraws][45], 0);
	PlayerTextDrawSetOutline(playerid, Player[playerid][AVotingTextdraws][45], 0);
	PlayerTextDrawFont(playerid, Player[playerid][AVotingTextdraws][45], 4);
	
	PlayerTextDrawSetSelectable(playerid, Player[playerid][AVotingTextdraws][44], true);
	PlayerTextDrawSetSelectable(playerid, Player[playerid][AVotingTextdraws][45], true);
}

stock A_OnPlayerVoteTextdraw(playerid, lobbyid, clickedid, PlayerText:ptd = PlayerText:INVALID_TEXT_DRAW)
{
	new Float:X, Float:Y;
	
	if(Player[playerid][APreviousClickedVoteTextdraw] != -1) 
	{
		if(IsPlayerTextDrawVisible(playerid, Player[playerid][AVotingTextdraws][Player[playerid][APreviousClickedVoteTextdraw]]))
		{
			PlayerTextDrawSetSelectable(playerid, Player[playerid][AVotingTextdraws][Player[playerid][APreviousClickedVoteTextdraw]], 1);
			PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][Player[playerid][APreviousClickedVoteTextdraw]]);
		}
	}
	
	if(clickedid < 40)
	{
		if(PlayerTextDrawIsSelectable(playerid, ptd))
		{
			PlayerTextDrawGetPos(playerid, ptd, X, Y);
			PlayerTextDrawSetPos(playerid, Player[playerid][AVotingTextdraws][44], X+60.0, Y+7.0);
			PlayerTextDrawSetPos(playerid, Player[playerid][AVotingTextdraws][45], X+80.0, Y+7.0);
			PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][44]);
			PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][45]);
			PlayerTextDrawSetSelectable(playerid, ptd, 0);
			PlayerTextDrawShow(playerid, ptd);
		}
	}
	else
	{
		switch(clickedid)
		{
			case 44: // Принял
			{
				if(Player[playerid][APreviousClickedVoteTextdraw] == 41) // Нажал на skip vote
				{
					new myid;
					
					for(; myid < A_MAX_PLAYERS_IN_LOBBY; myid++)
						if(A_Lobby[lobbyid][APlayers][myid] == playerid) break;
					
					PlayerTextDrawGetPos(playerid, Player[playerid][AVotingTextdraws][41], X, Y);
					
					for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
					{
						if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
						{
							PlayerTextDrawSetPos(A_Lobby[lobbyid][APlayers][i], Player[A_Lobby[lobbyid][APlayers][i]][AVotingTextdraws][(myid * 4) + 3], X+(A_Lobby[lobbyid][AVoteSkips]*10.0), Y-20.0);
							PlayerTextDrawShow(A_Lobby[lobbyid][APlayers][i], Player[A_Lobby[lobbyid][APlayers][i]][AVotingTextdraws][(myid * 4) + 3]);
						}
					}
					
					A_Lobby[lobbyid][AVoteSkips] ++;
					
				}
				else
				{
					new myid, 
						playerlobbyid = Player[playerid][APreviousClickedVoteTextdraw]/4;
						
					for(; myid < A_MAX_PLAYERS_IN_LOBBY; myid++)
						if(A_Lobby[lobbyid][APlayers][myid] == playerid) break;
					
					Player[A_Lobby[lobbyid][APlayers][playerlobbyid]][AVotesCount]++;
					
					PlayerTextDrawGetPos(A_Lobby[lobbyid][APlayers][playerlobbyid], Player[A_Lobby[lobbyid][APlayers][playerlobbyid]][AVotingTextdraws][playerlobbyid * 4], X, Y);
					
					for(new i; i < A_MAX_PLAYERS_IN_LOBBY; i++)
					{
						if(A_Lobby[lobbyid][APlayers][i] != INVALID_PLAYER_ID)
						{
							PlayerTextDrawSetPos(A_Lobby[lobbyid][APlayers][i], Player[A_Lobby[lobbyid][APlayers][i]][AVotingTextdraws][(myid * 4) + 3], X+(A_Lobby[lobbyid][AVotePlayersCount]*10.0), Y+15.0);
							PlayerTextDrawShow(A_Lobby[lobbyid][APlayers][i], Player[A_Lobby[lobbyid][APlayers][i]][AVotingTextdraws][(myid * 4) + 3]);
						}
					}

					
					A_Lobby[lobbyid][AVotePlayersCount]++;
				}
				
				for(new i; i < A_MAX_VOTING_TEXTDRAWS; i++)
				{
					if(Player[playerid][AVotingTextdraws][i] != PlayerText:INVALID_TEXT_DRAW) 
					{
						if(IsPlayerTextDrawVisible(playerid, Player[playerid][AVotingTextdraws][i]))
						{
							PlayerTextDrawSetSelectable(playerid, Player[playerid][AVotingTextdraws][i], false);
							PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][i]);
						}
					}
				}
				
				PlayerTextDrawHide(playerid, Player[playerid][AVotingTextdraws][44]);
				PlayerTextDrawHide(playerid, Player[playerid][AVotingTextdraws][45]);
				PlayerTextDrawSetSelectable(playerid, Player[playerid][AVotingTextdraws][Player[playerid][APreviousClickedVoteTextdraw]], false);
				PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][Player[playerid][APreviousClickedVoteTextdraw]]);
			}
			case 45: // Отменил
			{
				PlayerTextDrawHide(playerid, Player[playerid][AVotingTextdraws][44]);
				PlayerTextDrawHide(playerid, Player[playerid][AVotingTextdraws][45]);
				PlayerTextDrawSetSelectable(playerid, Player[playerid][AVotingTextdraws][Player[playerid][APreviousClickedVoteTextdraw]], true);
				PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][Player[playerid][APreviousClickedVoteTextdraw]]);
			}
			case 41:
			{
				if(PlayerTextDrawIsSelectable(playerid, ptd))
				{
					PlayerTextDrawGetPos(playerid, ptd, X, Y);
					PlayerTextDrawSetPos(playerid, Player[playerid][AVotingTextdraws][44], X+60.0, Y);
					PlayerTextDrawSetPos(playerid, Player[playerid][AVotingTextdraws][45], X+80.0, Y);
					PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][44]);
					PlayerTextDrawShow(playerid, Player[playerid][AVotingTextdraws][45]);
					PlayerTextDrawSetSelectable(playerid, ptd, false);
					PlayerTextDrawShow(playerid, ptd);
				}
			}
		}
	}
	Player[playerid][APreviousClickedVoteTextdraw] = clickedid;
}

stock DestroyAmongusTextdraws(playerid, Comma)
{
	switch(Comma)
	{
		case A_STATE_TEXTDRAW_TYPE:
		{
			for(new i; i < A_MAX_STATE_TEXTDRAWS; i++)
			{
				if(Player[playerid][AEventStateTextdraws][i] != PlayerText:INVALID_TEXT_DRAW) DestroyPlayerTextdraw(playerid, Player[playerid][AEventStateTextdraws][i]);
			}
		}
		case A_DATA_TEXTDRAW_TYPE:
		{
			for(new i; i < A_MAX_DATA_TEXTDRAWS; i++)
			{
				if(Player[playerid][AEventDataTextdraws][i] != PlayerText:INVALID_TEXT_DRAW) DestroyPlayerTextdraw(playerid, Player[playerid][AEventDataTextdraws][i]);
			}
		}
		case A_STATIC_TEXTDRAW_TYPE:
		{
			for(new i; i < A_MAX_STATIC_TEXTDRAWS; i++)
			{
				if(Player[playerid][AStaticTextdraws][i] != PlayerText:INVALID_TEXT_DRAW) DestroyPlayerTextdraw(playerid, Player[playerid][AStaticTextdraws][i]);
			}
		}
		case A_VOTE_TEXTDRAW_TYPE:
		{
			for(new i; i < A_MAX_VOTING_TEXTDRAWS; i++)
			{
				if(Player[playerid][AVotingTextdraws][i] != PlayerText:INVALID_TEXT_DRAW) DestroyPlayerTextdraw(playerid, Player[playerid][AVotingTextdraws][i]);
			}
		}
	}
}
stock DestroyPlayerTextdraw(playerid, &PlayerText:td)
{
	if(td != PlayerText:INVALID_TEXT_DRAW)
	{
		PlayerTextDrawDestroy(playerid, td);
		td = PlayerText:INVALID_TEXT_DRAW;
	}
}
stock SetString(param_1[], const param_2[], size = 300) return strmid(param_1, param_2, 0, strlen(param_2), size);
stock Min(a, b)
{
	if(a < b) return a;
	return b;
}
stock Max(a, b)
{
	if(a > b) return a;
	return b;
}

stock ConvertToTime(number)
{
    new hours = 0, mins = 0, secs = 0, string[30];
    hours = floatround(number / 3600);
    mins = floatround((number / 60) - (hours * 60));
    secs = floatround(number - ((hours * 3600) + (mins * 60)));
    if(hours > 0) format(string, sizeof string, "%i:%02d:%02d", hours, mins, secs);
    else format(string, sizeof string, "%i:%02d", mins, secs);
    return string;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/lobby", false)) ShowLobbyDialog(playerid);
	else if(!strcmp(cmdtext, "/exitlobby", false) && Player[playerid][ALobby] != A_INVALID_LOBBY_ID) A_PlayerChangeState(playerid, Player[playerid][ALobby], A_STATE_NULL);
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch dialogid do
	{
		case 12390:
		{
			if !response *then return false;
			if(A_OnPlayerRequestJoin(playerid, listitem)) A_OnPlayerJoinToMatch(playerid, listitem);
		}
		case 1:
		{
			if(!response) return false;
			A_PlayerChangeState(playerid, Player[playerid][ALobby], A_STATE_NULL);
		}
	}
	return true;
}
stock ShowLobbyDialog(playerid)
{
	global_str = "Номер\tКоличество\n";
	for(new i; i < A_MAX_LOBBIES; i++) format(global_str, 250, "%s{ffffff}Номер №%i.\t{FFC900}%d/10\n", global_str, i+1, A_Lobby[i][APlayersCount]);
	return ShowPlayerDialog(playerid, 12390, DIALOG_STYLE_TABLIST_HEADERS, "Выберите лобби", global_str, "Выбрать", "Отмена");
}
