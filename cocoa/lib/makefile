.PHONY: setup
setup:
	rm -rf Qt*.dylib*
	rm -rf Qt*.framework*
	rm -rf libqsqlite.dylib*
	cp -r ~/Qt/5.11.2/clang_64/lib/QtCore.framework .
	cp -r ~/Qt/5.11.2/clang_64/lib/QtCore.framework.dSYM .
	cp -r ~/Qt/5.11.2/clang_64/lib/QtSql.framework .
	cp -r ~/Qt/5.11.2/clang_64/lib/QtSql.framework.dSYM .
	cp -r ~/Qt/5.11.2/clang_64/plugins/sqldrivers/libqsqlite.dylib .
	cp -r ~/Qt/5.11.2/clang_64/plugins/sqldrivers/libqsqlite.dylib.dSYM .
	make QtCore.framework
	make QtSql.framework
	make libqsqlite.dylib
	make docviewer.framework

.PHONY: codesign
codesign:
	codesign -v -s $(CODESIGN_APP_STORE) QtCore.framework/QtCore
	codesign -v -s $(CODESIGN_APP_STORE) QtSql.framework/QtSql
	codesign -v -s $(CODESIGN_APP_STORE) docviewer.framework/docviewer
	codesign -v -s $(CODESIGN_APP_STORE) libqsqlite.dylib

.PHONY: docviewer.framework
docviewer.framework:
	rm -rf docviewer.framework
	cp -r ../../qt/release-build/docviewer.framework .
	cd docviewer.framework && rm -rf `echo [^V]*` Versions/Current 

	mv ./docviewer.framework/Versions/1 ./docviewer.framework/Versions/A
	ln -sF Versions/Current/Headers ./docviewer.framework/Headers
	ln -sF Versions/Current/Resources ./docviewer.framework/Resources
	ln -sF Versions/Current/docviewer ./docviewer.framework/docviewer
	ln -sF A ./docviewer.framework/Versions/Current

	install_name_tool -id @rpath/docviewer.framework/Versions/A/docviewer ./docviewer.framework/docviewer
	install_name_tool -change /usr/local/lib/libgq.dylib @executable_path/../Frameworks/libgq.dylib ./docviewer.framework/docviewer
	install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/A/QtCore ./docviewer.framework/docviewer
	install_name_tool -change @rpath/QtSql.framework/Versions/5/QtSql @executable_path/../Frameworks/QtSql.framework/Versions/A/QtSql ./docviewer.framework/docviewer
	
	otool -L ./docviewer.framework/docviewer
	ls -l ./docviewer.framework
	ls -l ./docviewer.framework/Versions

	cp Info.plist ./docviewer.framework/Resources/Info.plist

.PHONY: QtCore.framework
QtCore.framework:
	echo If rm fails the framework is already signed.
	cd QtCore.framework && rm -rf `echo [^V]*` Versions/Current

	mv ./QtCore.framework/Versions/5 ./QtCore.framework/Versions/A
	ln -sF Versions/Current/Headers ./QtCore.framework/Headers
	ln -sF Versions/Current/Resources ./QtCore.framework/Resources
	ln -sF Versions/Current/QtCore ./QtCore.framework/QtCore
	ln -sF A ./QtCore.framework/Versions/Current

	install_name_tool -id @rpath/QtCore.framework/Versions/A/QtCore ./QtCore.framework/QtCore
	install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/A/QtCore ./QtCore.framework/QtCore
	
	otool -L ./QtCore.framework/QtCore
	ls -l ./QtCore.framework
	ls -l ./QtCore.framework/Versions

.PHONY: libqsqlite.dylib
libqsqlite.dylib:
	install_name_tool -id @rpath/libqsqlite.dylib ./libqsqlite.dylib
	install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/A/QtCore ./libqsqlite.dylib
	install_name_tool -change @rpath/QtSql.framework/Versions/5/QtSql @executable_path/../Frameworks/QtSql.framework/Versions/A/QtSql ./libqsqlite.dylib	

	otool -L libqsqlite.dylib


.PHONY: QtSql.framework
QtSql.framework:
	echo If rm fails the framework is already signed.
	cd QtSql.framework && rm -rf `echo [^V]*` Versions/Current

	mv ./QtSql.framework/Versions/5 ./QtSql.framework/Versions/A
	ln -sF Versions/Current/Headers ./QtSql.framework/Headers
	ln -sF Versions/Current/Resources ./QtSql.framework/Resources
	ln -sF Versions/Current/QtSql ./QtSql.framework/QtSql
	ln -sF A ./QtSql.framework/Versions/Current

	install_name_tool -id @rpath/QtSql.framework/Versions/A/QtSql ./QtSql.framework/QtSql
	install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore @executable_path/../Frameworks/QtCore.framework/Versions/A/QtCore ./QtSql.framework/QtSql

	otool -L ./QtSql.framework/QtSql
	ls -l ./QtSql.framework
	ls -l ./QtSql.framework/Versions


