{ Classes for using svn commands
  Copyright (C) 2012 Reinier Olislagers

  Based on svncommand unit
  Copyright (C) 2007 Vincent Snijders vincents@freepascal.org,

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}
unit svnclient;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  process,
  FileUtil {Requires LCL};

type
  ESVNClientError = class(Exception);
  { TSVNClient }

  TSVNClient = class(TObject)
  private
    FLocalRepository: string;
    FRepositoryURL: string;
    FReturnCode: integer;
    FRevision: string;
    FSVNExecutable: string;
    function GetSVNExecutable: string;
    procedure SetRevision(AValue: string);
    procedure SetSVNExecutable(AValue: string);
  public
    procedure CheckOut;
    //Performs an SVN checkout (initial download), HEAD (latest revision) only for speed
    procedure CheckOutOrUpdate;
    //Pulls SVN checkout if local repository doesn't exist, else does an update
    function FindSVNExecutable: string;
    //Search for installed SVN executable (might return just a filename if in the OS path)
    procedure Log(var Log: TStringList); //Shows commit log for local directory
    procedure Revert;
    //Reverts/removes local changes so we get a clean copy again. Note: will remove modifications to files!
    procedure Update; //Performs an SVN update (pull)
    function ExecuteSvnCommand(const Command: string; Output: TStream): integer;
    //Executes a free form SVN command; returns SVN client exit code
    function ExecuteSVNCommand(const Command: string; var Output: TStringList): integer;
    //Executes a free form SVN command; returns SVN client exit code
    function ExecuteSvnCommand(const Command: string): integer;
    //Executes a free form SVN command; returns SVN client exit code
    function LocalRepositoryExists: boolean;
    property LocalRepository: string read FLocalRepository write FLocalRepository;
    //Local directory that has an SVN repository/checkout
    function LocalRevision: integer; //Revision number of local repository
    property Repository: string read FRepositoryURL write FRepositoryURL;
    property Revision: string read FRevision write SetRevision;
    property ReturnCode: integer read FReturnCode;
    //Exit code returned by last SVN client command. Useful for troubleshooting
    property SVNExecutable: string read GetSVNExecutable write SetSVNExecutable;
    constructor Create;
    destructor Destroy; override;
  end;


implementation


{ TSVNClient }
function TSVNClient.FindSvnExecutable: string;
const
  SVNName = 'svn';
var
  ExeResult: longint;
begin
  Result := FSVNExecutable;
  if FileExists(FSvnExecutable) then
  begin
    exit;
  end;

  if FSVNExecutable = '' then
  begin
    //todo: check what happens if svn exe is in path but not specified here?
    // process call will still work!!?! Maybe run it once with -v or something and just set FSVNExecutable to svn.exe
    try
      {$IFDEF MSWINDOWS}
      ExeResult := SysUtils.ExecuteProcess(SVNName, '--version', []);
      {$ENDIF MSWINDOWS}
      {$IFDEF UNIX}
      ExeResult := SysUtils.ExecuteProcess(SVNName, '--version');
      {$ENDIF UNIX}
      if ExeResult = 0 then
      begin
        //Found a working SVN in path
        FSVNExecutable := SVNName;
        exit;
      end;
    except
      //Apparently SVN exe not found in path or some other error.
    end;
  end;

{$IFDEF MSWINDOWS}
  // Some popular locations for SlikSVN and Subversion
  if not FileExists(FSvnExecutable) then
    FSvnExecutable := GetEnvironmentVariable('ProgramFiles') + '\Subversion\bin\svn.exe';
  if not FileExists(FSvnExecutable) then
    FSvnExecutable := GetEnvironmentVariable('ProgramFiles(x86)') +
      '\Subversion\bin\svn.exe';
  if not FileExists(FSvnExecutable) then
    FSvnExecutable := GetEnvironmentVariable('ProgramFiles') + '\SlikSvn\bin\svn.exe';
  if not FileExists(FSvnExecutable) then
    FSvnExecutable := GetEnvironmentVariable('ProgramFiles(x86)') +
      '\SlikSvn\bin\svn.exe';
{$ENDIF MSWINDOWS}

  if not FileExists(FSvnExecutable) then
    FSvnExecutable := FindDefaultExecutablePath('svn');

