#include once "ThreadPool.bi"
#include once "win\ole2.bi"
#include once "AsyncTask.bi"

Function WorkerThread( _
		ByVal lpParam As LPVOID _
	)As DWORD
	
	Dim pTask As BrowseFolderTask Ptr = lpParam
	
	Select Case pTask->State
		
		Case TaskState.Starting
			If pTask->NeedWorking Then
				Dim pFormParam As MainFormParam Ptr = CoTaskMemAlloc(SizeOf(MainFormParam))
				
				If pFormParam Then
					pFormParam->hWin = pTask->hWin
					pFormParam->Action = FormNotify.TaskStarting
					pFormParam->pTask = pTask
					
					Const AsteriskString = __TEXT("*")
					lstrcat(@pTask->szText(0), @AsteriskString)
					
					pTask->hFind = FindFirstFile( _
						@pTask->szText(0), _
						@pTask->ffd _
					)
					If pTask->hFind = INVALID_HANDLE_VALUE Then
						pFormParam->Action = FormNotify.TaskStopped
						pTask->State = TaskState.Stopped
					Else
						lstrcpyW(@pFormParam->cFileName(0), pTask->ffd.cFileName)
						
						' Notifying the window that the process is starting
						QueueUserAPC( _
							pTask->pfnAPC, _
							pTask->MainThread, _
							Cast(ULONG_PTR, pFormParam) _
						)
						
						pTask->State = TaskState.Working
					End If
				Else
					pTask->State = TaskState.Stopped
				End If
			Else
				pTask->State = TaskState.Stopped
			End If
			
			QueueUserWorkItem( _
				@WorkerThread, _
				pTask, _
				WT_EXECUTEDEFAULT _
			)
			
		Case TaskState.Working
			If pTask->NeedWorking Then
				
				Dim pFormParam As MainFormParam Ptr = CoTaskMemAlloc(SizeOf(MainFormParam))
				
				If pFormParam Then
					pFormParam->hWin = pTask->hWin
					pFormParam->Action = FormNotify.TaskWorking
					pFormParam->pTask = pTask
					
					Sleep_(1000)
					
					Dim resFindNext As BOOL = FindNextFile( _
						pTask->hFind, _
						@pTask->ffd _
					)
					If resFindNext = 0 Then
						/'
						Dim dwError As DWORD = GetLastError()
						If dwError <> ERROR_NO_MORE_FILES Then
							' TOTO Handle error
						End If
						'/
						
						pFormParam->Action = FormNotify.TaskStopped
						pTask->State = TaskState.Stopped
					Else
						lstrcpyW(@pFormParam->cFileName(0), pTask->ffd.cFileName)
						
						' Notifying the window that the process is working
						QueueUserAPC( _
							pTask->pfnAPC, _
							pTask->MainThread, _
							Cast(ULONG_PTR, pFormParam) _
						)
					End If
				Else
					pTask->State = TaskState.Stopped
				End If
			Else
				pTask->State = TaskState.Stopped
			End If
			
			QueueUserWorkItem( _
				@WorkerThread, _
				pTask, _
				WT_EXECUTEDEFAULT _
			)
			
		Case TaskState.Stopped
			FindClose(pTask->hFind)
			
			Dim pFormParam As MainFormParam Ptr = CoTaskMemAlloc(SizeOf(MainFormParam))
			
			If pFormParam Then
				
				pFormParam->hWin = pTask->hWin
				pFormParam->Action = FormNotify.TaskStopped
				pFormParam->pTask = pTask
				
				' Notifying the window that the process is stopped
				QueueUserAPC( _
					pTask->pfnAPC, _
					pTask->MainThread, _
					Cast(ULONG_PTR, pFormParam) _
				)
			End If
			
	End Select
	
	Return 0
	
End Function
