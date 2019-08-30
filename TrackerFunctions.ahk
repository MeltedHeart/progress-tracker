; /// Tracker Library ///

BoiBox()
{
	MsgBox, BOI
}

DisableAllGui()
{
	WinGet, ActiveControlList, ControlList, A
	Loop, Parse, ActiveControlList, `n
	{
		GuiControl, Disable, %A_LoopField%
	}
}

EnableAllGui()
{
	WinGet, ActiveControlList, ControlList, A
	Loop, Parse, ActiveControlList, `n
	{
		GuiControl, Enable, %A_LoopField%
	}
}

DisableAllMenus()
{
	Menu, MainMenuBar, Disable, &File
	Menu, MainMenuBar, Disable, &Help
}

EnableAllMenus()
{
	Menu, MainMenuBar, Enable, &File
	Menu, MainMenuBar, Enable, &Help
}

TreeViewLoader(ParentProgram,ProjectChildren,SaveFile)
{
	Global
	P1 := TV_Add(ParentProgram)
	LastMainTaskLoop=1
	Loop, Parse, ProjectChildren, `|
	{
		P1C%A_Index% := TV_Add(A_LoopField,P1,"Bold")
		IniRead, TVLTaskList, %CurrentSaveFile%, %A_LoopField%, Tasks
		Loop, Parse, TVLTaskList, `|
		{
			P1C1C1 := TV_Add(A_LoopField,P1C%LastMainTaskLoop%)
		}
		LastMainTaskLoop+=1
		TV_Modify(P1C%A_Index%, "Expand")
	}
	TV_Modify(P1, "Expand")
}

TaskLoader(Selected,ParentName,TaskList,SaveFile)
{
	global
	Loop, Parse, TaskList, `|
	{
		if A_LoopField = %Selected%
		{
			IniRead, ProgressBarPercent, %SaveFile%, %ParentName%, ProgressTracker%A_Index%
			GuiControl,,ProgressBar, %ProgressBarPercent%
			IniRead, SelectedTaskDescription, %SaveFile%, %ParentName%, TaskDescription%A_Index%
			GuiControl,,MainDescriptionText, %SelectedTaskDescription%
			IniRead, SelectedTaskTitle, %SaveFile%, %ParentName%, Task%A_Index%
			;IniRead, SelectedProjectCreator, %CurrentSaveFile%, %TVItemName%, ProjectCreator //Placeholder for collaboration in the future
			IniRead, SelectedTaskDate, %SaveFile%, %ParentName%, Date
			IniRead, SelectedTaskLastChange, %SaveFile%, %ParentName%, LastChange
			GuiControl,,MainPropertiesText, Title: %SelectedTaskTitle%`nCreator: %CurrentUser%`nDate: %SelectedTaskDate%`nLast Change: %SelectedTaskLastChange%
		}
	}
	return
}