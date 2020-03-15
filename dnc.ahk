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
color := Ceil(color)
transparency := transparency



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

bD:= {}
bD.sectorTopX:= sectorTopX
bD.sectorTopY:= sectorTopY
bD.sectorWidth:= sectorWidth
bD.sectorHeight:= sectorHeight
bD.newX:= currentMouseX
bD.newY:= currentMouseY

BackAll:=Object()

DrawGrid(bD)

BackAll.Insert(bD)

currentBox := bD

Loop {

	if (depth >= MAX_DEPTH) {
		CleanUpGui()
		break
	}
	
	Input, userInput, T5 L1, {Escape}{Space}, w,e,r,s,d,f,x,c,v

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
		if(depth>0)
		{
			currentBox:= GoBack(BackAll)
			depth:= depth - 1
		}
	}
	else
	{
		
		if userInput in x,c,v,s,d,f,w,e,r
		{
			currentBox:= computeNewBox(currentBox, userInput)
			moveMouseToCellCenter(currentBox)
			DrawGrid(currentBox)

			BackAll.Insert(currentBox)			
			depth := depth + 1
			
			if ErrorLevel = Max { }

			if ErrorLevel = NewInput
				return
		}
	}
}
return



moveMouseToCellCenter(currentBox)
{
	xpos:= currentBox.newX
	ypos:= currentBox.newY
	MouseMove, xpos, ypos
}

computeNewBox(currentBox, selection)
{
	newBox := currentBox.Clone()
	newBox.sectorWidth := Floor(newBox.sectorWidth/3)
	newBox.sectorHeight := Floor(newBox.sectorHeight/3)

	if selection in c,d,e
		newBox.sectorTopX := newBox.sectorTopX + newBox.sectorWidth
	if selection in v,f,r
		newBox.sectorTopX := newBox.sectorTopX + (2*newBox.sectorWidth)

	if selection in x,c,v
		newBox.sectorTopY := newBox.sectorTopY + (2*newBox.sectorHeight)
	if selection in s,d,f
		newBox.sectorTopY := newBox.sectorTopY + newBox.sectorHeight

	newBox.newX := newBox.sectorTopX + Floor(newBox.sectorWidth/2)
	newBox.newY := newBox.sectorTopY + Floor(newBox.sectorHeight/2)

	return newBox
}

calculateMaxDepth(screenSize) {
	tmpHeight := screenSize
	
	Loop {
		tmpHeight := tmpHeight / 3

		if (tmpHeight <= 3) {
			return %A_Index%
		}
	}
}

GoBack(history)
{
	history.remove(history.MaxIndex())
	BackOne := history[history.MaxIndex()]
	
	moveMouseToCellCenter(BackOne)
	DrawGrid(BackOne)
	return BackOne
}

DrawGrid(boxDefinition){
	bD := boxDefinition.Clone()
	drawRect(bD.sectorTopX, bD.sectorTopY, bD.sectorWidth, 1, 1)
	drawRect(bD.sectorTopX + bD.sectorWidth - 1, bD.sectorTopY, 1, bD.sectorHeight, 2)
	drawRect(bD.sectorTopX, bD.sectorTopY + bD.sectorHeight - 1, bD.sectorWidth, 1, 3)
	drawRect(bD.sectorTopX, bD.sectorTopY, 1, bD.sectorHeight, 4)

	drawRect(bD.sectorTopX, bD.sectorTopY + Floor(bD.sectorHeight/3), bD.sectorWidth, 1, 5)
	drawRect(bD.sectorTopX, bD.sectorTopY + Ceil(2 * (bD.sectorHeight/3)), bD.sectorWidth, 1, 6)
	
	drawRect(bD.sectorTopX + Floor(bD.sectorWidth/3), bD.sectorTopY, 1, bD.sectorHeight, 7)
	drawRect(bD.sectorTopX + Ceil(2 * (bD.sectorWidth/3)), bD.sectorTopY, 1, bD.sectorHeight, 8)
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
	CleanUpGui()
	exit
}
	

ClickLeft()
{
	CleanUpGui()
	click
	exit
}

ClickRight()
{
	CleanUpGui()
	Click right
	exit
}

ClickDouble()
{
	CleanUpGui()
	Click 2
	exit
}

LoadConfigurationFile()
{
	global
	IfNotExist,%iniFile%
	{
		IniWrite,^NumpadMult,%iniFile%,Settings,hotkey
		IniWrite,FF3333,%iniFile%,Settings,color
		IniWrite,70,%iniFile%,Settings,transparency
	}
	IniRead,hotkey,%iniFile%,Settings,hotkey
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