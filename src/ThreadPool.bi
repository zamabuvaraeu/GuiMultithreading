#ifndef THREADPOOL_BI
#define THREADPOOL_BI

#include once "windows.bi"

Declare Function WorkerThread( _
	ByVal lpParam As LPVOID _
)As DWORD

#endif
