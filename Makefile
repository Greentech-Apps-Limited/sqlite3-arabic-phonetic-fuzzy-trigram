prepare-dist:
	rm -rf dist
	mkdir dist
	rm -rf generate
	mkdir generate

copy-file:
	cp src/* generate

download-sqlite:
	curl -L https://www.sqlite.org/2022/sqlite-amalgamation-3390400.zip --output sqlite3.zip # change sql version if need
	unzip sqlite3.zip
	mv sqlite-amalgamation-3390400/* generate  # change sql version if need
	rm -rf sqlite-amalgamation-3390400  # change sql version if need
	rm -rf sqlite3.zip

compile-linux:
	gcc -fPIC -shared generate/sqlite3-arabic-phonetic-fuzzy-trigram.c -o dist/sqlite3-arabic-phonetic-fuzzy-trigram.so

pack-linux:
	zip -j dist/sqlite3-arabic-phonetic-fuzzy-trigram-linux-x86.zip dist/*.so

compile-windows:
	gcc -shared -I. generate/sqlite3-arabic-phonetic-fuzzy-trigram.c -o dist/sqlite3-arabic-phonetic-fuzzy-trigram.dll

pack-windows:
	7z a -tzip dist/sqlite3-arabic-phonetic-fuzzy-trigram-win-x64.zip ./dist/*.dll

compile-macos-x86:
	mkdir -p dist/x86
	gcc -fPIC -dynamiclib -I generate generate/sqlite3-arabic-phonetic-fuzzy-trigram.c -o dist/x86/sqlite3-arabic-phonetic-fuzzy-trigram.dylib -target x86_64-apple-macos10.12

compile-macos-arm64:
	mkdir -p dist/arm64
	gcc -fPIC -dynamiclib -I generate generate/sqlite3-arabic-phonetic-fuzzy-trigram.c -o dist/arm64/sqlite3-arabic-phonetic-fuzzy-trigram.dylib -target arm64-apple-macos11

compile-macos-universal: compile-macos-x86 compile-macos-arm64
	lipo -create -output dist/sqlite3-arabic-phonetic-fuzzy-trigram.dylib dist/x86/sqlite3-arabic-phonetic-fuzzy-trigram.dylib dist/arm64/sqlite3-arabic-phonetic-fuzzy-trigram.dylib

pack-macos:
	zip -j dist/sqlite3-arabic-phonetic-fuzzy-trigram-macos-universal.zip dist/*.dylib
	zip -j dist/sqlite3-arabic-phonetic-fuzzy-trigram-macos-x86.zip dist/x86/*.dylib
	zip -j dist/sqlite3-arabic-phonetic-fuzzy-trigram-macos-arm64.zip dist/arm64/*.dylib

end-dist:
	rm -rf generate