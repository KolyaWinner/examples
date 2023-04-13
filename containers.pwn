#define SetFloatPosData(%0,%1,%2,%3) %0[0] = %1, %0[1] = %2, %0[2] = %3

const MAX_RADMIR_CONTAINERS = 7;

enum radmircont
{
	cont_owner_id,
	cont_money,
	cont_type,
	cont_status,
	cont_timer,
	cont_from,
	cont_object[3],
	Float:cont_position[3],
	Text3D:cont_text[2],
	cont_car
};

new radmir_container[MAX_RADMIR_CONTAINERS][radmircont];

new Float:radmir_cont_vehicle_pos[MAX_RADMIR_CONTAINERS][3] = 
{
	{-1958.8539,2932.0823,7.6542},
	{-1942.0539,2932.0823,7.6542},
	{-1925.2539,2932.0823,7.6542},
	{-1908.4539,2932.0823,7.6542},
	{-1932.6007,2926.4312,8.1144},
	{-1915.8007,2926.4312,8.1144},
	{-1899.0007,2926.4312,8.1144}
};
//IsPlayerInDynamicArea
new radmir_container_zone;

cmd:tp_cont(playerid) return SetPlayerPos(playerid, -1965.6470,2932.1155,7.8827);

cmd:contspawn(playerid)
{
	if(GetPlayerAdminEx(playerid) != 7) return false;
	for(new i; i < MAX_RADMIR_CONTAINERS; i ++)
	{
		if(!radmir_container[i][cont_status])
		{
			radmir_container_delete(i);
			radmir_container_install(i, random(5));
		}
	}
	SCM(playerid, 0xAFAFAFFF, !"Новые контейнеры (Транспортное средство) заспавнены на свободные места");
	return SendMessageContainer("{DC973A}В порт доставлена новая партия контейнеров.");
}

stock radmir_container_install(id, from = 0) // 0 dubai 1 - usa 2 - europe 3 - rf
{
	new obj[3], Float:arg;
	switch(from)
	{
		case 0: obj = {10466, 10474, 10475}, radmir_container[id][cont_money] = 12000000;
		case 1: obj = {10465, 10472, 10473}, radmir_container[id][cont_money] = 5500000;
		case 2: obj = {10464, 10461, 10462}, radmir_container[id][cont_money] = 5500000;
		case 3: obj = {10476, 10459, 10460}, radmir_container[id][cont_money] = 300000;
		case 4: obj = {10728, 10726, 10727}, radmir_container[id][cont_money] = 1800000;
	}
	
	switch(id)
	{
		case 0..3:
		{
			arg = 16.8 * id;
			radmir_container[id][cont_object][0] = CreateDynamicObject(obj[0], -1959.691650 + arg, 2932.064208, 6.402674, 0.000000, 0.000000, -90.099952, 0, 0, -1, 300.00, 300.00); 
			radmir_container[id][cont_object][1] = CreateDynamicObject(obj[1], -1965.258422 + arg, 2933.387451, 7.052675, 0.000000, 0.000000, 0.000000, 0, 0, -1, 300.00, 300.00); 
			radmir_container[id][cont_object][2] = CreateDynamicObject(obj[2], -1965.272705 + arg, 2930.868164, 7.052674, 0.000000, 0.000000, 0.000000, 0, 0, -1, 300.00, 300.00); 
		
			radmir_container[id][cont_text][0] = CreateDynamic3DTextLabel("-", 0xDCDBDBFF, -1960.0588 + arg, 2932.1738, 10.6995, 20.0);
			radmir_container[id][cont_text][1] = CreateDynamic3DTextLabel("-", 0xDCDBDBFF, -1965.4698 + arg, 2932.1394, 8.0060, 20.0);
		}
		default:
		{
			arg = 16.8 * (id-4);
			radmir_container[id][cont_object][0] = CreateDynamicObject(obj[0], -1933.381713 + arg, 2926.536132, 6.402674, 0.000000, 0.000000, -90.099952, 0, 0, -1, 300.00, 300.00); 
			radmir_container[id][cont_object][1] = CreateDynamicObject(obj[1], -1938.938232 + arg, 2927.853271, 7.052675, 0.000000, 0.000000, 0.000000, 0, 0, -1, 300.00, 300.00); 
			radmir_container[id][cont_object][2] = CreateDynamicObject(obj[2], -1938.950439 + arg, 2925.330810, 7.052674, 0.000000, 0.000000, 0.000000, 0, 0, -1, 300.00, 300.00); 

			radmir_container[id][cont_text][0] = CreateDynamic3DTextLabel("-", 0xDCDBDBFF, -1932.4875 + arg, 2926.6438, 10.6995, 20.0);
			radmir_container[id][cont_text][1] = CreateDynamic3DTextLabel("-", 0xDCDBDBFF, -1939.3417 + arg, 2926.5894, 8.0060, 20.0);
			
		}
	}
	
	radmir_container[id][cont_owner_id] = INVALID_PLAYER_ID;
	radmir_container[id][cont_from] = from;
	radmir_container[id][cont_status] = true;
	radmir_container[id][cont_timer] = 30;
	SetFloatPosData(radmir_container[id][cont_position], radmir_cont_vehicle_pos[id][0] - 6.5, radmir_cont_vehicle_pos[id][1], radmir_cont_vehicle_pos[id][2]);

	format( STRING_GLOBAL, 350, "{F1F1F1}Используйте {F1BC2E}L.ALT {F1F1F1}чтобы \nоткрыть торги за контейнер начальная \nстоимость которого составляет: {DC973A}%d руб", radmir_container[id][cont_money]);
	UpdateDynamic3DTextLabelText(radmir_container[id][cont_text][1], 0xDCDBDBFF, STRING_GLOBAL);
	return radmir_container_update(id);
}

