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

TaskLoader(AllTasks,SaveFile)
{
	return
}

CreateTempFile(WhereToSave)
{
	FormatTime, Localtiem, ,ShortDate
	IniWrite,,WhereToSave,ProgramInfo,ProgramName
	IniWrite,,WhereToSave,ProgramInfo,Creator
	IniWrite,,WhereToSave,ProgramInfo,CreatorVersion
	IniWrite,,WhereToSave,ProgramInfo,CreatorDescription
	IniWrite,,WhereToSave,ProgramInfo,Projects
	IniWrite,,WhereToSave,ProgramName,ProjectTitle
	IniWrite,,WhereToSave,ProgramName,Creator
	IniWrite,Localtiem,WhereToSave,ProgramName,Date
	IniWrite,,WhereToSave,ProgramName,LastChange
	IniWrite,,WhereToSave,ProgramName,ProjectDescription
}