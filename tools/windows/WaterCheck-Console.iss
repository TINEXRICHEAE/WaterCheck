#define AppName "WaterCheck Console"
#define AppVersion "0.1.1"
#define AppPublisher "WaterCheck"
#define AppExeName "watercheck_console.exe"

#ifndef ReleaseDir
  #define ReleaseDir "..\..\apps\console\build\windows\x64\runner\Release"
#endif

#ifndef VcRedist
  #define VcRedist ""
#endif

[Setup]
AppId={{C5F4C8A3-3C1F-4B4B-98EF-47EE9B4E42A2}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\WaterCheck Console
DefaultGroupName={#AppName}
OutputDir=..\..\dist\windows
OutputBaseFilename=WaterCheck-Console-Setup
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
UninstallDisplayIcon={app}\{#AppExeName}

[Files]
Source: "{#ReleaseDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
#if VcRedist != ""
; Copied under a fixed name: the [Run] entry below starts this exact file
; (the downloaded redistributable has a long, versioned name).
Source: "{#VcRedist}"; DestDir: "{tmp}"; DestName: "vc_redist.x64.exe"; Flags: deleteafterinstall; Check: NeedsVcRedist
#endif

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"

[Run]
#if VcRedist != ""
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Microsoft Visual C++ runtime..."; Flags: waituntilterminated; Check: NeedsVcRedist
#endif
Filename: "{app}\{#AppExeName}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent

[Code]
// The x64 Visual C++ 2015-2022 runtime registers itself here; skip the
// bundled installer when it is already present.
function NeedsVcRedist: Boolean;
var
  Installed: Cardinal;
begin
  Result := not (RegQueryDWordValue(HKLM64,
    'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64',
    'Installed', Installed) and (Installed = 1));
end;
