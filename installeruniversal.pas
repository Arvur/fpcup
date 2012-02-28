unit installerUniversal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, installerCore, m_crossinstaller,processutils,process;


type
  { TUniversalInstaller }

  TUniversalInstaller = class(TInstaller)
  private
    BinPath:string;
    FFPCDir:string;
    FLazarusDir:string;
    FLazarusPrimaryConfigPath:string;
    InitDone:boolean;
  protected
    function GetValue(Key:string;sl:TStringList):string;
    // internal initialisation, called from BuildModule,CLeanModule,GetModule
    // and UnInstallModule but executed only once
    function InitModule:boolean;
    function RunCommands(directive:string;sl:TStringList):boolean;
  public
    // FPC base directory
    property FPCDir:string read FFPCDir write FFPCDir;
    // Lazarus primary config path
    property LazarusPrimaryConfigPath:string read FLazarusPrimaryConfigPath write FLazarusPrimaryConfigPath;
    // Lazarus base directory
    property LazarusDir:string read FLazarusDir write FLazarusDir;
    // Build module
    function BuildModule(ModuleName:string): boolean; override;
    // Clean up environment
    function CleanModule(ModuleName:string): boolean; override;
    function ConfigModule(ModuleName:string): boolean; override;
    // Install update sources
    function GetModule(ModuleName:string): boolean; override;
    // Gets the list of required modules for ModuleName
    function GetModuleRequirements(ModuleName:string; var RequirementList:TStringList): boolean;
    // Uninstall module
    function UnInstallModule(ModuleName:string): boolean; override;
    constructor Create;
    destructor Destroy; override;
  end;

  // Gets the list of modules enabled in ConfigFile. Appends to existing TStringList
  function GetModuleEnabledList(var ModuleList:TStringList):boolean;
  // Gets the sequence representation for all modules
  function GetModuleList(ConfigFile:string):string;


var sequences:string;

implementation

uses inifiles,updatelazconfig,svnclient,fileutil;

Const
  STARTUSERMODULES=1000;
  MAXUSERMODULES=100;
  MAXINSTRUCTIONS=20;

var
  IniGeneralSection:TStringList=nil;
  UniModuleList:TStringList=nil;
  UniModuleEnabledList:TStringlist=nil;

{ TUniversalInstaller }

function TUniversalInstaller.GetValue(Key: string;sl:TStringList): string;
var
  i,len:integer;
  s,macro:string;
begin
  Key:=UpperCase(Key);
  s:='';
  for i:=0 to sl.Count-1 do
    begin
    s:=sl[i];
    if (copy(UpperCase(s),1, length(Key))=Key) and ((s[length(Key)+1]='=') or (s[length(Key)+1]=' ')) then
      begin
      if pos('=',s)>0 then
        s:=trim(copy(s,pos('=',s)+1,length(s)));
      break;
      end;
    s:='';
    end;
  if s='' then //search general section
    for i:=0 to IniGeneralSection.Count-1 do
      begin
      s:=IniGeneralSection[i];
      if (copy(UpperCase(s),1, length(Key))=Key) and ((s[length(Key)+1]='=') or (s[length(Key)+1]=' ')) then
        begin
        if pos('=',s)>0 then
          s:=trim(copy(s,pos('=',s)+1,length(s)));
        break;
        end;
      s:='';
      end;
