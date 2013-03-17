unit m_freebsd_to_win386;

{ Cross compiles from FreeBSD x64 and presumably x86 to Windows i386 code (win32)
Needed ports/packages:
- see error message in code
}


{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, m_crossinstaller;

implementation
const
  ErrorNotFound='Not all required files are present.'+LineEnding+
    'Required ports/packages:'+LineEnding+
    LineEnding+
    LineEnding+
    'cd /usr/ports/devel/mingw32-bin-msvcrt'+LineEnding+
    'make -DBATCH install clean'+LineEnding+
    'cd /usr/ports/devel/mingw32-binutils'+LineEnding+
    'make -DBATCH install clean'+LineEnding+
    'cd /usr/ports/devel/mingw32-gcc'+LineEnding+
    'make -DBATCH install clean'+LineEnding+
    'cd /usr/ports/devel/mingw32-pthreads //=> not needed?'+LineEnding+
    'make -DBATCH install clean'+LineEnding+
    'This list may be excessive, please verify'+LineEnding+
    LineEnding+
    'Useful:'+LineEnding+
    'cd /usr/ports/emulators/wine'+LineEnding+
    'make -DBATCH install clean';

type

{ TFreeBSD_win386 }

TFreeBSD_win386 = class(TCrossInstaller)
private

public
  function GetLibs(Basepath:string):boolean;override;
  function GetLibsLCL(LCL_Platform:string; Basepath:string):boolean;override;
  function GetBinUtils(Basepath:string):boolean;override;
  constructor Create;
  destructor Destroy; override;
end;

{ TWin32 }

function TFreeBSD_win386.GetLibs(Basepath:string): boolean;
begin
  FLibsPath:='/usr/local/mingw32/lib';
  result:=true;
end;

function TFreeBSD_win386.GetLibsLCL(LCL_Platform: string; Basepath: string): boolean;
begin
  // todo: check if/how we need to implement freebsd=>win386 GetLibsLCL
  result:=true;
end;

function TFreeBSD_win386.GetBinUtils(Basepath:string): boolean;
begin
  FBinUtilsPath:='/usr/local/mingw32/bin';
  FBinUtilsPrefix:=''; // we have the "native" names, no prefix
  result:=fileexists(FBinUtilsPath+'as');
end;

constructor TFreeBSD_win386.Create;
begin
  inherited Create;
  FTargetCPU:='i386';
  FTargetOS:='win32';
end;

destructor TFreeBSD_win386.Destroy;
begin
  inherited Destroy;
end;

var
  FreeBSD_Linux386:TFreeBSD_win386;

initialization
  FreeBSD_Linux386:=TFreeBSD_win386.Create;
  RegisterExtension(FreeBSD_Linux386.TargetCPU+'-'+FreeBSD_Linux386.TargetOS,FreeBSD_Linux386);
finalization
  FreeBSD_Linux386.Destroy;
end.

