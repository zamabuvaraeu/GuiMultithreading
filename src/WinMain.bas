#include once "WinMain.bi"
#include once "win\commctrl.bi"
#include once "win\shlobj.bi"
#include once "win\windowsx.bi"
#include once "ThreadPool.bi"
#include once "Resources.RH"

Const C_COLUMNS As UINT = 2

Type InputDialogParam
	hInst As HINSTANCE
	pIPool As IThreadPool Ptr
End Type

Type ResStringBuffer
	szText(255) As TCHAR
End Type

Type PathBuffer
	szText(MAX_PATH) As TCHAR
End Type

Sub ListViewCreateColumns( _
		ByVal hInst As HINSTANCE, _
		ByVal hList As HWND _
	)
	
	Dim rcList As RECT = Any
	GetClientRect(hList, @rcList)
	
	Dim ColumnWidth As Long = rcList.right \ C_COLUMNS
	
	Dim szText As ResStringBuffer = Any
	
	Dim Column As LVCOLUMN = Any
	With Column
		.mask = LVCF_FMT Or LVCF_WIDTH Or LVCF_TEXT Or LVCF_SUBITEM
		.fmt = LVCFMT_RIGHT
		.cx = ColumnWidth
		.pszText = @szText.szText(0)
	End With
	
	For i As UINT = 0 To C_COLUMNS - 1
		LoadString( _
			hInst, _
			IDS_TASK + i, _
			@szText.szText(0), _
			UBound(szText.szText) - LBound(szText.szText) _
		)
		Column.iSubItem = i
		ListView_InsertColumn(hList, i, @Column)
	Next
	
End Sub

Sub ListViewAppendRow( _
		ByVal hList As HWND, _
		ByVal ColumnText1 As LPTSTR, _
		ByVal ColumnText2 As LPTSTR _
	)
	
	Dim Item As LVITEM = Any
	With Item
		.mask = LVIF_TEXT
		.iItem  = 0
	End With
	
	Item.iSubItem = 0
	Item.pszText = ColumnText1
	ListView_InsertItem(hList, @Item)
	
	Item.iSubItem = 1
	Item.pszText = ColumnText2
	ListView_SetItem(hList, @Item)
	
End Sub

Sub ListViewTaskAppendRow( _
		ByVal hInst As HINSTANCE, _
		ByVal hList As HWND, _
		ByVal Column1 As TCHAR Ptr _
	)
	
	Dim szText As ResStringBuffer = Any
	
	LoadString( _
		hInst, _
		IDS_STOPPED, _
		@szText.szText(0), _
		UBound(szText.szText) - LBound(szText.szText) _
	)
	
	ListViewAppendRow( _
		hList, _
		Column1, _
		@szText.szText(0) _
	)
	
End Sub

Sub DialogMain_OnLoad( _
		ByVal this As InputDialogParam Ptr, _
		ByVal hWin As HWND _
	)
	
	Dim hListChars As HWND = GetDlgItem(hWin, IDC_LVW_TASKS)
	Const dwFlasg = LVS_EX_FULLROWSELECT Or LVS_EX_GRIDLINES
	ListView_SetExtendedListViewStyle(hListChars, dwFlasg)
	
	ListViewCreateColumns(this->hInst, hListChars)
	
End Sub

Sub ButtonAdd_OnClick( _
		ByVal this As InputDialogParam Ptr, _
		ByVal hWin As HWND _
	)
	
	Dim bi As BROWSEINFO = Any
	bi.hwndOwner = hWin
	bi.pidlRoot = NULL
	bi.pszDisplayName = NULL
	bi.lpszTitle = NULL
	bi.ulFlags = BIF_RETURNONLYFSDIRS
	bi.lpfn = NULL
	bi.lParam = NULL
	bi.iImage = 0
	
	Dim plst As PIDLIST_ABSOLUTE = SHBrowseForFolder(@bi)
	If plst Then
		Dim buf As PathBuffer = Any
		SHGetPathFromIDList(plst, @buf.szText(0))
		
		Dim hList As HWND = GetDlgItem(hWin, IDC_LVW_TASKS)
		ListViewTaskAppendRow( _
			this->hInst, _
			hList, _
			@buf.szText(0) _
		)
		
		CoTaskMemFree(plst)
	End If
	
End Sub

Sub IDCANCEL_OnClick( _
		ByVal this As InputDialogParam Ptr, _
		ByVal hWin As HWND _
	)
	
	PostQuitMessage(0)
	
End Sub

Sub ButtonClear_OnClick( _
		ByVal this As InputDialogParam Ptr, _
		ByVal hWin As HWND _
	)
	
	Dim hButton As HWND = GetDlgItem(hWin, IDC_BTN_CLEAR)
	Button_Enable(hButton, 0)
	
	Dim hList As HWND = GetDlgItem(hWin, IDC_LST_RESULT)
	ListBox_ResetContent(hList)
	
