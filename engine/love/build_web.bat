call "C:\Program Files\7-Zip\7z.exe" a -r %1.zip -w ..\..\ -xr!engine/love -xr!builds -xr!.git -xr!*.moon
rename %1.zip %1.love
call love-js -c -m 1073741824 -t %1 %2\engine\love\%1.love ..\..\builds\web
del %1.love
