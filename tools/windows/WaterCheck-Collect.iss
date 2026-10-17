#define AppName "WaterCheck Collect"
#define AppVersion "0.1.0"
#define AppPublisher "WaterCheck"
#define AppExeName "watercheck_collect.exe"

#ifndef ReleaseDir
  #define ReleaseDir "..\..\apps\collect\build\windows\x64\runner\Release"
#endif

#ifndef VcRedist
  #define VcRedist ""
#endif

[Setup]
AppId={{A7A20AE9-7B7B-4E3A-8B8A-9B8B3D6A0C01}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\WaterCheck Collect
DefaultGroupName={#AppName}
OutputDir=..\..\dist\windows
OutputBaseFilename=WaterCheck-Collect-Setup
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
UninstallDisplayIcon={app}\{#AppExeName}

[Files]
Source: "{#ReleaseDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
#if VcRedist != ""
Source: "{#VcRedist}"; DestDir: "{tmp}"; Flags: deleteafterinstall
#endif

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"

[Run]
#if VcRedist != ""
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Microsoft Visual C++ runtime..."; Flags: waituntilterminated
#endif
Filename: "{app}\{#AppExeName}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent
