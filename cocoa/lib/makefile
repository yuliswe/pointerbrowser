.PHONY: docviewer.framework
docviewer.framework:
	mv ./docviewer.framework/Versions/1 ./docviewer.framework/Versions/A
	ln -sF Versions/A/Headers ./docviewer.framework/Headers
	ln -sF Versions/A/Resources ./docviewer.framework/Resources
	ln -sF Versions/Current/docviewer ./docviewer.framework/docviewer
	ln -sF A ./docviewer.framework/Versions/Current

	install_name_tool -id @rpath/docviewer.framework/Versions/A/docviewer ./docviewer.framework/docviewer
	install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/A/QtCore ./docviewer.framework/docviewer
	install_name_tool -change @rpath/QtSql.framework/Versions/5/QtSql @rpath/QtSql.framework/Versions/A/QtSql ./docviewer.framework/docviewer
	
	otool -L ./docviewer.framework/docviewer
	ls -l ./docviewer.framework
	ls -l ./docviewer.framework/Versions

	cp Info.plist ./docviewer.framework/Resources/Info.plist

.PHONY: QtCore.framework
QtCore.framework:
	echo If rm fails the framework is already signed.
	rm ./QtCore.framework/QtCore_debug
	rm ./QtCore.framework/Versions/5/QtCore_debug
	rm ./QtCore.framework/.prl

	mv ./QtCore.framework/Versions/5 ./QtCore.framework/Versions/A
	ln -sF Versions/A/Headers ./QtCore.framework/Headers
	ln -sF Versions/A/Resources ./QtCore.framework/Resources
	ln -sF Versions/Current/QtCore ./QtCore.framework/QtCore
	ln -sF A ./QtCore.framework/Versions/Current

	install_name_tool -id @rpath/QtCore.framework/Versions/A/QtCore ./QtCore.framework/QtCore
	install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/A/QtCore ./QtCore.framework/QtCore
	
	otool -L ./QtCore.framework/QtCore
	ls -l ./QtCore.framework
	ls -l ./QtCore.framework/Versions

.PHONY: QtGui.framework
QtGui.framework:
	echo If rm fails the framework is already signed.
	rm ./QtGui.framework/QtGui_debug
	rm ./QtGui.framework/Versions/5/QtGui_debug
	rm ./QtGui.framework/.prl

	mv ./QtGui.framework/Versions/5 ./QtGui.framework/Versions/A
	ln -sF Versions/A/Headers ./QtGui.framework/Headers
	ln -sF Versions/A/Resources ./QtGui.framework/Resources
	ln -sF Versions/Current/QtGui ./QtGui.framework/QtGui
	ln -sF A ./QtGui.framework/Versions/Current

	install_name_tool -id @rpath/QtGui.framework/Versions/A/QtGui ./QtGui.framework/QtGui
	install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/A/QtCore ./QtGui.framework/QtGui
	
	otool -L ./QtGui.framework/QtGui
	ls -l ./QtGui.framework
	ls -l ./QtGui.framework/Versions


.PHONY: libqsqlite.dylib
libqsqlite.dylib:
	install_name_tool -id @rpath/libqsqlite.dylib ./libqsqlite.dylib
	install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/A/QtCore ./libqsqlite.dylib
	install_name_tool -change @rpath/QtSql.framework/Versions/5/QtSql @rpath/QtSql.framework/Versions/A/QtSql ./libqsqlite.dylib	

	otool -L libqsqlite.dylib


.PHONY: QtSql.framework
QtSql.framework:
	echo If rm fails the framework is already signed.
	rm ./QtSql.framework/QtSql_debug
	rm ./QtSql.framework/Versions/5/QtSql_debug
	rm ./QtSql.framework/.prl

	mv ./QtSql.framework/Versions/5 ./QtSql.framework/Versions/A
	ln -sF Versions/A/Headers ./QtSql.framework/Headers
	ln -sF Versions/A/Resources ./QtSql.framework/Resources
	ln -sF Versions/Current/QtSql ./QtSql.framework/QtSql
	ln -sF A ./QtSql.framework/Versions/Current

	install_name_tool -id @rpath/QtSql.framework/Versions/A/QtSql ./QtSql.framework/QtSql
	install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/A/QtCore ./QtSql.framework/QtSql

	otool -L ./QtSql.framework/QtSql
	ls -l ./QtSql.framework
	ls -l ./QtSql.framework/Versions


