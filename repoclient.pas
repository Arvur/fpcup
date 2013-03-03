unit repoclient;
{ Generic repository client class. Implementations for hg, svn,... are availalbe
  Copyright (C) 2012-2013 Reinier Olislagers, Ludo Brands

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

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  // Custom return codes
  FRET_LOCAL_REMOTE_URL_NOMATCH=-1; //Return code that indicates remote and local repository URLs don't match
  FRET_WORKING_COPY_TOO_OLD=-2; //Return code for SVN problem with old client version used
  FRET_UNKNOWN_REVISION='FRET_UNKNOWN_REVISION';

type

  { TRepoClient }

  TRepoClient = class(TObject)
  protected
    FDesiredRevision: string;
    FLocalRepository: string;
    FLocalRevision: string;
    FRepoExecutable: string;
    FRepositoryURL: string;
    FReturnCode: integer;
    FVerbose: boolean;
    function GetLocalRevision: string; virtual;
    function GetRepoExecutable: string; virtual;
    // Makes sure non-empty strings have a / at the end.
    function IncludeTrailingSlash(AValue: string): string; virtual;
    procedure SetDesiredRevision(AValue: string); virtual;
    procedure SetLocalRepository(AValue: string); virtual;
    procedure SetRepositoryURL(AValue: string); virtual;
    procedure SetRepoExecutable(AValue: string); virtual;
    procedure SetVerbose(AValue: boolean); virtual;
  public
    //Performs a checkout/initial download
    //Note: it's often easier to call CheckOutOrUpdate
    procedure CheckOut; virtual;
    //Runs checkout if local repository doesn't exist, else does an update
    procedure CheckOutOrUpdate; virtual;
    //Search for installed version control client executable (might return just a filename if in the OS path)
    function FindRepoExecutable: string; virtual;
    //Creates diff of all changes in the local directory versus the remote version
    function GetDiffAll:string; virtual;
    //Shows commit log for local directory
    procedure Log(var Log: TStringList); virtual;
    //Reverts/removes local changes so we get a clean copy again. Note: will remove modifications to files!
    procedure Revert; virtual;
    //Performs an update (pull)
    //Note: it's often easier to call CheckOutOrUpdate; that also has some more network error recovery built in
    procedure Update; virtual;
    //Get/set desired revision to checkout/pull to (if none given, use HEAD/tip/newest)
    property DesiredRevision: string read FDesiredRevision write SetDesiredRevision;
    //Shows list of files that have been modified locally (and not committed)
    procedure LocalModifications(var FileList: TStringList); virtual;
    //Checks to see if local directory is a valid repository for the repository URL given (if any)
    function LocalRepositoryExists: boolean; virtual;
    //Local directory that has a repository/checkout.
    //When setting, relative paths will be expanded; trailing path delimiters will be removed
    property LocalRepository: string read FLocalRepository write SetLocalRepository;
    //Revision number of local repository: branch revision number if we're in a branch.
    property LocalRevision: string read GetLocalRevision;
    //URL where central (remote) repository is placed
    property Repository: string read FRepositoryURL write SetRepositoryURL;
    //Exit code returned by last client command; 0 for success. Useful for troubleshooting
    property ReturnCode: integer read FReturnCode;
    //Version control client executable. Can be set to explicitly determine which executable to use.
    property RepoExecutable: string read GetRepoExecutable write SetRepoExecutable;
    //Show additional console/log output?
    property Verbose:boolean read FVerbose write SetVerbose;
    destructor Destroy; override;
  end;


implementation

{ TRepoClient }

function TRepoClient.GetLocalRevision: string;
begin
  // Inherited classes, please implement
  FLocalRevision:=FRET_UNKNOWN_REVISION;
  raise Exception.Create('TRepoClient descendants must implement this themselves.');
end;

function TRepoClient.GetRepoExecutable: string;
begin
  { Inherited classes, please implement getting the client executable
  for your version control system, e.g. svn.exe, git, hg, bzr... or nothing}
  raise Exception.Create('TRepoClient descendants must implement this themselves.');
  result:='';
end;

function TRepoClient.IncludeTrailingSlash(AValue: string): string;
begin
  // Default: either empty string or / already there
  result:=AValue;
  if (AValue<>'') and (RightStr(AValue,1)<>'/') then
  begin
    result:=AValue+'/';
  end;
end;

procedure TRepoClient.SetDesiredRevision(AValue: string);
begin
  if FDesiredRevision=AValue then Exit;
  FDesiredRevision:=AValue;
end;

procedure TRepoClient.SetLocalRepository(AValue: string);
// Sets local repository, converting relative path to absolute path
// and adding a trailing / or \
begin
  if FLocalRepository=AValue then Exit;
  FLocalRepository:=ExcludeTrailingPathDelimiter(ExpandFileName(AValue));
end;

procedure TRepoClient.SetRepositoryURL(AValue: string);
// Make sure there's a trailing / in the URL.
// This normalization helps matching remote and local URLs
begin
  if FRepositoryURL=AValue then Exit;
  FRepositoryURL:=IncludeTrailingSlash(AValue);
end;

procedure TRepoClient.SetRepoExecutable(AValue: string);
begin
  if FRepoExecutable <> AValue then
  begin
    FRepoExecutable := AValue;
    FindRepoExecutable; //Make sure it actually exists; use fallbacks if possible
  end;
end;

procedure TRepoClient.SetVerbose(AValue: boolean);
begin
  if FVerbose=AValue then Exit;
  FVerbose:=AValue;
end;

procedure TRepoClient.CheckOut;
begin
  raise Exception.Create('TRepoClient descendants must implement this themselves.');
end;

procedure TRepoClient.CheckOutOrUpdate;
begin
  raise Exception.Create('TRepoClient descendants must implement this themselves.');
end;

function TRepoClient.GetDiffAll: string;
begin
  raise Exception.Create('TRepoClient descendants must implement this themselves.');
end;

function TRepoClient.FindRepoExecutable: string;
begin
  raise Exception.Create('TRepoClient descendants must implement this themselves.');
end;

procedure TRepoClient.Log(var Log: TStringList);
begin
  raise Exception.Create('TRepoClient descendants must implement this themselves.');
end;

procedure TRepoClient.Revert;
begin
  raise Exception.Create('TRepoClient descendants must implement this themselves.');
end;

procedure TRepoClient.Update;
begin
  raise Exception.Create('TRepoClient descendants must implement this themselves.');
end;

procedure TRepoClient.LocalModifications(var FileList: TStringList);
begin
  raise Exception.Create('TRepoClient descendants must implement this themselves.');
end;

function TRepoClient.LocalRepositoryExists: boolean;
begin
  raise Exception.Create('TRepoClient descendants must implement this themselves.');
end;

destructor TRepoClient.Destroy;
begin
  inherited Destroy;
end;

end.

