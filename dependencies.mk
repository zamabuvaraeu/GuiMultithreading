$(OBJ_DEBUG_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj: src$(PATH_SEP)Resources.RH src$(PATH_SEP)app.exe.manifest
$(OBJ_RELEASE_DIR)$(PATH_SEP)Resources$(FILE_SUFFIX).obj: src$(PATH_SEP)Resources.RH src$(PATH_SEP)app.exe.manifest
$(OBJ_DEBUG_DIR)$(PATH_SEP)WinMain$(FILE_SUFFIX).c: src$(PATH_SEP)WinMain.bi src$(PATH_SEP)Resources.RH
$(OBJ_RELEASE_DIR)$(PATH_SEP)WinMain$(FILE_SUFFIX).c: src$(PATH_SEP)WinMain.bi src$(PATH_SEP)Resources.RH
