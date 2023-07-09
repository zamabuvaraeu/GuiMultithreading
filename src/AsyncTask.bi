#ifndef ASYNCTASK_BI
#define ASYNCTASK_BI

#include once "windows.bi"

Enum TaskState
	Starting
	Working
	Stopped
End Enum

Enum FormNotify
	TaskStarting
	TaskWorking
	TaskStopped
End Enum

Type BrowseFolderTask
	szText(MAX_PATH) As TCHAR
	State As TaskState
	hWin As HWND
	MainThread As HANDLE
	hFind As HANDLE
	pfnAPC As PAPCFUNC
	ffd As WIN32_FIND_DATA
	NeedWorking As Boolean
End Type

Type MainFormParam
	hWin As HWND
	Action As FormNotify
	pTask As BrowseFolderTask Ptr
	cFileName(MAX_PATH) As TCHAR
End Type

#endif
