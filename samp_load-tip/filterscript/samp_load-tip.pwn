 /**                                                                                  ***
 *		  Filterscript: Samp Load-Tip system                                            *
 *	Autor:	 	_l0stfake7 <barpon@gmail.com>                                           *
 *				 	                                                                    *
 *  Podziękowania:        Kalcor,                                                       *
 *                                                                                      *
 *	Wersja:		0.1.0                                                               	*
 *	Licencja:		GNU General Public License, version 2                               *
 *	                                                                                    *
 *	Zapraszam na: pawno.pl - najlepszy support pawn                                     *
 ***                                                                                  **/   
 
 #define FILTERSCRIPT
 #include <a_samp>//0.3z RC3
 #include <tdbox>//1.0
 #include <playerprogress>
 #include <zcmd>
 
 #define MAX_TIP_HEADER_LENGHT 32
 #define MAX_TIP_TEXT_LENGHT 128
 #define DEFAULT_TIP_TIME 10000
 #define REFRESH_TIP 100
 
 new PlayerText:tTipBackground[MAX_PLAYERS];
 new PlayerBar:tTipBar[MAX_PLAYERS];
 
 new const tGrandTheftAutoBackgrounds[][] = {
	"loadsc0:loadsc0",
	"loadsc1:loadsc1",
	"loadsc2:loadsc2",
	"loadsc3:loadsc3",
	"loadsc4:loadsc4",
	"loadsc5:loadsc5",
	"loadsc6:loadsc6",
	"loadsc7:loadsc7",
	"loadsc8:loadsc8",
	"loadsc9:loadsc9",
	"loadsc10:loadsc10",
	"loadsc11:loadsc11",
	"loadsc12:loadsc12",
	"loadsc13:loadsc13",
	"loadsc14:loadsc14"
};

forward fnTipTimer(iPlayerid, iTipCount);
public fnTipTimer(iPlayerid, iTipCount)
{
	if(iTipCount==100)
	{
		HidePlayerProgressBar(iPlayerid, tTipBar[iPlayerid]);
		PlayerTextDrawHide(iPlayerid, tTipBackground[iPlayerid]);
	}
	else
	{
		if(iTipCount==1)
			SetPlayerProgressBarValue(iPlayerid, tTipBar[iPlayerid], 100);
		else
			SetPlayerProgressBarValue(iPlayerid, tTipBar[iPlayerid], GetPlayerProgressBarValue(iPlayerid, tTipBar[iPlayerid])+100);
		UpdatePlayerProgressBar(iPlayerid, tTipBar[iPlayerid]);
		SetTimerEx("fnTipTimer", 100, 0, "dd", iPlayerid, iTipCount+1);
	}
}

stock fnTip(iPlayerid, sHeader[], const sTip[], const iTime = DEFAULT_TIP_TIME, bool:bIgnore = false)
{
	if(IsPlayerConnected(iPlayerid) && strlen(sHeader) <= MAX_TIP_HEADER_LENGHT && strlen(sTip) <= MAX_TIP_TEXT_LENGHT)
	{
		if(bIgnore == true)
			PlayerTextDrawSetSelectable(iPlayerid, tTipBackground[iPlayerid], 1);		
		PlayerTextDrawSetString(iPlayerid, tTipBackground[iPlayerid], tGrandTheftAutoBackgrounds[random(sizeof(tGrandTheftAutoBackgrounds))]);
		PlayerTextDrawShow(iPlayerid, tTipBackground[iPlayerid]);
		TD_SendMessage(iPlayerid, sTip, sHeader, iTime);
		SetPlayerProgressBarMaxValue(iPlayerid, tTipBar[iPlayerid],10000);
		ShowPlayerProgressBar(iPlayerid, tTipBar[iPlayerid]);
		SetPlayerProgressBarValue(iPlayerid, tTipBar[iPlayerid], 0.0);
		UpdatePlayerProgressBar(iPlayerid, tTipBar[iPlayerid]);	
		
		SetTimerEx("fnTipTimer", 100, 0, "dd", iPlayerid, 1, 100);
	}
}

public OnPlayerConnect(playerid)
{
	tTipBackground[playerid] = CreatePlayerTextDraw(playerid, -0.333333, -0.414818, "load0uk:load0uk");
	PlayerTextDrawLetterSize(playerid, tTipBackground[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, tTipBackground[playerid], 643.999633, 448.830017);
	PlayerTextDrawAlignment(playerid, tTipBackground[playerid], 1);
	PlayerTextDrawColor(playerid, tTipBackground[playerid], -1);
	PlayerTextDrawSetShadow(playerid, tTipBackground[playerid], 0);
	PlayerTextDrawSetOutline(playerid, tTipBackground[playerid], 0);
	PlayerTextDrawFont(playerid, tTipBackground[playerid], 4);
	tTipBar[playerid] = CreatePlayerProgressBar(playerid, 207.00, 179.00, 232.50, 2.50, -16776961, 1000.0);
}

CMD:test(playerid, params[])
{
	fnTip(playerid, "Tip", "Jak bedziesz czitowal to zarobisz bana", 10000, false);
	return 1;
}