//expand macros
  if s<>'' then
    while pos('$(',s)>0 do
      begin
      i:=pos('$(',s);
      macro:=copy(s,i+2,length(s));
      if pos(')',macro)>0 then
        begin
        delete(macro,pos(')',macro),length(macro));
        macro:=UpperCase(macro);
        len:=length(macro)+3; // the brackets
        if macro='FPCDIR' then macro:=FFPCDir
        else if macro='LAZARUSDIR' then macro:=FLazarusDir
        else if macro='LAZARUSPRIMARYCONFIGPATH' then macro:=FLazarusPrimaryConfigPath
        else macro:=GetValue(macro,sl); //user defined value
        // quote if containing spaces
        if pos(' ',macro)>0 then
          macro:=''''+macro+'''';
        delete(s,i,len);
        insert(macro,s,i);
        end;
      end;
  // correct path delimiter
  if (pos('URL',Key)<=0) and (pos('ADDTO',Key)<>1)then
    begin
    for i:=1 to length(s) do
      if (s[i]='/') or (s[i]='\') then
        s[i]:=DirectorySeparator;
    end;
  result:=s;
end;

function TUniversalInstaller.InitModule: boolean;
begin
  result:=true;
  if InitDone then
    exit;
  if FVerbose then
    ProcessEx.OnOutputM:=@DumpOutput;
//  result:=CheckAndGetNeededExecutables;
  BinPath:=IncludeTrailingPathDelimiter(FFPCDir)+'bin'+DirectorySeparator+GetFPCTarget(true);
  InitDone:=result;
end;

function TUniversalInstaller.RunCommands(directive: string;sl:TStringList): boolean;
var
  i,j:integer;
  exec,output:string;
  Workingdir:string;
  PE:TProcessEx;
begin
  PE:=TProcessEx.Create(nil);
  try
    PE.CurrentDirectory:=GetValue('Workingdir',sl);
    for i:=1 to MAXINSTRUCTIONS do
      begin
      exec:=GetValue(directive+IntToStr(i),sl);
      if exec='' then break;
      //split off command and parameters
      j:=1;
      while j<=length(exec) do
        begin
        if exec[j]='"' then
          repeat  //skip until next quote
            j:=j+1;
          until (exec[j]='"') or (j=length(exec));
        j:=j+1;
        if exec[j]=' ' then break;
        end;
      PE.Executable:=trim(copy(exec,1,j));
      PE.ParametersString:=trim(copy(exec,j,length(exec)));
      PE.ShowWindow := swoHIDE;
      if FVerbose then
        PE.OnOutput:=@DumpConsole;
      PE.Execute;
      Output:=PE.OutputString;
      result:=PE.ExitStatus=0;
      if not result then
        break;
      end;
  finally
    PE.Free;
  end;
end;

function TUniversalInstaller.BuildModule(ModuleName: string): boolean;
var
  idx:integer;
  sl:TStringList;
begin
  result:=InitModule;
  if not result then exit;
  idx:=UniModuleList.IndexOf(UpperCase(ModuleName));
  if idx>=0 then
    begin
    sl:=TStringList(UniModuleList.Objects[idx]);
    WritelnLog('Building module '+ModuleName);
    result:=RunCommands('InstallExecute',sl);
    end
  else
    result:=false;
end;

function TUniversalInstaller.CleanModule(ModuleName: string): boolean;
begin
  result:=InitModule;
  if not result then exit;
  result:=true;
end;

function TUniversalInstaller.ConfigModule(ModuleName: string): boolean;
var
  idx:integer;
  sl:TStringList;
  ULC:TUpdateLazConfig;

  function AddToLazXML(xmlfile:string):boolean;
  var
    i,j,k:integer;
    exec,key,counter,oldcounter,filename:string;
    count:integer;
  begin
  filename:=xmlfile+'.xml';
  oldcounter:='';
  for i:=1 to MAXINSTRUCTIONS do
    begin
    exec:=GetValue('AddTo'+xmlfile+IntToStr(i),sl);
    if exec='' then break;
    //split off key and value
    j:=1;
    while j<=length(exec) do
      begin
      j:=j+1;
      if exec[j]=':' then break;
      end;
    key:=trim(copy(exec,1,j-1));
    k:=pos('@',key);
    if k<=0 then
      ULC.SetVariable(filename,key,trim(copy(exec,j+1,length(exec))))
    else //we got a counter
      begin
      counter:= trim(copy(key,k+1,length(key)));
      key:=trim(copy(key,1,k-1));
      if oldcounter<>counter then //read write counter only once
        begin
        count:=ULC.GetVariable(filename,counter,0)+1;
        ULC.SetVariable(filename,counter,count);
        oldcounter:=counter;
        end;
      k:=pos('#',key);
      while k>0 do
        begin //replace # with count
        delete(key,k,1);
        insert(inttostr(count),key,k);
        k:=pos('#',key);
        end;
      ULC.SetVariable(filename,key,trim(copy(exec,j+1,length(exec))));
      end;
    if not result then
      break;
    end;
  end;

begin
  result:=InitModule;
  if not result then exit;
  idx:=UniModuleList.IndexOf(UpperCase(ModuleName));
  if idx>=0 then
    begin
    ULC:=TUpdateLazConfig.Create(FLazarusPrimaryConfigPath);
    sl:=TStringList(UniModuleList.Objects[idx]);
    AddToLazXML('environmentoptions');
    AddToLazXML('helpoptions');
    AddToLazXML('packagefiles');
    ULC.Destroy;
    end
  else
    result:=false;
end;

function TUniversalInstaller.GetModule(ModuleName: string): boolean;
var
  idx:integer;
  sl:TStringList;
  SVN,InstallDir:string;
  BeforeRevision, AfterRevision: string;
  UpdateWarnings: TStringList;
begin
  result:=InitModule;
  if not result then exit;
  result:=true;
  idx:=UniModuleList.IndexOf(UpperCase(ModuleName));
  if idx>=0 then
    begin
    sl:=TStringList(UniModuleList.Objects[idx]);
    WritelnLog('Getting module '+ModuleName);
    InstallDir:=GetValue('InstallDir',sl);
    if InstallDir<>'' then
      ForceDirectoriesUTF8(InstallDir);
    SVN:=GetValue('SVNURL',sl);
    if SVN<>'' then
      begin
      UpdateWarnings:=TStringList.Create;
      try
        FSVNClient:=TSVNClient.Create;
        FSVNClient.Verbose:=FVerbose;
        FBaseDirectory:=InstallDir;
        FUrl:=SVN;
        result:=DownloadFromSVN(ModuleName,BeforeRevision,AfterRevision,UpdateWarnings);
        if UpdateWarnings.Count>0 then
        begin
          WritelnLog(UpdateWarnings.Text);
        end;
        FSVNClient.Free;
      finally
        UpdateWarnings.Free;
      end;
      end;
    end
  else
    result:=false;
end;

function TUniversalInstaller.GetModuleRequirements(ModuleName: string;
  var RequirementList: TStringList): boolean;
begin
  if not InitModule then exit;

end;

function TUniversalInstaller.UnInstallModule(ModuleName: string): boolean;
var
  idx:integer;
  sl:TStringList;
begin
  result:=InitModule;
  if not result then exit;
  idx:=UniModuleList.IndexOf(UpperCase(ModuleName));
  if idx>=0 then
    begin
    sl:=TStringList(UniModuleList.Objects[idx]);
    WritelnLog('UnInstalling module '+ModuleName);
    result:=RunCommands('UnInstallExecute',sl);
    end
  else
    result:=false;
end;

constructor TUniversalInstaller.Create;
begin
  inherited Create;
end;

destructor TUniversalInstaller.Destroy;
begin
  inherited Destroy;
end;


procedure ClearUniModuleList;
var
  i:integer;
begin
  for i:=0 to UniModuleList.Count -1 do
    TStringList(UniModuleList.Objects[i]).free;
end;

procedure ReadInifile(ConfigFile: string);
var
  ini:TMemIniFile;
  i,j:integer;
  val,name:string;

  function LoadModule(ModuleName:string):boolean;
  var
    name,val:string;
    i:integer;
    sl:TStringList;
  begin
    name:=ini.ReadString(ModuleName,'Name','');
    result:=name<>'';
    if result then
      begin
      if ini.ReadString(ModuleName,'Enabled','')='1' then
        UniModuleEnabledList.Add(uppercase(name));
      // store the section as is and attach as object to UniModuleList
      // TstringList cleared in finalization
      sl:=TstringList.Create;
      ini.ReadSectionRaw(ModuleName,sl);
      UniModuleList.AddObject(name,TObject(sl));
      end;
  end;

begin
  ini:=TMemIniFile.Create(ConfigFile);
  ini.CaseSensitive:=false;
// parse inifile
  try
    ini.ReadSectionRaw('General',IniGeneralSection);
    for i:=1 to STARTUSERMODULES do
      if not LoadModule('Module'+IntToStr(i)) then break; //require contiguous numbering
    for i:=STARTUSERMODULES to STARTUSERMODULES+MAXUSERMODULES do
      LoadModule('Module'+IntToStr(i));   // don't require contiguous
    // the overrides
    for i:=0 to UniModuleList.Count-1 do
      begin
      name:=UniModuleList[i];
      val:=ini.ReadString('General',name,'');
      if val='1' then
        begin //enable if not yet done
        if UniModuleEnabledList.IndexOf(name)<0 then
          UniModuleEnabledList.Add(name);
        end
      else if val='0' then
        begin //disable if enabled
        j:=UniModuleEnabledList.IndexOf(name);
        if j>=0 then
          UniModuleEnabledList.Delete(j);
        end;
      end;
  finally
    ini.Free;
  end;
end;

function GetModuleEnabledList(var ModuleList: TStringList): boolean;
var i:integer;
begin
  for i:=0 to UniModuleEnabledList.Count -1 do
    ModuleList.Add(UniModuleEnabledList[i]);
end;

function GetModuleList(ConfigFile: string): string;
var
  i:integer;
  s:string;
begin
  ReadInifile(ConfigFile);
  result:='';
  for i:=0 to UniModuleList.Count -1 do
    begin
    s:=UniModuleList[i];
    result:=result+'Declare '+ s + ';' +
        'Cleanmodule '+ s +';' +
        'Getmodule '+ s +';' +
        'Buildmodule '+ s +';' +
        'Configmodule '+ s +';' +
        'End;';
    end;
end;

initialization
 IniGeneralSection:=TStringList.create;
 UniModuleList:=TStringList.create;
 UniModuleEnabledList:=TStringList.create;
finalization
ClearUniModuleList;
UniModuleList.free;
UniModuleEnabledList.free;
IniGeneralSection.Free;
end.

