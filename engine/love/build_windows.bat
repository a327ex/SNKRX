call "C:\Program Files\7-Zip\7z.exe" a -r %1.zip -w ..\..\ -xr!engine/love -xr!builds -xr!steam -xr!.git -xr!*.moon -xr!conf.lua
rename %1.zip %1.love
copy /b "love.exe"+"%1.love" "%1.exe"
del %1.love
mkdir %1
for %%I in (*.dll) do copy %%I %1\
for %%I in (*.txt) do copy %%I %1\
copy %1.exe %1\
del %1.exe
call "C:\Program Files\7-Zip\7z.exe" a %1.zip %1\
del /q %1\
rmdir /q %1\
copy %1.zip ..\..\builds\windows\
del %1.zip