stock radmir_container_delete(id)
{
	for(new i; i < 3; i ++) DestroyDynamicObject(radmir_container[id][cont_object][i]);

	switch(radmir_container[id][cont_status])
	{
		case 1: for(new i; i < 2; i++) DestroyDynamic3DTextLabel(radmir_container[id][cont_text][i]);
		case 2,3: DestroyDynamic3DTextLabel(radmir_container[id][cont_text][1]);
	}
		
	radmir_container[id][cont_owner_id] = INVALID_PLAYER_ID;
	radmir_container[id][cont_from] = -1;
	radmir_container[id][cont_status] = false;
	return false;
}

stock radmir_container_update(id)
{
	switch(radmir_container[id][cont_from])
	{
		case 0: STRING_GLOBAL = "{F0DA4D}Объединённые Арабские Эмираты";
		case 1: STRING_GLOBAL = "{4F7AB0}Соединенные Штаты Америки";
		case 2: STRING_GLOBAL = "{55A0FA}Европейский Союз";
		case 3: STRING_GLOBAL = "{FF6347}Российская Федерация";
		case 4: STRING_GLOBAL = "{D36F11}Китайская Народная Республика";
	}
	
	format( STRING_GLOBAL, 250, "%s \n{F1F1F1}Вес: {DCBD3A}3500.00 кг (№%d) \n{F1F1F1}Содержимое: {C1D369}Транспорт \n{F1F1F1}Стоимость: {DC973A}%d руб", STRING_GLOBAL, id + 1 , radmir_container[id][cont_money]);
	return UpdateDynamic3DTextLabelText(radmir_container[id][cont_text][0], 0xDCDBDBFF, STRING_GLOBAL);
}

