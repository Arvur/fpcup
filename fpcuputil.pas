{ Utility unit for FPCUp
Copyright (C) 2012 Reinier Olislagers, Ludo Brands

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

unit fpcuputil;
{ Utility functions that might be needed by fpcup core and plugin units }

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils;

// Create shortcut on desktop to Target file
procedure CreateDesktopShortCut(Target, TargetArguments, ShortcutName: string) ;
// Create shell script in ~ directory that links to Target
procedure CreateHomeStartLink(Target, TargetArguments, ShortcutName: string);
// Delete directory and children, even read-only. Equivalent to rm -rf <directory>
function DeleteDirectoryEx(DirectoryName: string): boolean;
// Download from HTTP (includes Sourceforge redirection support) or FTP
function Download(URL, TargetFile: string): boolean;
{$IFDEF MSWINDOWS}
// Get path for Windows per user storage of application data. Useful for storing settings
function GetLocalAppDataPath: string;
{$ENDIF MSWINDOWS}
procedure infoln(Message: string);
//Uses writeln for now, and waits a bit afterwards so output is hopefully not garbled
function MoveFile(const SrcFilename, DestFilename: string): boolean;
// Moves file if it exists, overwriting destination file
{$IFDEF UNIX}
function XdgConfigHome: String;
{$ENDIF UNIX}
// Emulates/runs which to find executable in path. If not found, returns empty string
function Which(Executable: string): string;


implementation
uses
  httpsend {for downloading from http},
  ftpsend {for downloading from ftp},
  FileUtil, strutils
  {$IFDEF MSWINDOWS}
    //Mostly for shortcut code
    ,windows, shlobj {for special folders}, ActiveX, ComObj
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  ,baseunix,processutils
  {$ENDIF UNIX}
  ;

{$IFDEF MSWINDOWS}
procedure CreateDesktopShortCut(Target, TargetArguments, ShortcutName: string);
var
  IObject: IUnknown;
  ISLink: IShellLink;
  IPFile: IPersistFile;
  PIDL: PItemIDList;
  InFolder: array[0..MAX_PATH] of Char;
  LinkName: WideString;
begin
  { Creates an instance of IShellLink }
  IObject := CreateComObject(CLSID_ShellLink);
  ISLink := IObject as IShellLink;
  IPFile := IObject as IPersistFile;

  ISLink.SetPath(pChar(Target));
  ISLink.SetArguments(pChar(TargetArguments));
  ISLink.SetWorkingDirectory(pChar(ExtractFilePath(Target)));

  { Get the desktop location }
  SHGetSpecialFolderLocation(0, CSIDL_DESKTOPDIRECTORY, PIDL);
  SHGetPathFromIDList(PIDL, InFolder);
  LinkName := InFolder + PathDelim + ShortcutName+'.lnk';

  { Get rid of any existing shortcut first }
  SysUtils.DeleteFile(LinkName);

  { Create the link }
  IPFile.Save(PWChar(LinkName), false);
end;
{$ENDIF MSWINDOWS}

{$IFDEF UNIX}
procedure CreateDesktopShortCut(Target, TargetArguments, ShortcutName: string);
begin
  infoln('todo: implement createdesktopshortcut for '+Target+' with '+TargetArguments+' as '+Shortcutname);
end;
{$ENDIF UNIX}

procedure CreateHomeStartLink(Target, TargetArguments,
  ShortcutName: string);
var
  ScriptText: TStringList;
  ScriptFile: string;
begin
  {$IFDEF MSWINDOWS}
  infoln('todo: write me (CreateHomeStartLink)!');
  {$ENDIF MSWINDOWS}
  {$IFDEF UNIX}
  //create dir if it doesn't exist
  ForceDirectoriesUTF8(ExtractFilePath(IncludeTrailingPathDelimiter(ExpandFileNameUTF8('~'))+ShortcutName));
  ScriptText:=TStringList.Create;
  try
    // No quotes here, either, we're not in a shell, apparently...
    ScriptFile:=IncludeTrailingPathDelimiter(ExpandFileNameUTF8('~'))+ShortcutName;
    SysUtils.DeleteFile(ScriptFile); //Get rid of any existing remnants
    ScriptText.Add('#!/bin/sh');
    ScriptText.Add('# shortcut to Lazarus trunk, generated by fcpup');
    ScriptText.Add(Target+' '+TargetArguments);
    ScriptText.SaveToFile(ScriptFile);
    FPChmod(ScriptFile, &700); //rwx------
  finally
    ScriptText.Free;
  end;
  {$ENDIF UNIX}
end;

function DownloadFTP(URL, TargetFile: string): boolean;
const
  FTPPort=21;
  FTPScheme='ftp://'; //URI scheme name for FTP URLs
var
  Host: string;
  Port: integer;
  Source: string;
  FoundPos: integer;
begin
  if LeftStr(URL, length(FTPScheme))=FTPScheme then URL:=Copy(URL, length(FTPScheme)+1, length(URL));
  FoundPos:=pos('/', URL);
  Host:=LeftStr(URL, FoundPos-1);
  Source:=Copy(URL, FoundPos+1, Length(URL));
  //Check for port numbers:
  FoundPos:=pos(':', Host);
  Port:=FTPPort;
  if FoundPos>0 then
  begin
    Host:=LeftStr(Host, FoundPos-1);
    Port:=StrToIntDef(Copy(Host, FoundPos+1, Length(Host)),21);
  end;
  Result:=FtpGetFile(Host, IntToStr(Port), Source, TargetFile, 'anonymous', 'fpc@example.com');
  if result=false then infoln('DownloadFTP: error downloading '+URL+'. Details: host: '+Host+'; port: '+Inttostr(Port)+'; remote path: '+Source+' to '+TargetFile);
end;

function DownloadHTTPStream(URL: string; Buffer: TStream): boolean;
  // Download file; retry if necessary.
const
  MaxRetries = 3;
var
  RetryAttempt: integer;
  HTTPGetResult: boolean;
begin
  Result:=false;
  RetryAttempt := 1;
  HTTPGetResult := False;
  while ((HTTPGetResult = False) and (RetryAttempt < MaxRetries)) do
  begin
    HTTPGetResult := HttpGetBinary(URL, Buffer);
    //Application.ProcessMessages;
    Sleep(100 * RetryAttempt);
    RetryAttempt := RetryAttempt + 1;
  end;
  if HTTPGetResult = False then
    raise Exception.Create('Cannot load document from remote server');
  Buffer.Position := 0;
  if Buffer.Size = 0 then
    raise Exception.Create('Downloaded document is empty.');
  Result := True;
end;

function SFDirectLinkURL(URL: string; Document: TMemoryStream): string;
{
Transform this part of the body:
<noscript>
<meta http-equiv="refresh" content="5; url=http://downloads.sourceforge.net/project/base64decoder/base64decoder/version%202.0/b64util.zip?r=&amp;ts=1329648745&amp;use_mirror=kent">
</noscript>
into a valid URL:
http://downloads.sourceforge.net/project/base64decoder/base64decoder/version%202.0/b64util.zip?r=&amp;ts=1329648745&amp;use_mirror=kent
}
const
  Refresh='<meta http-equiv="refresh"';
  URLMarker='url=';
var
  Counter: integer;
  HTMLBody: TStringList;
  RefreshStart: integer;
  URLStart: integer;
begin
  HTMLBody:=TStringList.Create;
  try
    HTMLBody.LoadFromStream(Document);
    for Counter:=0 to HTMLBody.Count-1 do
    begin
      // This line should be between noscript tags and give the direct download locations:
      RefreshStart:=Ansipos(Refresh, HTMLBody[Counter]);
      if RefreshStart>0 then
      begin
        URLStart:=AnsiPos(URLMarker, HTMLBody[Counter])+Length(URLMarker);
        if URLStart>RefreshStart then
        begin
          // Look for closing "
          URL:=Copy(HTMLBody[Counter],
            URLStart,
            PosEx('"',HTMLBody[Counter],URLStart+1)-URLStart);
          infoln(URL);
          break;
        end;
      end;
    end;
  finally
    HTMLBody.Free;
  end;
  result:=URL;
end;

function SourceForgeURL(URL: string): string;
// Detects sourceforge download and tries to deal with
// redirection, and extracting direct download link.
// Thanks to
// Ocye: http://lazarus.freepascal.org/index.php/topic,13425.msg70575.html#msg70575
const
  SFProjectPart = '//sourceforge.net/projects/';
  SFFilesPart = '/files/';
  SFDownloadPart ='/download';
var
  HTTPSender: THTTPSend;
  i, j: integer;
  FoundCorrectURL: boolean;
  SFDirectory: string; //Sourceforge directory
  SFDirectoryBegin: integer;
  SFFileBegin: integer;
  SFFilename: string; //Sourceforge name of file
  SFProject: string;
  SFProjectBegin: integer;
begin
  // Detect SourceForge download; e.g. from URL
  //          1         2         3         4         5         6         7         8         9
  // 1234557890123456789012345578901234567890123455789012345678901234557890123456789012345578901234567890
  // http://sourceforge.net/projects/base64decoder/files/base64decoder/version%202.0/b64util.zip/download
  //                                 ^^^project^^^       ^^^directory............^^^ ^^^file^^^
  FoundCorrectURL:=true; //Assume not a SF download
  i:=Pos(SFProjectPart, URL);
  if i>0 then
  begin
    // Possibly found project; now extract project, directory and filename parts.
    SFProjectBegin:=i+Length(SFProjectPart);
    j := PosEx(SFFilesPart, URL, SFProjectBegin);
    if (j>0) then
    begin
      SFProject:=Copy(URL, SFProjectBegin, j-SFProjectBegin);
      SFDirectoryBegin:=PosEx(SFFilesPart, URL, SFProjectBegin)+Length(SFFilesPart);
      if SFDirectoryBegin>0 then
      begin
        // Find file
        // URL might have trailing arguments... so: search for first
        // /download coming up from the right, but it should be after
        // /files/
        i:=RPos(SFDownloadPart, URL);
        // Now look for previous / so we can make out the file
        // This might perhaps be the trailing / in /files/
        SFFileBegin:=RPosEx('/',URL,i-1)+1;

        if SFFileBegin>0 then
        begin
          SFFilename:=Copy(URL,SFFileBegin, i-SFFileBegin);
          //Include trailing /
          SFDirectory:=Copy(URL, SFDirectoryBegin, SFFileBegin-SFDirectoryBegin);
          FoundCorrectURL:=false;
        end;
      end;
    end;
  end;

  if not FoundCorrectURL then
  begin
    try
      // Rewrite URL if needed for Sourceforge download redirection
      // Detect direct link in HTML body and get URL from that
      HTTPSender := THTTPSend.Create;
      //Who knows, this might help:
      HTTPSender.UserAgent:='curl/7.21.0 (i686-pc-linux-gnu) libcurl/7.21.0 OpenSSL/0.9.8o zlib/1.2.3.4 libidn/1.18';
      while not FoundCorrectURL do
      begin
        HTTPSender.HTTPMethod('GET', URL);
        case HTTPSender.Resultcode of
          301, 302, 307:
            begin
              for i := 0 to HTTPSender.Headers.Count - 1 do
                if (Pos('Location: ', HTTPSender.Headers.Strings[i]) > 0) or
                  (Pos('location: ', HTTPSender.Headers.Strings[i]) > 0) then
                begin
                  j := Pos('use_mirror=', HTTPSender.Headers.Strings[i]);
                  if j > 0 then
                    URL :=
                      'http://' + RightStr(HTTPSender.Headers.Strings[i],
                      length(HTTPSender.Headers.Strings[i]) - j - 10) +
                      '.dl.sourceforge.net/project/' +
                      SFProject + '/' + SFDirectory + SFFilename
                  else
                    URL:=StringReplace(
                      HTTPSender.Headers.Strings[i], 'Location: ', '', []);
                  HTTPSender.Clear;//httpsend
                  FoundCorrectURL:=true;
                  break; //out of rewriting loop
              end;
            end;
          100..200:
            begin
              //Could be a sourceforge timer/direct link page, but...
              if AnsiPos('Content-Type: text/html', HTTPSender.Headers.Text)>0 then
              begin
                // find out... it's at least not a binary
                URL:=SFDirectLinkURL(URL, HTTPSender.Document);
              end;
              FoundCorrectURL:=true; //We're done by now
            end;
          500: raise Exception.Create('No internet connection available');
            //Internal Server Error ('+aURL+')');
          else
            raise Exception.Create('Download failed with error code ' +
              IntToStr(HTTPSender.ResultCode) + ' (' + HTTPSender.ResultString + ')');
        end;//case
      end;//while
    finally
      HTTPSender.Free;
    end;
  end;
  result:=URL;
end;

function DownloadHTTP(URL, TargetFile: string): boolean;
// Download file; retry if necessary.
// Deals with SourceForge download links
var
  Buffer: TMemoryStream;
begin
  result:=false;
  URL:=SourceForgeURL(URL); //Deal with sourceforge URLs
  try
    Buffer := TMemoryStream.Create;
    DownloadHTTPStream(URL, Buffer);
    Buffer.SaveToFile(TargetFile);
    result:=true;
  finally
    FreeAndNil(Buffer);
  end;
end;

function DeleteDirectoryEx(DirectoryName: string): boolean;
// Lazarus fileutil.DeleteDirectory on steroids, works like
// deltree <directory>, rmdir /s /q <directory> or rm -rf <directory>
// - removes read-only files/directories (DeleteDirectory doesn't)
// - removes directory itself
// Adapted from fileutil.DeleteDirectory, thanks to Paweł Dmitruk
var
  FileInfo: TSearchRec;
  CurSrcDir: String;
  CurFilename: String;
begin
  Result:=false;
  CurSrcDir:=CleanAndExpandDirectory(DirectoryName);
  if FindFirstUTF8(CurSrcDir+GetAllFilesMask,faAnyFile,FileInfo)=0 then
  begin
    repeat
      // Ignore directories and files without name:
      if (FileInfo.Name<>'.') and (FileInfo.Name<>'..') and (FileInfo.Name<>'') then
      begin
        // Remove all files and directories in this directory:
        CurFilename:=CurSrcDir+FileInfo.Name;
        // Remove read-only file attribute so we can delete it:
        if (FileInfo.Attr and faReadOnly)>0 then
          FileSetAttrUTF8(CurFilename, FileInfo.Attr-faReadOnly);
        if (FileInfo.Attr and faDirectory)>0 then
        begin
          // Directory; exit with failure on error
          if not DeleteDirectoryEx(CurFilename) then exit;
        end
        else
        begin
          // File; exit with failure on error
          if not DeleteFileUTF8(CurFilename) then exit;
        end;
      end;
    until FindNextUTF8(FileInfo)<>0;
  end;
  FindCloseUTF8(FileInfo);
  // Remove root directory; exit with failure on error:
  if (not RemoveDirUTF8(DirectoryName)) then exit;
  Result:=true;
end;

function Download(URL, TargetFile: string): boolean;
begin
  result:=false;
  // Assume http if no ftp detected
  try
    infoln('Going to download '+TargetFile+' from URL: ' + URL);
    if (Copy(URL, 1, Length('ftp://'))='ftp://') or
    (Copy(URL,1,Length('ftp.'))='ftp.') then
    begin
      result:=DownloadFTP(URL, TargetFile);
    end
    else
    begin
      result:=DownloadHTTP(URL, TargetFile);
    end;
  except
    on E: Exception do
    begin
      infoln('Download: error occurred downloading file '+TargetFile+' from URL: '+URL+
        '. Exception occurred: '+E.ClassName+'/'+E.Message+')');
    end;
    //Not writing message here; to be handled by calling code with more context.
    //if result:=false then infoln('Download: download of '+TargetFile+' from URL: '+URL+' failed.');
  end;
end;

{$IFDEF MSWINDOWS}
function GetLocalAppDataPath: string;
var
  AppDataPath: array[0..MaxPathLen] of char; //Allocate memory
begin
  AppDataPath := '';
  SHGetSpecialFolderPath(0, AppDataPath, CSIDL_LOCAL_APPDATA, False);
  result:=AppDataPath;
end;
{$ENDIF MSWINDOWS}

procedure infoln(Message: string);
begin
  if AnsiPos(LineEnding, Message)>0 then writeln(''); //Write an empty line before multiline messagse
  writeln('Info: ' + Message); //we misuse this for info output
  sleep(200); //hopefully allow output to be written without interfering with other output
  {$IFDEF DEBUG}
  {DEBUG conditional symbol is defined using
  Project Options/Other/Custom Options using -dDEBUG}
  //Possibly more extensive logging
  {$ENDIF DEBUG}
end;

function MoveFile(const SrcFilename, DestFilename: string): boolean;
// We might (in theory) be moving files across partitions so we cannot use renamefile
begin
  try
    if FileExistsUTF8(SrcFileName) then
    begin
      if FileUtil.CopyFile(SrcFilename, DestFileName) then Sysutils.DeleteFile(SrcFileName);
      result:=true;
    end
    else
    begin
      //Source file does not exist, so cannot move
      result:=false;
    end;
  except
    result:=false;
  end;
end;

function Which(Executable: string): string;
var
  Output: string;
begin
  {$IFDEF UNIX}
  // Note: we're using external which because
  // FindDefaultExecutablePath
  // doesn't check if the user has execute permission
  // on the found file.
  ExecuteCommandHidden('which',Executable,Output,false);
  //Remove trailing LF(s) and other control codes:
  while (length(output)>0) and (ord(output[length(output)])<$20) do
    delete(output,length(output),1);
  {$ELSE}
  Output:=FindDefaultExecutablePath(Executable);
  {$ENDIF UNIX}
  // We could have checked for ExecuteCommandHidden exitcode, but why not
  // do file existence check instead:
  if fileexists(Output) then
  begin
    result:=Output;
  end
  else
  begin
    result:=''; //command failed
  end;
end;


{$IFDEF UNIX}
//Adapted from sysutils; Unix/Linux only
Function XdgConfigHome: String;
{ Follows base-dir spec,
  see [http://freedesktop.org/Standards/basedir-spec].
  Always ends with PathDelim. }
begin
  Result:=GetEnvironmentVariable('XDG_CONFIG_HOME');
  if (Result='') then
    Result:=IncludeTrailingPathDelimiter(ExpandFileNameUTF8('~'))+'.config'+DirectorySeparator
  else
    Result:=IncludeTrailingPathDelimiter(Result);
end;
{$ENDIF UNIX}

end.