End Sub

Sub DialogMain_OnUnload( _
		ByVal this As InputDialogParam Ptr, _
		ByVal hWin As HWND _
	)
	
End Sub

Sub ListView_OnClick( _
		ByVal this As InputDialogParam Ptr, _
		ByVal hWin As HWND, _
		ByVal lpnmitem As NMITEMACTIVATE Ptr _
	)
	
End Sub

Function InputDataDialogProc( _
		ByVal hWin As HWND, _
		ByVal uMsg As UINT, _
		ByVal wParam As WPARAM, _
		ByVal lParam As LPARAM _
	)As INT_PTR
	
	Select Case uMsg
		
		Case WM_INITDIALOG
			Dim pParam As InputDialogParam Ptr = Cast(InputDialogParam Ptr, lParam)
			DialogMain_OnLoad(pParam, hWin)
			SetWindowLongPtr(hWin, GWLP_USERDATA, Cast(LONG_PTR, pParam))
			
		Case WM_COMMAND
			Dim pParam As InputDialogParam Ptr = Cast(InputDialogParam Ptr, GetWindowLongPtr(hWin, GWLP_USERDATA))
			
			Select Case LOWORD(wParam)
				
				Case IDC_BTN_ADD
					ButtonAdd_OnClick(pParam, hWin)
					
				Case IDC_BTN_CLEAR
					ButtonClear_OnClick(pParam, hWin)
					
				Case IDCANCEL
					IDCANCEL_OnClick(pParam, hWin)
					
			End Select
			
		Case WM_NOTIFY
			Dim pParam As InputDialogParam Ptr = Cast(InputDialogParam Ptr, GetWindowLongPtr(hWin, GWLP_USERDATA))
			Dim pHdr As NMHDR Ptr = Cast(NMHDR Ptr, lParam)
			
			Select Case pHdr->code
				
				Case NM_CLICK
					Dim lpnmitem As NMITEMACTIVATE Ptr = Cast(NMITEMACTIVATE Ptr, lParam)
					ListView_OnClick(pParam, hWin, lpnmitem)
					
			End Select
			
		Case WM_CLOSE
			Dim pParam As InputDialogParam Ptr = Cast(InputDialogParam Ptr, GetWindowLongPtr(hWin, GWLP_USERDATA))
			DialogMain_OnUnload(pParam, hWin)
			PostQuitMessage(0)
			
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
		Const EventVectorLength = 1
		Dim dwWaitResult As DWORD = MsgWaitForMultipleObjectsEx( _
			EventVectorLength, _
			@hEvent, _
			INFINITE, _
			QS_ALLEVENTS Or QS_ALLINPUT Or QS_ALLPOSTMESSAGE, _
			MWMO_ALERTABLE Or MWMO_INPUTAVAILABLE _
		)
		Select Case dwWaitResult
			
			Case WAIT_OBJECT_0
				' The event became a signal
				' exit from loop
				Return 0
				
			Case WAIT_OBJECT_0 + 1
				' Messages have been added to the message queue
				' they need to be processed
				
			Case WAIT_IO_COMPLETION
				' The asynchronous procedure has ended
				' we continue to wait
				
			Case Else ' WAIT_ABANDONED, WAIT_TIMEOUT, WAIT_FAILED
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
		' Need for function SHBrowseForFolder
		Dim hrComInit As HRESULT = CoInitialize(NULL)
		If FAILED(hrComInit) Then
			Return 1
		End If
	End Scope
	
	Dim param As InputDialogParam = Any
	param.hInst = hInst
	
	Scope
		Const dwMemContextReserved = 1
		Dim pIMalloc As IMalloc Ptr = Any
		Dim hrGetMalloc As HRESULT = CoGetMalloc( _
			dwMemContextReserved, _
			@pIMalloc _
		)
		If FAILED(hrGetMalloc) Then
			Return 1
		End If
		
		Dim hrCreateThreadPool As HRESULT = CreateThreadPool( _
			pIMalloc, _
			@IID_IThreadPool, _
			@param.pIPool _
		)
		IMalloc_Release(pIMalloc)
		
		If FAILED(hrCreateThreadPool) Then
			Return 1
		End If
		
		IThreadPool_SetMaxThreads(param.pIPool, 4)
		
		Dim hrRunPool As HRESULT = IThreadPool_Run(param.pIPool)
		If FAILED(hrRunPool) Then
			Return 1
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
		
		IThreadPool_Stop(param.pIPool)
		IThreadPool_Release(param.pIPool)
		
		Return resMessageLoop
	End Scope
	
End Function

Function EntryPoint()As Integer
	
	Dim hInst As HMODULE = GetModuleHandle(NULL)
	
	' The program does not process command line parameters
	Dim Arguments As LPTSTR = NULL
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
