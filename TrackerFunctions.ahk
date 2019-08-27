; /// Tracker Library ///

BoiBox()
{
	MsgBox, BOI
}

DisableAllGui()
{
	WinGet, ActiveControlList, ControlList, A
	;MsgBox, %ActiveControlList%
	;StringSplit, ActiveControls, ActiveControlList, `n
	;MsgBox, %ActiveControls1%
	;MsgBox, %ActiveControls2%
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

TreeViewLoader(ParentProgram,ProjectChildren)
{
	P1 := TV_Add(ParentProgram)
	Loop, Parse, ProjectChildren, `|
	{
		;TreeViewParent=P1
		;TreeViewChildren=C%A_Index%
		P1C1 := TV_Add(A_LoopField,P1)
	}
	TV_Modify(P1, "Expand")
}

