//
// #LB_TDBox
// Text Draw Message Box
// ---------------------
// Sends a message box to a playerid. If the input text is to long the function
// automaticly stops, creates a new line and continues writing. Also supports
// ~n~ to not exceed the background box.
//
// If you wish to send the text without the background box just use an invisible
// color for the box (e.g. 0xFFAAFF00). If you want to change the text color use
// as following ~y~, ~r~ ...
//
// 'padding' defines the space between text and box while 'BaseX' and 'BaseY'
// set the actual text and box position. Note that the function checks whether
// the text would exceed the screen and aligns the position of the box!
//
// If 'hide_in' is set to 0 or anything below the text box will not disappear
// after time. You then have to use 'TD_HideMessage()' or the box will be hidden
// when the function gets used a second time for a player!
//
//  	!!!	Max amount of Lines that can be used is 10 !!!
//
// Version 1.0
//
// 	~ LeBoyce 2013
//

#if defined _tdbox_inc
	#endinput
#endif
#define _tdbox_inc

/*

native TD_SendMessage(playerid, const string_[], header[], hide_in = 5000, bgcolor = 12840, Float:padding = 24.0000, Float:BaseX = 319.000000, Float:BaseY = 231.000000, length = 90);
native TD_HideMessage(playerid);

*/

#define LIMIT_LEFT  2.0000
#define LIMIT_RIGHT 634.0000
#define LIMIT_BOTTOM  436.0000
#define LIMIT_TOP 2.0000

// Callbacks
forward TD_HideAll(playerid, hide_in);

// settings player lists
new
	PlayerText:G_TEXTDRAW[MAX_PLAYERS][12],
	G_TEXTDRAW_MESSAGE[MAX_PLAYERS][12][128],
	P_TDRAWS[MAX_PLAYERS],
	bool:P_HEADER[MAX_PLAYERS],
	E_TD_TIMER[MAX_PLAYERS],
	P_TEXTDRAW_SIZE[MAX_PLAYERS],
	P_TEXTDRAW_SIZE_LONGEST[MAX_PLAYERS],
	E_LAST[MAX_PLAYERS],
	PlayerText:Td_Header[MAX_PLAYERS]
;


//------------------------------------------------

