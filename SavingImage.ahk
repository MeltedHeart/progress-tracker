#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
MyNumber = 1
#Persistent
TrayTip, Progress Tracker, Copy an image address to save it to the current Task/Project
OnClipboardChange("ChangeItUp")
ChangeItUp()
{
	IfInString, Clipboard, .jpg
	{
		MsgBox 4, Save Picture,Would you like to saved picture to the current Task/Project?
		IfMsgBox, Yes
		{
			InputBox, imgname, Image Name, Choose a name for this image,,210, 125
			if ErrorLevel = 1
			{
				return
			}
			IniRead, CurrentMiscList, %A_MyDocuments%\ProgressTracker\ProgramData\%CurrentProgram%\Misc\%CurrentItem%.ptl, MiscInfo, MiscList
			IfInString, CurrentMiscList, imgname
			{
				MsgBox 16, ERROR, There is already an image with that name!
				return
			}
			If imgname = 
			{
				MsgBox 16, Warning, Item Name cannot be empty!
				return
			}
			FileRead, CurrentProgram, %A_Temp%\ProgressTracker\cprogram.tmp
			FileRead, CurrentItem, %A_Temp%\ProgressTracker\citem.tmp
			UrlDownloadToFile, %Clipboard%, %A_MyDocuments%\ProgressTracker\ProgramData\%CurrentProgram%\Misc\IMG\%CurrentItem%\IMG-%imgname%.jpg
			IniRead, CurrentMiscList, %A_MyDocuments%\ProgressTracker\ProgramData\%CurrentProgram%\Misc\%CurrentItem%.ptl, MiscInfo, MiscList
			if CurrentMiscList = ERROR
			{
				IniWrite, IMG:%imgname%.jpg, %A_MyDocuments%\ProgressTracker\ProgramData\%CurrentProgram%\Misc\%CurrentItem%.ptl, MiscInfo, MiscList
			}
			else
			{
				IniWrite, IMG:%imgname%.jpg|%CurrentMiscList%, %A_MyDocuments%\ProgressTracker\ProgramData\%CurrentProgram%\Misc\%CurrentItem%.ptl, MiscInfo, MiscList
			}
			TrayTip, Image %imgname%.jpg saved!
		}
	}
	; FileAppend, %ClipboardAll%, %A_MyDocuments%\ProgressTracker\bruh.jpg
	IfInString, Clipboard, .png
	{
		MsgBox 4, Save Picture,Would you like to saved picture to the current Task/Project?
		IfMsgBox, Yes
		{
			InputBox, imgname, Image Name, Choose a name for this image
			if ErrorLevel = 1
			{
				return
			}
			IniRead, CurrentMiscList, %A_MyDocuments%\ProgressTracker\ProgramData\%CurrentProgram%\Misc\%CurrentItem%.ptl, MiscInfo, MiscList
			IfInString, CurrentMiscList, imgname
			{
				MsgBox 16, ERROR, There is already an image with that name!
				return
			}
			If imgname = 
			{
				MsgBox 16, Warning, Item Name cannot be empty!
				return
			}
			FileRead, CurrentProgram, %A_Temp%\ProgressTracker\cprogram.tmp
			FileRead, CurrentItem, %A_Temp%\ProgressTracker\citem.tmp
			UrlDownloadToFile, %Clipboard%, %A_MyDocuments%\ProgressTracker\ProgramData\%CurrentProgram%\Misc\IMG\%CurrentItem%\IMG-%imgname%.jpg
			IniRead, CurrentMiscList, %A_MyDocuments%\ProgressTracker\ProgramData\%CurrentProgram%\Misc\%CurrentItem%.ptl, MiscInfo, MiscList
			if CurrentMiscList = ERROR
			{
				IniWrite, IMG:%imgname%.png, %A_MyDocuments%\ProgressTracker\ProgramData\%CurrentProgram%\Misc\%CurrentItem%.ptl, MiscInfo, MiscList
			}
			else
			{
				IniWrite, IMG:%imgname%.png|%CurrentMiscList%, %A_MyDocuments%\ProgressTracker\ProgramData\%CurrentProgram%\Misc\%CurrentItem%.ptl, MiscInfo, MiscList
			}
			TrayTip, Image %imgname%.png saved!
		}
	}
	
}
