 /**                                                                                  ***
 *		  Filterscript: Samp TurnSignal                                                 *
 *	Autor:	 	_l0stfake7 <barpon@gmail.com>                                           *
 *				 	                                                                    *
 *  Podziękowania:        Kalcor, Incognito, Gorniczek(KaZ)                             *
 *                                                                                      *
 *	Wersja:		0.1.1                                                               	*
 *	Licencja:		GNU General Public License, version 2                               *
 *	                                                                                    *
 *	Zapraszam na: pawno.pl - najlepszy support pawn                                     *
 ***                                                                                  **/   

#define FILTERSRCIPT
#include <a_samp>//0.3z RC2
#include <streamer>//2.7.2

#define KLAWISZ_PRAWOSKRETNY KEY_ANALOG_RIGHT
#define KLAWISZ_LEWOSKRETNY KEY_ANALOG_LEFT

#define BRAK_KIERUNKOWSKAZU 0
#define PRAWY_KIERUNKOWSKAZ 1
#define LEWY_KIERUNKOWSKAZ 2

#define ILOSC_POJAZDOW MAX_VEHICLES

#define WCISNIETY(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

enum dPojazd {
	iObiektKierunkowskazu[3],
	iUzywanyKierunkowskaz
}
new iPojazd[ILOSC_POJAZDOW][dPojazd];
static const Float:iPozycjaKierunkowskazu[211][3];

bool:fnCzyMoznaWlaczycKierunkowskaz(iModelPojazdu) {
	static iNieuzywaneModele[22] = {
		435, 441, 449, 450, 464, 465, 481, 501, 509, 510, 564, 569, 570, 584, 590, 591, 594, 606, 607, 608, 610, 611
	};
	for(new iLicznik = 0; iLicznik < sizeof(iNieuzywaneModele); ++iLicznik) {
		if(iModelPojazdu == iNieuzywaneModele[iLicznik]) {
			return false;
		}
	}
	return true;
}

fnUstalPozycjeKierunkowskazow()
{
	for(new iModelPojazdu = 0; iModelPojazdu < 211; ++iModelPojazdu) {
		if(fnCzyMoznaWlaczycKierunkowskaz(iModelPojazdu+400) == true) {
			GetVehicleModelInfo(iModelPojazdu+400, VEHICLE_MODEL_INFO_SIZE, iPozycjaKierunkowskazu[iModelPojazdu][0], iPozycjaKierunkowskazu[iModelPojazdu][1], iPozycjaKierunkowskazu[iModelPojazdu][2]);
		}
	}
	return 1;
}

fnUsunKierunkowskaz(iIdentyfikatorPojazdu, iTypKierunkowskazu) {
	switch(iTypKierunkowskazu) {
		case LEWY_KIERUNKOWSKAZ: {			
			DestroyDynamicObject(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][0]);
			DestroyDynamicObject(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][1]);
			if(GetVehicleTrailer(iIdentyfikatorPojazdu))
				DestroyDynamicObject(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][2]);		
		}
		case PRAWY_KIERUNKOWSKAZ: {
			DestroyDynamicObject(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][0]);
			DestroyDynamicObject(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][1]);
			if(GetVehicleTrailer(iIdentyfikatorPojazdu))
				DestroyDynamicObject(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][2]);
		}
		default: printf("Funkcja fnUsunKierunkowskaz wywolana z nieznanym parametrem: %d (identyfikator pojazdu: %d)", iTypKierunkowskazu, iIdentyfikatorPojazdu);
	}
	iPojazd[iIdentyfikatorPojazdu][iUzywanyKierunkowskaz] = BRAK_KIERUNKOWSKAZU;
}