stock radmir_container_timer_update()
{
	for(new id; id < MAX_RADMIR_CONTAINERS; id ++)
	{
		if(radmir_container[id][cont_status]) && radmir_container[id][cont_timer] && !(radmir_container[id][cont_owner_id] == INVALID_PLAYER_ID)
		{
			radmir_container[id][cont_timer]--;
			format( STRING_GLOBAL, 400, "{F1F1F1}Контейнер {F69E00}№%d \n{F1F1F1}До конца торгов осталось {E9C700}%d {F1F1F1}сек \n\n{F1F1F1}Текущая стоимость: {F65D00}%d руб \n{F1F1F1}Предложил: {BEAB4A}%s \n\n{F1F1F1}Используйте {F1BC2E}L.ALT {F1F1F1}чтобы оценить стоимость \nэтого контейнера в свою пользу", id + 1, radmir_container[id][cont_timer], radmir_container[id][cont_money], GetPlayerNameEx(radmir_container[id][cont_owner_id]));
			
			if(!radmir_container[id][cont_timer])
			{
				radmir_container[id][cont_status] = 2;
				format( STRING_GLOBAL, 400, "{BEAB4A}Контейнер Был продан за {F65D00}%d руб.\n\n{F1F1F1}Вы владелец? Используйте {F1BC2E}L.ALT {F1F1F1}чтобы снять замок", radmir_container[id][cont_money]);
				UpdateDynamic3DTextLabelText(radmir_container[id][cont_text][0], 0xDCDBDBFF, !"");
			}
			UpdateDynamic3DTextLabelText(radmir_container[id][cont_text][1], 0xDCDBDBFF, STRING_GLOBAL);
		}
	}
	return false;
}
		
stock radmir_container_car_spawn(id)
{
	new model;
	switch(radmir_container[id][cont_from])
	{
		case 0..3:
		{
			switch(random(1000))
			{
				default:
				{
					new random_model[33] = {400,402,405,409,410,415,429,451,466,480,489,490,494,502,503,505,506,533,541,543,558,573,579,587,602,604,605,793,794,795,796,797,798};
					model = random_model[ random ( sizeof random_model ) ];
				}
			}
		}
		case 4:
		{
			switch(random(1000))
			{
				case 0..100: model = 560; // subaru
				case 101..200: model = 559; // supra
				case 201..300: model = 15065; // chaser
				case 301..400: model = 15068; // mark2
				case 401..500: model = 15068; // camry v50
				case 501..600: model = 15118; // prado
				case 601..700: model = 15125; // lancer
				case 701..800: model = 562; // r-34
				case 801..900: model = 15090; // silvia
				case 901..950: model = 503; // GTR
				case 951..999: model = 15131; // imprezza
			}
		}
	}

	radmir_container[id][cont_car] = CreateVehicle(model, radmir_cont_vehicle_pos[id][0], radmir_cont_vehicle_pos[id][1], radmir_cont_vehicle_pos[id][2], 90.0, random(255), random(255), -1, 0, VEHICLE_ACTION_TYPE_ADMIN_CAR, 0);
	DestroyDynamic3DTextLabel(radmir_container[id][cont_text][1]);
	radmir_container[id][cont_text][1] = CreateDynamic3DTextLabel("{99CC00}Транспортное средство\n{F1F1F1}Используйте {F1BC2E}L.ALT {F1F1F1}чтобы \nпринять решение по этому транспорту", 0xDCDBDBFF, radmir_cont_vehicle_pos[id][0], radmir_cont_vehicle_pos[id][1], radmir_cont_vehicle_pos[id][2] + 1.0, 20.0);
	SetFloatPosData(radmir_container[id][cont_position], radmir_cont_vehicle_pos[id][0] - 2.5, radmir_cont_vehicle_pos[id][1], radmir_cont_vehicle_pos[id][2]);
}

stock SendMessageContainer(msg[])
{
	foreach(Player, i)
	{
		if(IsPlayerInDynamicArea(i, radmir_container_zone)) SCM(i, -1, msg);
	}
	return false;
}

stock radmir_container_door(id)
{
	new Float:x, Float:y, Float:z, status = radmir_container[id][cont_status];

	GetDynamicObjectPos(radmir_container[id][cont_object][1], x,y,z);
	MoveDynamicObject(radmir_container[id][cont_object][1], x + (status == 3 ? 0.036255:-0.036255), y + (status == 3 ? 0.001709:-0.001709), z, 0.025, 0.000000, 0.000000, status == 3 ? 0.0:-120.499969);
	GetDynamicObjectPos(radmir_container[id][cont_object][2], x,y,z);
	MoveDynamicObject(radmir_container[id][cont_object][2], x + (status == 3 ? 0.035766:-0.035766), y + (status == 3 ? 0.005126:-0.005126), z, 0.025, 0.000000, 0.000000, status == 3 ? 0.0:132.099761);
	
	return false;
}

