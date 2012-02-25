unit installerUniversal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, installerCore, m_crossinstaller;


type
  { TUniversalInstaller }

  TUniversalInstaller = class(TInstaller)
  private
    BinPath:string;
    FConfigFile:string;
    FFPCDir:string;
    FLazarusDir:string;
    InitDone:boolean;
  protected
    // internal initialisation, called from BuildModule,CLeanModule,GetModule
    // and UnInstallModule but executed only once
    function InitModule:boolean;
  public
    // Configuration file in ini format containing module definitions
    property ConfigFile:string read FConfigFile write FConfigFile;
    // FPC base directory
    property FPCDir:string read FFPCDir write FFPCDir;
    // Lazarus base directory
    property LazarusDir:string read FLazarusDir write FLazarusDir;
    // Build module
    function BuildModule(ModuleName:string): boolean; override;
    // Clean up environment
    function CleanModule(ModuleName:string): boolean; override;
    // Gets the list of modules enabled in ConfigFile
    function GetDefaultModuleList(var ModuleList:TStringList):boolean;
    // Install update sources
    function GetModule(ModuleName:string): boolean; override;
    // Gets the list of modules from ConfigFile
    function GetModuleList(var ModuleList:TStringList):boolean;
    // Gets the list of required modules for ModuleName
    function GetModuleRequirements(ModuleName:string; var RequirementList:TStringList): boolean;
    // Uninstall module
    function UnInstallModule(ModuleName:string): boolean; override;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TUniversalInstaller }

function TUniversalInstaller.InitModule: boolean;
begin
  result:=true;
  if InitDone then
    exit;
  if FVerbose then
    ProcessEx.OnOutputM:=@DumpOutput;
  result:=CheckAndGetNeededExecutables;
  BinPath:=IncludeTrailingPathDelimiter(FFPCDir)+'bin'+DirectorySeparator+GetFPCTarget(true);
  InitDone:=result;
end;

function TUniversalInstaller.BuildModule(ModuleName: string): boolean;
begin
  if not InitModule then exit;

end;

function TUniversalInstaller.CleanModule(ModuleName: string): boolean;
begin
  if not InitModule then exit;

end;

function TUniversalInstaller.GetDefaultModuleList(var ModuleList: TStringList
  ): boolean;
begin
  if not InitModule then exit;

end;

function TUniversalInstaller.GetModule(ModuleName: string): boolean;
begin
  if not InitModule then exit;

end;

function TUniversalInstaller.GetModuleList(var ModuleList: TStringList): boolean;
begin
  if not InitModule then exit;

end;

function TUniversalInstaller.GetModuleRequirements(ModuleName: string;
  var RequirementList: TStringList): boolean;
begin
  if not InitModule then exit;

end;

function TUniversalInstaller.UnInstallModule(ModuleName: string): boolean;
begin
  if not InitModule then exit;

end;

constructor TUniversalInstaller.Create;
begin
  inherited Create;
end;

destructor TUniversalInstaller.Destroy;
begin
  inherited Destroy;
end;

end.
