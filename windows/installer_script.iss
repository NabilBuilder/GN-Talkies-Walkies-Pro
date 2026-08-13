[Setup]
AppName=Gardnet Talkie Walkie Pro
AppVersion=1.0.0
DefaultDirName={autopf}\Gardnet Talkie Walkie Pro
DefaultGroupName=Gardnet Talkie Walkie Pro
OutputBaseFilename=Setup_Gardnet_TalkieWalkie_Pro
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x64
WizardStyle=modern
OutputDir=installer_output
DisableProgramGroupPage=yes
PrivilegesRequired=admin

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{autoprograms}\Gardnet Talkie Walkie Pro"; Filename: "{app}\gestion_materiel.exe"
Name: "{autodesktop}\Gardnet Talkie Walkie Pro"; Filename: "{app}\gestion_materiel.exe"

[Run]
Filename: "{app}\gestion_materiel.exe"; Description: "Lancer l'application"; Flags: nowait postinstall skipifsilent
