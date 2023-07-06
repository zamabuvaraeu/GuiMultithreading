#include once "WinMain.bi"
#include once "win\commctrl.bi"
#include once "win\windowsx.bi"
#include once "Resources.RH"

Const COMMONCONTROLS_ERRORSTRING = __TEXT("Failed to register Common Controls")
Const DIALOGBOXPARAM_ERRORSTRING = __TEXT("Failed to DialogBoxParam")

Const C_COLUMNS As UINT = 2
Const MAX_TEXT_LENGTH As Integer = 128000 - 1

Type InputDialogParam
	hInst As HINSTANCE
End Type

#ifdef UNICODE
Declare Sub LongIntToString Alias "LongIntToStringW"( _
	ByVal buf As LPWSTR, _
	ByVal li As LongInt _
)
#else
Declare Sub LongIntToString Alias "LongIntToStringA"( _
	ByVal buf As LPSTR, _
	ByVal li As LongInt _
)
#endif

Type IntegerToStringBuffer
	szText(31) As TCHAR
End Type

Type CharacterStringBuffer
	szText(1) As TCHAR
End Type

Type ResStringBuffer
	szText(255) As TCHAR
End Type

Type EditStringBuffer
	szText(MAX_TEXT_LENGTH - 1) As TCHAR
End Type

Type CharacterCounter
	Code As Integer
	Count As Integer
End Type


Sub OnCreate(ByVal hWin As HWND, ByVal pParam As InputDialogParam Ptr)
	
End Sub

Sub IDOK_OnClick(ByVal hWin As HWND)
	

End Sub

Sub IDCANCEL_OnClick(ByVal hWin As HWND)
	PostQuitMessage(0)
End Sub

Sub OnClose(ByVal hWin As HWND)
	PostQuitMessage(0)
End Sub

Function InputDataDialogProc( _
		ByVal hWin As HWND, _
		ByVal uMsg As UINT, _
		ByVal wParam As WPARAM, _
		ByVal lParam As LPARAM _
	)As INT_PTR
	
	Select Case uMsg
		
		Case WM_INITDIALOG
			' Dim pParam As InputDialogParam Ptr = Cast(InputDialogParam Ptr, LPARAM)
			OnCreate(hWin, NULL)
			
		Case WM_COMMAND
			Select Case LOWORD(wParam)
				
				Case IDOK
					IDOK_OnClick(hWin)
					
				Case IDCANCEL
					IDCANCEL_OnClick(hWin)
					
			End Select
			
		Case WM_CLOSE
			OnClose(hWin)
			
		Case Else
			Return FALSE
			
	End Select
	
	Return TRUE
	
End Function

Function EnableVisualStyles()As Integer
	
	Dim icc As INITCOMMONCONTROLSEX = Any
	icc.dwSize = SizeOf(INITCOMMONCONTROLSEX)
	icc.dwICC = ICC_ANIMATE_CLASS Or _
		ICC_BAR_CLASSES Or _
		ICC_COOL_CLASSES Or _
		ICC_DATE_CLASSES Or _
		ICC_HOTKEY_CLASS Or _
		ICC_INTERNET_CLASSES Or _
		ICC_LINK_CLASS Or _
		ICC_LISTVIEW_CLASSES Or _
		ICC_NATIVEFNTCTL_CLASS Or _
		ICC_PAGESCROLLER_CLASS Or _
		ICC_PROGRESS_CLASS Or _
		ICC_STANDARD_CLASSES Or _
		ICC_TAB_CLASSES Or _
		ICC_TREEVIEW_CLASSES Or _
		ICC_UPDOWN_CLASS Or _
		ICC_USEREX_CLASSES Or _
	ICC_WIN95_CLASSES
	
	Dim res As BOOL = InitCommonControlsEx(@icc)
	If res = 0 Then
		Return 1
	End If
	
	Return 0
	
End Function

Function CreateMainWindow( _
		Byval hInst As HINSTANCE, _
		ByVal param As InputDialogParam Ptr _
	)As HWND
	
	Dim hWin As HWND = CreateDialogParam( _
		hInst, _
		MAKEINTRESOURCE(IDD_DLG_TASKS), _
		NULL, _
		@InputDataDialogProc, _
		Cast(LPARAM, param) _
	)
	
	Return hWin
	
End Function

Function MessageLoop( _
		ByVal hWin As HWND, _
		ByVal hEvent As HANDLE _
	)As Integer
	
	Do
		
		Dim dwWaitResult As DWORD = MsgWaitForMultipleObjectsEx( _
			1, _
			@hEvent, _
			INFINITE, _
			QS_ALLEVENTS Or QS_ALLINPUT Or QS_ALLPOSTMESSAGE, _
			MWMO_ALERTABLE Or MWMO_INPUTAVAILABLE _
		)
		Select Case dwWaitResult
			
			Case WAIT_OBJECT_0
				' Событие стало сигнальным
				Return 0
				
			Case WAIT_OBJECT_0 + 1
				' Сообщения добавлены в очередь сообщений
				
			Case WAIT_IO_COMPLETION
				' Завершилась асинхронная процедура
				' продолжаем ждать
				
			Case Else ' WAIT_ABANDONED WAIT_TIMEOUT WAIT_FAILED
				Return 1
				
		End Select
		
		Do
			Dim wMsg As MSG = Any
			Dim resGetMessage As BOOL = PeekMessage( _
				@wMsg, _
				NULL, _
				0, _
				0, _
				PM_REMOVE _
			)
			If resGetMessage =  0 Then
				Exit Do
			End If
			
			If wMsg.message = WM_QUIT Then
				Return wMsg.wParam
			Else
				Dim resDialogMessage As BOOL = IsDialogMessage( _
					hWin, _
					@wMsg _
				)
				If resDialogMessage = 0 Then
					TranslateMessage(@wMsg)
					DispatchMessage(@wMsg)
				End If
			End If
		Loop
	Loop
	
	Return 0
	
End Function

Function tWinMain( _
		Byval hInst As HINSTANCE, _
		ByVal hPrevInstance As HINSTANCE, _
		ByVal lpCmdLine As LPTSTR, _
		ByVal iCmdShow As Long _
	)As Integer
	
	Scope
		Dim resVisualStyles As Integer = EnableVisualStyles()
		If resVisualStyles Then
			Return resVisualStyles
		End If
	End Scope
	
	Scope
		Dim hEvent As HANDLE = CreateEvent( _
			NULL, _
			TRUE, _
			FALSE, _
			NULL _
		)
		If hEvent = NULL Then
			Return 1
		End If
		
		Dim param As InputDialogParam = Any
		param.hInst = hInst
		Dim hWin As HWND = CreateMainWindow( _
			hInst, _
			@param _
		)
		If hWin = NULL Then
			CloseHandle(hEvent)
			Return 1
		End If
		
		Dim resMessageLoop As Integer = MessageLoop( _
			hWin, _
			hEvent _
		)
		
		DestroyWindow(hWin)
		CloseHandle(hEvent)
		
		Return resMessageLoop
	End Scope
	
End Function

Function EntryPoint()As Integer
	
	Dim hInst As HMODULE = GetModuleHandle(NULL)
	Dim Arguments As LPTSTR = NULL ' GetCommandLine()
	Dim RetCode As Integer = tWinMain( _
		hInst, _
		NULL, _
		Arguments, _
		SW_SHOW _
	)
	
	#ifdef WITHOUT_RUNTIME
		ExitProcess(RetCode)
	#endif
	
	Return RetCode
	
End Function

#ifndef WITHOUT_RUNTIME
Dim RetCode As Long = CLng(EntryPoint())
End(RetCode)
#endif
