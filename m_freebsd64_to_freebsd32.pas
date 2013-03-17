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
  Classes, SysUtils, m_crossinstaller;

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
  result:=true;
end;

function TFreeBSD64_FreeBSD386.GetLibsLCL(LCL_Platform: string; Basepath: string): boolean;
begin
  result:=true;
end;

function TFreeBSD64_FreeBSD386.GetBinUtils(Basepath:string): boolean;
begin
  FBinUtilsPath:='';
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

initialization
  FreeBSD64_FreeBSD386:=TFreeBSD64_FreeBSD386.Create;
  RegisterExtension(FreeBSD64_FreeBSD386.TargetCPU+'-'+FreeBSD64_FreeBSD386.TargetOS,FreeBSD64_FreeBSD386);
finalization
  FreeBSD64_FreeBSD386.Destroy;
end.