{$IFDEF MSWINDOWS}
  if not FileExists(FSvnExecutable) then
    FSvnExecutable := (ExtractFilePath(ParamStr(0)) + 'svn'); //directory where current executable is
{$ENDIF MSWINDOWS}

  if not FileExists(FSvnExecutable) then
  begin
    //current path.
    //todo: check if this is safe (e.g. compromised svn etc)
    if FileExists('svn.exe') then
      FSVNExecutable := 'svn.exe';
    if FileExists('svn') then
      FSVNExecutable := 'svn';
  end;

  if not FileExists(FSVNExecutable) then
    FSVNExecutable := ''; //Make sure we don't call an arbitrary executable
  Result := FSVNExecutable;
end;

function TSVNClient.GetSVNExecutable: string;
begin
  Result := FSVNExecutable;
end;

procedure TSVNClient.SetRevision(AValue: string);
begin
  if FRevision=AValue then Exit;
  FRevision:=AValue;
end;

procedure Tsvnclient.Checkout;
const
  MaxRetries = 3;
var
  Command: string;
  RetryAttempt: integer;
begin
  if FRevision='' then
    Command := 'checkout --non-interactive --revision HEAD ' + Repository + ' ' + LocalRepository
  else
    Command := 'checkout --non-interactive -r '+ FRevision+ ' ' + Repository + ' ' + LocalRepository;
  ExecuteSVNCommand(Command);
  // If command fails, e.g. due to misconfigured firewalls blocking ICMP etc, retry a few times
  RetryAttempt := 1;
  while (ReturnCode <> 0) and (RetryAttempt < MaxRetries) do
  begin
    Sleep(500); //Give everybody a chance to relax ;)
    ExecuteSVNCommand(Command); //attempt again
    RetryAttempt := RetryAttempt + 1;
  end;
  FRevision:=''; //don't reuse
end;

procedure Tsvnclient.CheckOutOrUpdate;

begin
  //todo: for this and update, indicate whether there actually were any updates.
  //maybe with an oldrevision and newrevision property? something else? the svn log?
  if LocalRepositoryExists = False then
  begin
    // Checkout (first download)
    //writeln('debug: doing checkout of ' + Repository + ' to ' + LocalRepository + '.');
    Checkout;
  end
  else
  begin
    // Update
    //writeln('debug: doing update of ' + Repository + ' to ' + LocalRepository + '.');
    Update;
  end;
end;

procedure Tsvnclient.Log(var Log: TStringList);
begin
  ExecuteSVNCommand('log ' + LocalRepository, Log);
end;

procedure Tsvnclient.Revert;
begin
  ExecuteSVNCommand('revert --recursive ' + LocalRepository);
end;

procedure TSVNClient.SetSVNExecutable(AValue: string);
begin
  if FSVNExecutable <> AValue then
  begin
    FSVNExecutable := AValue;
    FindSVNExecutable; //Make sure it actually exists
  end;
end;

procedure Tsvnclient.Update;
const
  MaxRetries = 3;
var
  Command: string;
  RetryAttempt: integer;
  StartRevision: integer;
begin
  StartRevision := LocalRevision;
  if FRevision='' then
    Command := 'update --non-interactive ' + LocalRepository
  else
    Command := 'update --non-interactive -r ' + FRevision + ' ' + LocalRepository;
  ExecuteSVNCommand(Command);
  // If command fails, e.g. due to misconfigured firewalls blocking ICMP etc, retry a few times
  RetryAttempt := 1;
  while (ReturnCode <> 0) and (RetryAttempt < MaxRetries) do
  begin
    Sleep(500); //Give everybody a chance to relax ;)
    ExecuteSVNCommand(Command); //attempt again
    RetryAttempt := RetryAttempt + 1;
  end;
  FRevision:=''; //don't reuse