public: radmir_container_back(id) radmir_container_delete(id);

stock radmir_container_givecar(playerid, id, model, color_1, color_2)
{
	new modelid, idx, Float: pos_veh[3], Float: angle = random(30) > 15 ? 270.0:90.0;
	modelid = model;	
	
	idx = GetFreeOwnableCarID();

	pos_veh[0] = radmir_cont_vehicle_pos[id][0];
	pos_veh[1] = radmir_cont_vehicle_pos[id][1] + ( id < 4 ? 5.0:-5.0);
	pos_veh[2] = radmir_cont_vehicle_pos[id][2] - 1.5;
	
	SetOwnableCarData(idx, OC_OWNER_ID, 	GetPlayerAccountID(playerid));
	
	SetOwnableCarData(idx, OC_MODEL_ID, 	modelid);
	SetOwnableCarData(idx, OC_COLOR_1, 		color_1);
	SetOwnableCarData(idx, OC_COLOR_2, 		color_2);
	
	SetOwnableCarData(idx, OC_POS_X, 		pos_veh[0]);
	SetOwnableCarData(idx, OC_POS_Y, 		pos_veh[1]);
	SetOwnableCarData(idx, OC_POS_Z, 		pos_veh[2]);
	SetOwnableCarData(idx, OC_ANGLE, 		angle);
	
	strmid(g_ownable_car[idx][OC_NUMBER], "------", 0, 8, 8);

	SetOwnableCarData(idx, OC_ALARM, 		false);
	SetOwnableCarData(idx, OC_KEY_IN, 		false);

	SetOwnableCarData(idx, OC_CREATE, 		gettime());
	
	format(g_ownable_car[idx][OC_OWNER_NAME], 21, GetPlayerNameEx(playerid));
	
	// ----------------------------------------------------------------------------------------
		
	new vehicleid = CreateVehicle
	(
		modelid,
		GetOwnableCarData(idx, OC_POS_X), 
		GetOwnableCarData(idx, OC_POS_Y), 
		GetOwnableCarData(idx, OC_POS_Z), 
		GetOwnableCarData(idx, OC_ANGLE), 
		GetOwnableCarData(idx, OC_COLOR_1), 
		GetOwnableCarData(idx, OC_COLOR_2),
		-1, 
		0, 
		VEHICLE_ACTION_TYPE_OWNABLE_CAR,
		idx
	);
	if(vehicleid != INVALID_VEHICLE_ID)
	{
		CreateVehicleLabel(vehicleid, GetOwnableCarData(idx, OC_NUMBER), 0xFFFF00EE, 0.0, 0.0, 1.3, 20.0);
		SetVehicleParam(vehicleid, V_LOCK, false);
		
		SetVehicleData(vehicleid, V_MILEAGE, 0.0);
	}

	format
	(
		STRING_GLOBAL, 700, 
		"INSERT INTO `ownable_cars` (`owner_id`, `model_id`, `color_1`, `color_2`, `pos_x`, `pos_y`, `pos_z`, `angle`, `create_time`) VALUES ('%d','%d','%d','%d','%f','%f','%f','%f','%d')",
		GetPlayerAccountID(playerid), 
		modelid,
		color_1,
		color_2,
		pos_veh[0],
		pos_veh[1],
		pos_veh[2],
		angle,
		gettime()
	);
	mysql_tquery(mysql, STRING_GLOBAL, "CarSQLAdd", "d", idx);

	return SetPlayerData(playerid, P_OWNABLE_CAR, vehicleid);
}

stock radmir_container_player_delete(playerid)
{
	for(new id; id < MAX_RADMIR_CONTAINERS; id++)
	{
		if(radmir_container[id][cont_owner_id] == playerid && radmir_container[id][cont_status])
        {
			radmir_container_delete(id);
        }
	}
}