fnUstawKierunkowskaz(iIdentyfikatorPojazdu, iTypKierunkowskazu, bool:blnStartoweWywolanie=false) {	
	if(fnCzyMoznaWlaczycKierunkowskaz(GetVehicleModel(iIdentyfikatorPojazdu))) {				
		switch(iTypKierunkowskazu) {
			case LEWY_KIERUNKOWSKAZ: {
				if(iPojazd[iIdentyfikatorPojazdu][iUzywanyKierunkowskaz] == BRAK_KIERUNKOWSKAZU || blnStartoweWywolanie == true) {
					iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][0] = CreateDynamicObject(19294, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
					iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][1] = CreateDynamicObject(19294, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);					
					AttachDynamicObjectToVehicle(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][0], iIdentyfikatorPojazdu, -floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][0], 3.0), floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][1], 2.4), -0.1, 0.0, 0.0, 0.0);
					AttachDynamicObjectToVehicle(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][1], iIdentyfikatorPojazdu, -floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][0], 3.0), -floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][1], 2.3), -0.1, 0.0, 0.0, 0.0);
					if(GetVehicleTrailer(iIdentyfikatorPojazdu)) {
						new iIdentyfikatorNaczepy=GetVehicleTrailer(iIdentyfikatorPojazdu);
						iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][2] = CreateDynamicObject(19294, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
						AttachDynamicObjectToVehicle(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][2], iIdentyfikatorNaczepy, -floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][0], 3.0), -floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][1], 2.4), -0.1, 0.0, 0.0, 0.0);
					}
					iPojazd[iIdentyfikatorPojazdu][iUzywanyKierunkowskaz] = LEWY_KIERUNKOWSKAZ;
				}
				else {
					fnUsunKierunkowskaz(iIdentyfikatorPojazdu, iPojazd[iIdentyfikatorPojazdu][iUzywanyKierunkowskaz]); 
				}
			}
			case PRAWY_KIERUNKOWSKAZ: {
				if(iPojazd[iIdentyfikatorPojazdu][iUzywanyKierunkowskaz] == BRAK_KIERUNKOWSKAZU || blnStartoweWywolanie == true) {		
					iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][0] = CreateDynamicObject(19294, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
					iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][1] = CreateDynamicObject(19294, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
					AttachDynamicObjectToVehicle(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][0], iIdentyfikatorPojazdu, floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][0], 3.0), floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][1], 2.4), -0.1, 0.0, 0.0, 0.0);
					AttachDynamicObjectToVehicle(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][1], iIdentyfikatorPojazdu, floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][0], 3.0), -floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][1], 2.3), -0.1, 0.0, 0.0, 0.0);
					if(GetVehicleTrailer(iIdentyfikatorPojazdu)) {
						new iIdentyfikatorNaczepy=GetVehicleTrailer(iIdentyfikatorPojazdu);
						iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][2] = CreateDynamicObject(19294, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
						AttachDynamicObjectToVehicle(iPojazd[iIdentyfikatorPojazdu][iObiektKierunkowskazu][2], iIdentyfikatorNaczepy, floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][0], 3.0), -floatdiv(iPozycjaKierunkowskazu[GetVehicleModel(iIdentyfikatorPojazdu)-400][1], 2.4), -0.1, 0.0, 0.0, 0.0);
					}
					iPojazd[iIdentyfikatorPojazdu][iUzywanyKierunkowskaz] = PRAWY_KIERUNKOWSKAZ;
				}
				else {
					fnUsunKierunkowskaz(iIdentyfikatorPojazdu, iPojazd[iIdentyfikatorPojazdu][iUzywanyKierunkowskaz]); 
				}
			}
			default: printf("Funkcja fnUstawKierunkowskaz wywolana z nieznanym parametrem: %d (identyfikator pojazdu: %d, startowe wywolanie: %s)", iTypKierunkowskazu, iIdentyfikatorPojazdu, (blnStartoweWywolanie)?("tak"):("nie"));
		}
	}
    return 1;
}

public OnFilterScriptInit()
{
	print("/************************************************************");
	print("*\tSkrypt: Samp TurnSignal");
	print("*\tAutor:	_l0stfake7 <barpon@gmail.com>");
	print("*");
	print("*\tPodziękowania: Kalcor, Incognito, Gorniczek(KaZ)");
	print("*");
	print("*\tWersja: 0.1.1");
	print("*\tLicencja: GNU General Public License, version 2");
	print("*");
	print("*\tZapraszam na: pawno.pl - najlepszy support pawn");
	print("************************************************************/");
	fnUstalPozycjeKierunkowskazow();
	return 1;
}

public OnFilterScriptExit()
{
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)	{
		if(WCISNIETY(KEY_ANALOG_RIGHT)) {
			fnUstawKierunkowskaz(GetPlayerVehicleID(playerid), PRAWY_KIERUNKOWSKAZ);
		}
		if(WCISNIETY(KEY_ANALOG_LEFT)) {
			fnUstawKierunkowskaz(GetPlayerVehicleID(playerid), LEWY_KIERUNKOWSKAZ);	
		}
	}
	return 1;
}