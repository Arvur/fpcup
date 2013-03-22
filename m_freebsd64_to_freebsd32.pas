unit m_freebsd64_to_freebsd32;
{ Cross compiles from FreeBSD x64 to FreeBSD x86
Needed ports/packages:
- to do: default available with pc bsd; need to find out for freebsd
perhaps something like
cd /usr/src && make build32 install32 && ldconfig -v -m -R /usr/lib32
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, m_crossinstaller, fpcuputil;

implementation

type

{ TFreeBSD_win386 }

TFreeBSD64_FreeBSD386 = class(TCrossInstaller)
private

public
  function GetLibs(Basepath:string):boolean;override;
  function GetLibsLCL(LCL_Platform:string; Basepath:string):boolean;override;
  function GetBinUtils(Basepath:string):boolean;override;
  constructor Create;
  destructor Destroy; override;
end;

{ TFreeBSD64_FreeBSD386 }

function TFreeBSD64_FreeBSD386.GetLibs(Basepath:string): boolean;
begin
  FLibsPath:='/usr/lib32';
  result:=fileexists(FLibsPath+'/libc.so'); //let the c library be our coalmine canary
end;

function TFreeBSD64_FreeBSD386.GetLibsLCL(LCL_Platform: string; Basepath: string): boolean;
begin
  result:=true;
end;

function TFreeBSD64_FreeBSD386.GetBinUtils(Basepath:string): boolean;
begin
  //todo: remove once done
  infoln('Experimental, not finished. Stopping now.',etError);
  result:=false;
  FBinUtilsPath:='/usr/bin'; //try with regular binutils
  FBinUtilsPrefix:=''; // we have the "native" names, no prefix
  result:=true;
end;

constructor TFreeBSD64_FreeBSD386.Create;
begin
  inherited Create;
  FTargetCPU:='i386';
  FTargetOS:='freebsd';
end;

destructor TFreeBSD64_FreeBSD386.Destroy;
begin
  inherited Destroy;
end;

var
  FreeBSD64_FreeBSD386:TFreeBSD64_FreeBSD386;

//todo: FreeBSD64_FreeBSD386: enable when working. For this, we'll probably need to pass -32 to ld etc. Perhaps do this with batch scripts
{
initialization
  FreeBSD64_FreeBSD386:=TFreeBSD64_FreeBSD386.Create;
  RegisterExtension(FreeBSD64_FreeBSD386.TargetCPU+'-'+FreeBSD64_FreeBSD386.TargetOS,FreeBSD64_FreeBSD386);
finalization
  FreeBSD64_FreeBSD386.Destroy;
}
end.