TD_CreateBgBox(playerid, bgcolor, Float:startX, Float:BaseY, Float:padding, Float:length)
{
    G_TEXTDRAW[playerid][0] = CreatePlayerTextDraw(playerid, (startX - padding), BaseY + (P_HEADER[playerid] ? 1.0 : 0.0), "_");
	PlayerTextDrawLetterSize(playerid, G_TEXTDRAW[playerid][0], 0.169999, 0.899999+float(P_TDRAWS[playerid]));
	PlayerTextDrawBoxColor(playerid, G_TEXTDRAW[playerid][0], bgcolor);
	PlayerTextDrawTextSize(playerid, G_TEXTDRAW[playerid][0], (startX + length + padding + 3.0000), 24.000000);
   	PlayerTextDrawBackgroundColor(playerid, G_TEXTDRAW[playerid][0], 255);
	PlayerTextDrawFont(playerid, G_TEXTDRAW[playerid][0], 1);
	PlayerTextDrawColor(playerid, G_TEXTDRAW[playerid][0], -1);
 	PlayerTextDrawSetOutline(playerid, G_TEXTDRAW[playerid][0], 0);
	PlayerTextDrawSetProportional(playerid, G_TEXTDRAW[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, G_TEXTDRAW[playerid][0], 1);
	PlayerTextDrawUseBox(playerid, G_TEXTDRAW[playerid][0], 1);
	PlayerTextDrawShow(playerid, G_TEXTDRAW[playerid][0]);
}

//------------------------------------------------

TD_CreateTextMessages(playerid, Float:startX, Float:BaseY)
{
    for(new i = 1; i != P_TDRAWS[playerid]; i++)
	{
	    G_TEXTDRAW[playerid][i] = CreatePlayerTextDraw(playerid, startX, BaseY+(9.0*float(i)), G_TEXTDRAW_MESSAGE[playerid][i]);
		PlayerTextDrawBackgroundColor(playerid, G_TEXTDRAW[playerid][i], 255);
		PlayerTextDrawFont(playerid, G_TEXTDRAW[playerid][i], 2);
		PlayerTextDrawLetterSize(playerid, G_TEXTDRAW[playerid][i], 0.170000, 1.000000);
		PlayerTextDrawColor(playerid, G_TEXTDRAW[playerid][i], -1);
		PlayerTextDrawSetOutline(playerid, G_TEXTDRAW[playerid][i], 0);
		PlayerTextDrawSetProportional(playerid, G_TEXTDRAW[playerid][i], 1);
		PlayerTextDrawSetShadow(playerid, G_TEXTDRAW[playerid][i], 0);
		PlayerTextDrawShow(playerid, G_TEXTDRAW[playerid][i]);
		format(G_TEXTDRAW_MESSAGE[playerid][i], 128, "0");
	}
}

//------------------------------------------------

TD_CreateHeader(playerid, header[], Float:startX, Float:BaseY, Float:padding)
{
    if(header[0] == '\0' || header[0] == ' ') 
		header[0] = '_', P_HEADER[playerid] = true;
    else 
		P_HEADER[playerid] = false;

	Td_Header[playerid] = CreatePlayerTextDraw(playerid, startX - 1.0 - padding, BaseY - 7.0, header);
	PlayerTextDrawBackgroundColor(playerid, Td_Header[playerid], 255);
	PlayerTextDrawFont(playerid, Td_Header[playerid], 2);
	PlayerTextDrawLetterSize(playerid, Td_Header[playerid], 0.260000, 1.000000);
	PlayerTextDrawColor(playerid, Td_Header[playerid], -1);
	PlayerTextDrawSetOutline(playerid, Td_Header[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Td_Header[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Td_Header[playerid], 1);
	PlayerTextDrawShow(playerid, Td_Header[playerid]);
}

//------------------------------------------------

stock TD_HideMessage(playerid)
{
    if(P_TDRAWS[playerid] != 0)     {   KillTimer(E_TD_TIMER[playerid]);TD_HideAll(playerid, 0);   }
	return 1;
}

//------------------------------------------------

stock require_LetterLength(player_id, string[])
{
	new
	    var[1]
 	;
	var[0] = tolower(string[0]);
	switch(var[0])
	{
	    case 'a', 'c', 'f', 'h', 'l', 'm', 'o', 'p', 'r', 's', 'u', 'v', 'x', 'z', /**/'b', 'd', 'e', 'g', 'j', 'k', 'n', 'q', 't', 'y'/**/, 0..9, '!', '.', ',', ':', ';':
		{
		    if(E_LAST[player_id] == 4)
		    {
		        E_LAST[player_id] = 5;
				return 5;
			}
			else
			{
			    E_LAST[player_id] = 4;
				return 4;
			}
	    }
	    case 'w': return 6;
	}
	return 2;
}

//------------------------------------------------

stock TD_SendMessage(playerid, const string_[], header[], hide_in = 5000, bgcolor = 12840, Float:padding = 24.0000, Float:BaseX = 319.000000, Float:BaseY = 231.000000, length = 90)
{
	P_TEXTDRAW_SIZE_LONGEST[playerid] = 0;

	if(P_TDRAWS[playerid] != 0)     {   KillTimer(E_TD_TIMER[playerid]); TD_HideAll(playerid, 0);   }

	if(length > 90) length = 90;
	
	new
	    count,
		pos,
		td = 1,
		string[1024]
	;

	do  { string[pos] = string_[pos]; pos++; } while(string_[pos] != '\0');

	pos = 0;

	do
	{
	    new
	        bMessage[128]
		;
		do
		{
      		while(!count && !!pos && string[++pos] == ' ') continue;

			if(string[pos] == '~' && string[pos+1] == 'n' && string[pos+2] == '~') { string[pos] = '_'; string[pos+1] = '_'; pos += 2; string[pos] = ' '; break; }

			bMessage[count] = string[pos];
			count++;
			pos++;
 		}
		while(count < length && string[pos] != '\0' || count > length - 1 && string[pos] != ' ' && string[pos] != '\0');

		new
		    stringPos = 0
		;

		P_TEXTDRAW_SIZE[playerid] = 0;

		while(bMessage[stringPos++] != '\0') { P_TEXTDRAW_SIZE[playerid] += require_LetterLength(playerid, bMessage[stringPos]); }

		if(P_TEXTDRAW_SIZE[playerid] > P_TEXTDRAW_SIZE_LONGEST[playerid])   {   P_TEXTDRAW_SIZE_LONGEST[playerid] = P_TEXTDRAW_SIZE[playerid];	}

		format(G_TEXTDRAW_MESSAGE[playerid][td], 128, "%s", bMessage);
		count = 0;
		td++;
	}
	while(string[pos] != '\0');

	P_TDRAWS[playerid] = (td);

	new
		Float:Length = float(P_TEXTDRAW_SIZE_LONGEST[playerid]),
        Float:X = BaseX - Length / 2,
        Float:Y = BaseY,
		Rows = P_TDRAWS[playerid]
	;

	if(X - padding < LIMIT_LEFT)   {

		X += (LIMIT_LEFT - (X - padding));
	}
	else if(X + Length + padding > LIMIT_RIGHT)   {

		X += (LIMIT_RIGHT - (X + Length + padding));
	}
	if(Y < LIMIT_TOP) {

		Y = LIMIT_TOP;
	}
	else if (Y + float(Rows * 9) > LIMIT_BOTTOM) {

		Y = LIMIT_BOTTOM - (float(Rows * 9));
	}

	TD_CreateHeader(playerid, header, X, Y, padding);

	TD_CreateBgBox(playerid, bgcolor, X, Y, padding, Length);

	TD_CreateTextMessages(playerid, X, Y);

	if(hide_in != 0) SetTimerEx("TD_HideAll", 100, false, "ii", playerid, hide_in);
	return 1;
}

//------------------------------------------------

public TD_HideAll(playerid, hide_in)
{
	if(hide_in != 0) {   
		E_TD_TIMER[playerid] = SetTimerEx("TD_HideAll", hide_in, false, "ii", playerid, 0);	
	}
	else {
	    for(new i = 0; i != P_TDRAWS[playerid]; i++) 
		{   
			PlayerTextDrawHide(playerid, G_TEXTDRAW[playerid][i]);
			PlayerTextDrawDestroy(playerid, G_TEXTDRAW[playerid][i]);	
		}
		PlayerTextDrawHide(playerid, Td_Header[playerid]);
		PlayerTextDrawDestroy(playerid, Td_Header[playerid]);P_TDRAWS[playerid] = 0;
	}
	return 1;
}