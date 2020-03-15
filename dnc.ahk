;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Michael Soza
; Based upon the 'Mouser' AutoHotkey script by Adam Pash <adam.pash@gmail.com>
; Based upon DNC from Petr 'Vorkronor' Stedry (petr.stedry@gmail.com)

#SingleInstance,Force 
#Include trayWindow\aboutWindow.ahk
SetWinDelay,0 

iniFile = dnc.ini
LoadConfigurationFile()
GenerateTrayMenu()
overlayEnabled := overlayEnabled
color := Ceil(color)
transparency := transparency

return

Home::
Gosub, START

START:
CoordMode, Mouse, Screen
MouseGetPos, currentMouseX, currentMouseY

SysGet, resolution, Monitor

lastSector := 0	

currentMonitor := GetMonitorMouse()
SysGet, Monitor, Monitor, %currentMonitor%
sectorTopX := MonitorLeft
sectorTopY := 0
sectorWidth := (MonitorRight-MonitorLeft)
sectorHeight := MonitorBottom


GetMonitorMouse()
{
    MouseGetPos, x, y
	
	SysGet, MonitorCount, MonitorCount
    
	Loop, %MonitorCount%
	{
		SysGet, Monitor, Monitor, %A_Index%
	
		if(x >= MonitorLeft && x <= MonitorRight)
		{	
			return %A_Index%
		}
	}
}



MAX_DEPTH := calculateMaxDepth(resolutionBottom)
depth := 0

BackAll:=Object()
BackOne:= [ currentMouseX, currentMouseY,sectorTopX,sectorTopY,sectorWidth,sectorHeight]
BackAll.Insert(BackOne)


if overlayEnabled {
	DrawGrid()
}


Loop {
	if (depth >= MAX_DEPTH) {
		CleanUpGui()
		break
	}
	
	MouseGetPos, currentMouseX, currentMouseY
	
	Input, userInput, T5 L1, {Escape}{Space}

	if ErrorLevel = Timeout
		continue
	
	if userInput = j
		ClickLeft()

	if userInput = l
		ClickRight()

	if userInput = k
		ClickDouble()

	IfInString, ErrorLevel, EndKey:Escape
		Quit()

	IfInString, ErrorLevel, EndKey:Space
	{
		GoBack()
	}
	else
	{

		lastSector := 0
		if userInput in x,c,v,s,d,f,w,e,r
			lastSector := userInput

		sectorWidth := Floor(sectorWidth/3)
		sectorHeight := Floor(sectorHeight/3)
		
		if userInput in c,d,e
			sectorTopX := sectorTopX + sectorWidth
		if userInput in v,f,r
			sectorTopX := sectorTopX + (2*sectorWidth)

		if userInput in x,c,v
			sectorTopY := sectorTopY + (2*sectorHeight)
		if userInput in s,d,f
			sectorTopY := sectorTopY + sectorHeight
		
		
		newX := sectorTopX + Floor(sectorWidth/2)
		newY := sectorTopY + Floor(sectorHeight/2)
	
		if (lastSector != 0) {
			MouseMove, %newX%, %newY%
	
			if overlayEnabled {
				DrawGrid()
				BackOne:= [newX,newY,sectorTopX,sectorTopY,sectorWidth,sectorHeight]
				BackAll.Insert(BackOne)
			}

			depth := depth + 1
		}
		
		if ErrorLevel = Max { }

		if ErrorLevel = NewInput
			return
	}
}
return

calculateMaxDepth(screenSize) {
	tmpHeight := screenSize
	
	Loop {
		tmpHeight := tmpHeight / 3

		if (tmpHeight <= 3) {
			return %A_Index%
		}
	}
}

GoBack()
{
	global
	if(depth>0)
	{
		BackAll.remove(BackAll.MaxIndex())
		depth--
		BackOne := BackAll[BackAll.MaxIndex()]
		newX:=		BackOne[1]
		newY:=		BackOne[2]
		sectorTopX:=	BackOne[3]
		sectorTopY:=    BackOne[4]	
		sectorWidth:=   BackOne[5]
		sectorHeight:=  BackOne[6]
		MouseMove, %newX%, %newY%
		DrawGrid()
	}
}

DrawGrid(){
	global
	drawRect(sectorTopX, sectorTopY, sectorWidth, 1, 1)
	drawRect(sectorTopX + sectorWidth - 1, sectorTopY, 1, sectorHeight, 2)
	drawRect(sectorTopX, sectorTopY + sectorHeight - 1, sectorWidth, 1, 3)
	drawRect(sectorTopX, sectorTopY, 1, sectorHeight, 4)

	drawRect(sectorTopX, sectorTopY + Floor(sectorHeight/3), sectorWidth, 1, 5)
	drawRect(sectorTopX, sectorTopY + Ceil(2 * (sectorHeight/3)), sectorWidth, 1, 6)
	
	drawRect(sectorTopX + Floor(sectorWidth/3), sectorTopY, 1, sectorHeight, 7)
	drawRect(sectorTopX + Ceil(2 * (sectorWidth/3)), sectorTopY, 1, sectorHeight, 8)
}

