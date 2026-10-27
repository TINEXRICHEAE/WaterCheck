#define AppName "FieldQuire Collect"
#define AppVersion "0.1.1"
#define AppPublisher "FieldQuire"
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
DefaultDirName={autopf}\FieldQuire Collect
DefaultGroupName={#AppName}
OutputDir=..\..\dist\windows
OutputBaseFilename=FieldQuire-Collect-Setup
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