end;

function TSVNClient.ExecuteSvnCommand(const Command: string; Output: TStream): integer;
var
  SvnProcess: TProcess;

  function ReadOutput: boolean;
    // returns true if output was actually read
  const
    BufSize = 4096;
  var
    Buffer: array[0..BufSize - 1] of byte;
    ReadBytes: integer;
  begin
    Result := False;
    while SvnProcess.Output.NumBytesAvailable > 0 do
    begin
      ReadBytes := SvnProcess.Output.Read(Buffer, BufSize);
      Output.Write(Buffer, ReadBytes);
      Result := True;
    end;
  end;

begin
  FReturnCode := 255; //Preset to failure
  // Look for SVN if necessary; error if needed:
  if not FileExists(FSVNExecutable) then FindSvnExecutable;
  if not FileExists(FSvnExecutable) then
    raise ESVNClientError.Create('No SVN executable found');

  SvnProcess := TProcess.Create(nil);
  try
    SvnProcess.CommandLine := SvnExecutable + ' ' + Command;
    SvnProcess.Options := [poUsePipes, poStderrToOutPut];
    SvnProcess.ShowWindow := swoHIDE;
    SvnProcess.Execute;
    while SvnProcess.Running do
    begin
      if not ReadOutput then
        Sleep(100);
    end;
    ReadOutput;
    FReturnCode := SvnProcess.ExitStatus;
    Result := FReturnCode;
  finally
    SvnProcess.Free;
  end;
end;

function TSVNClient.ExecuteSVNCommand(const Command: string;
  var Output: TStringList): integer;
var
  OutputStream: TMemoryStream;
begin
  OutputStream := TMemoryStream.Create;
  try
    Result := ExecuteSvnCommand(Command, OutputStream);
    OutputStream.Position := 0;
    Output.LoadFromStream(OutputStream); //load output
  finally
    OutputStream.Free;
  end;
end;

function TSVNClient.ExecuteSvnCommand(const Command: string): integer;
var
  OutputStream: TMemoryStream;
begin
  OutputStream := TMemoryStream.Create;
  try
    Result := ExecuteSvnCommand(Command, OutputStream);
  finally
    OutputStream.Free;
  end;
end;

function Tsvnclient.LocalRepositoryExists: boolean;
var
  Output: TStringList;
begin
  Output := TStringList.Create;
  try
    Result := False;
    if (ExecuteSVNCommand('info ' + FLocalRepository, Output) = 0) then
      Result := False;
    if Pos('Path', Output.Text) > 0 then
      Result := True;
    //This is already covered by setting stuff to false first
    //if Pos('is not a working copy', Output.Text) > 0 then result:=false;
  finally
    Output.Free;
  end;
end;

function TSVNClient.LocalRevision: integer;
const
  RevLength = Length('Revision: ');
var
  Output: TStringList;
  LRevision: string;
begin
  Output := TStringList.Create;
  try
    if (ExecuteSVNCommand('info ' + FLocalRepository, Output) = 0) then
      Result := -1;
    // Could have used svnversion but that would have meant calling yet another command...
    // Get the part after "Revision: "
    LRevision := Output.Text;
    Result := StrToIntDef(trim(copy(Revision, pos('Revision: ', Revision) + 9, 6)), -1);
  finally
    Output.Free;
  end;
end;


constructor Tsvnclient.Create;
begin
  FLocalRepository := '';
  FRepositoryURL := '';
  FRevision:='';
  FReturnCode := 0;
  FSVNExecutable := '';
  FindSvnExecutable; //Do this so the SVNExecutable property is valid.
end;

destructor Tsvnclient.Destroy;
begin
  inherited Destroy;
end;
end.