drawRect(x, y, width, height, winNo) {
	Gui, %winNo%: +AlwaysOnTop -Caption +LastFound +ToolWindow
	Gui, %winNo%: Color, 666666
	WinSet, TransColor, %color% %transparency%
	Gui, %winNo%: Show, x%x% y%y% w%width% h%height% noactivate
}

CleanUpGui()
{
	global
	Gui,1: Destroy
	Gui,2: Destroy
	Gui,3: Destroy
	Gui,4: Destroy
	Gui,5: Destroy
	Gui,6: Destroy
	Gui,7: Destroy
	Gui,8: Destroy
	BackAll:=Object()
}


Quit()
{
	global
	if (overlayEnabled) {
		CleanUpGui()
	}
	exit
}
	

ClickLeft()
{
	global
	if (overlayEnabled) {
		CleanUpGui()
	}
	click
	exit
}

ClickRight()
{
	global
	if (overlayEnabled) {
		CleanUpGui()
	}
	Click right
	exit
}

ClickDouble()
{
	global
	if (overlayEnabled) {
		CleanUpGui()
	}
	Click 2
	exit
}

LoadConfigurationFile()
{
	global
	IfNotExist,%iniFile%
	{
		IniWrite,^NumpadMult,%iniFile%,Settings,hotkey
		IniWrite,1,%iniFile%,Settings,overlayEnabled
		IniWrite,FF3333,%iniFile%,Settings,color
		IniWrite,70,%iniFile%,Settings,transparency
	}
	IniRead,hotkey,%iniFile%,Settings,hotkey
	IniRead,overlayEnabled,%iniFile%,Settings,overlayEnabled
	IniRead,color,%iniFile%,Settings,color
	IniRead,transparency,%iniFile%,Settings,transparency
	HotKey,%hotkey%,START
}

GenerateTrayMenu()
{
	global
	Menu,Tray,NoStandard 
	Menu,Tray,DeleteAll 
	Menu,Tray,Add,DnC,ABOUT
	Menu,Tray,Add,
	Menu,Tray,Add,&Settings...,SETTINGS
	Menu,Tray,Add,&About...,ABOUT
	Menu,Tray,Add,E&xit,EXIT
	Menu,Tray,Default,DnC
	Menu,Tray,Tip,Divide and Conquer
}

SETTINGS:
	HotKey,%hotkey%,Off
	Gui,9: Destroy
	Gui,9: Add,GroupBox,xm ym w400 h70,&Hotkey
	Gui,9: Add,Hotkey,xp+10 yp+20 w380 vshotkey
	StringReplace,current,hotkey,+,Shift +%A_Space%
	StringReplace,current,current,^,Ctrl +%A_Space%
	StringReplace,current,current,!,Alt +%A_Space%
	Gui,9: Add, Text,,Current hotkey: %current%
	Gui,9: Add, Checkbox, xp yp+32 vsvisualizations_cbox Checked%overlayEnabled%, Show targeting grid
	Gui,9: Add, GroupBox, xm y+10 w400 h55,&Grid transparency (0 to 250; default:70; currently:%transparency%):
	Gui,9: Add, Slider, xp+10 yp+20 w380 vstransparency Range0-250 ToolTipRight TickInterval25, %transparency%
	Gui,9: Add, Button, xm y+30 w75 GSETTINGSOK,&OK
	Gui,9: Add, Button, x+5 w75 GSETTINGSCANCEL,&Cancel
	Gui,9: Show,,Mouser Settings
return

SETTINGSOK:
	Gui,9: Submit
	If shotkey<>
	{
	  hotkey:=shotkey
	  HotKey,%hotkey%,START
	}
	HotKey,%hotkey%,On
	If stransparency<>
	  transparency:=stransparency
	if svisualizations_cbox<>
	  overlayEnabled := svisualizations_cbox
	IniWrite,%hotkey%,%iniFile%,Settings,hotkey
	IniWrite,%overlayEnabled%,%iniFile%,Settings,overlayEnabled
	IniWrite,%transparency%,%iniFile%,Settings,transparency
	IniWrite,%checkbox%, %iniFile%, Settings,checkbox
	Gui,9: Destroy
	
	if (!overlayEnabled) {
		CleanUpGui()
	}
return

SETTINGSCANCEL:
	HotKey,%hotkey%,START,On
	HotKey,%hotkey%,On
	Gui,9: Destroy
return


GuiEscape:
	Gui,Destroy

return


AutohotkeyHome:
	run http://www.autohotkey.com
return

MouserHome:
	run http://lifehacker.com/software/mouser/hack-attack-operate-your-mouse-with-your-keyboard-212816.php
return

EXIT:
	ExitApp
