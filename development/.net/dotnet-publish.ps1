dotnet publish -r win-x64 --self-contained -p:PublishSingleFile=true -c Release -o ./publish/win
dotnet publish -r linux-x64 --self-contained -p:PublishSingleFile=true -c Release -o ./publish/linux
dotnet publish -r osx-x64 --self-contained -p:PublishSingleFile=true -c Release -o ./publish/osx