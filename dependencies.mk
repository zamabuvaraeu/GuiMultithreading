$(OBJ_DEBUG_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj: src$(PATH_SEP)Resources.RH src$(PATH_SEP)app.exe.manifest
$(OBJ_RELEASE_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj: src$(PATH_SEP)Resources.RH src$(PATH_SEP)app.exe.manifest
$(OBJ_DEBUG_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).c: src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)AsyncTask.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)ThreadPool$(FILE_SUFFIX).c: src$(PATH_SEP)ThreadPool.bi src$(PATH_SEP)AsyncTask.bi
$(OBJ_DEBUG_DIR)$(PATH_SEP)WinMain$(FILE_SUFFIX).c: src$(PATH_SEP)WinMain.bi src$(PATH_SEP)AsyncTask.bi src$(PATH_SEP)Resources.RH src$(PATH_SEP)ThreadPool.bi
$(OBJ_RELEASE_DIR)$(PATH_SEP)WinMain$(FILE_SUFFIX).c: src$(PATH_SEP)WinMain.bi src$(PATH_SEP)AsyncTask.bi src$(PATH_SEP)Resources.RH src$(PATH_SEP)ThreadPool.bi
