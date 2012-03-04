        ��  ��                  �  8   F I L E   F P C U P _ I N I         0	        [general]
[Module1]
; lhelp CHM help viewer for Lazarus.
; A CHM help viewer is required in order to view CHM help from within Lazarus
Name=lhelp
Enabled=1
Workingdir=$(lazarusdir)/components/chmhelp/lhelp
InstallExecute1=$(lazarusdir)/lazbuild  --primary-config-path=$(LazarusPrimaryConfigPath) $(lazarusdir)/components/chmhelp/lhelp/lhelp.lpr
AddToHelpOptions1=Viewers/TChmHelpViewer/CHMHelp/Exe:$(lazarusdir)/components/chmhelp/lhelp/lhelp.exe

[Module2]
; A database helper tool for Lazarus
Name=lazdatadesktop
Enabled=1
Workingdir=$(lazarusdir)/tools/lazdatadesktop
InstallExecute1=$(lazarusdir)/lazbuild  --primary-config-path=$(LazarusPrimaryConfigPath) $(lazarusdir)/tools/lazdatadesktop/lazdatadesktop.lpr
; we miss the .exe; perhaps Laz will pick it up
AddToEnvironmentOptions1=ExternalTools/Tool#/Format/Version@ExternalTools/Count:2  
AddToEnvironmentOptions2=ExternalTools/Tool#/Title/Value@ExternalTools/Count:LazDataDesktop
AddToEnvironmentOptions3=ExternalTools/Tool#/Filename/Value@ExternalTools/Count:$(lazarusdir)/tools/lazdatadesktop/lazdatadesktop
; alternative: new command
; RegisterExternalTool will register the tool in your Lazarus Tools menu if it can find the application.
; On Windows, it will look for an .exe extension as well.
; It will replace existing tools with the same name
;RegisterExternalTool1=$(lazarusdir)/tools/lazdatadesktop/lazdatadesktop

[Module3]
; Lazarus DocEditor; used to edit fpdoc (FPC and Lazarus) documentation files
; Can be used as an external tool in Lazarus
Name=doceditor
Enabled=1
Workingdir=$(lazarusdir)/doceditor
InstallExecute1=$(lazarusdir)/lazbuild  --primary-config-path=$(LazarusPrimaryConfigPath) $(lazarusdir)/doceditor/lazde.lpr

[Module4]
; Synapse networking library
; http://www.ararat.cz/synapse/doku.php
Name=synapse
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=https://synalist.svn.sourceforge.net/svnroot/synalist/trunk/
UnInstall1=rm -Rf $(Installdir)

[Module5]
; Lazarus Code and Components Repository
Name=lazarus_ccr
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=https://lazarus-ccr.svn.sourceforge.net/svnroot/lazarus-ccr
UnInstall=rm -Rf $(Installdir)

[Module6]
; The fpSpreadsheet library offers a convenient way to generate and read spreadsheet documents
; http://wiki.lazarus.freepascal.org/FPSpreadsheet
Name=fpspreadsheet
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=https://lazarus-ccr.svn.sourceforge.net/svnroot/lazarus-ccr/components/fpspreadsheet
UnInstall=rm -Rf $(Installdir)

[Module7]
; The TechInsite Object Persistence Framework (tiOPF) is an Open Source framework of Delphi/Object Pascal code that simplifies the mapping of an object oriented business model into a relational database. 
; It also offers utility classes
; Source code component; will be pulled in by module 10
Name=tiopf_source
Enabled=0
; tiopf likes to be installed in a certain directory
Installdir=$(fpcdir)/../extras/tiopf/Source
SVNURL=https://tiopf.svn.sourceforge.net/svnroot/tiopf/tiOPF2/Trunk
InstallExecute1=$(lazarusdir)/lazbuild  --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/Compilers/FPC/tiOpf.lpk
InstallExecute2=$(lazarusdir)/lazbuild  --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/Compilers/FPC/tiOPFLCL.lpk
; Help integration for tiopf; can be installed from withing Lazarus if required
InstallExecute3=$(lazarusdir)/lazbuild  --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/Compilers/FPC/tiOPFHelpIntegration.lpk
UnInstall=rm -Rf $(Installdir)

[Module8]
; The TechInsite Object Persistence Framework (tiOPF) is an Open Source framework of Delphi/Object Pascal code that simplifies the mapping of an object oriented business model into a relational database. 
; It also offers utility classes
; Demos component; will be pulled in by module 10
Name=tiopf_demos
Enabled=0
; tiopf likes to be installed in a certain directory
Installdir=$(fpcdir)/../extras/tiopf/Demos
SVNURL=https://tiopf.svn.sourceforge.net/svnroot/tiopf/tiOPF2_Demos
UnInstall=rm -Rf $(Installdir)

[Module9]
; The TechInsite Object Persistence Framework (tiOPF) is an Open Source framework of Delphi/Object Pascal code that simplifies the mapping of an object oriented business model into a relational database. 
; It also offers utility classes
; Documentation component; will be pulled in by module 10
Name=tiopf_docs
Enabled=0
; tiopf likes to be installed in a certain directory
Installdir=$(fpcdir)/../extras/tiopf/Docs
SVNURL=https://tiopf.svn.sourceforge.net/svnroot/tiopf/tiOPF2_Docs
UnInstall=rm -Rf $(Installdir)

[Module10]
; The TechInsite Object Persistence Framework (tiOPF) is an Open Source framework of Delphi/Object Pascal code that simplifies the mapping of an object oriented business model into a relational database. 
; It also offers utility classes
; Meta-module getting all 3 submodules
Name=tiopf
Enabled=0
; tiopf likes to be installed in a certain directory
Installdir=$(fpcdir)/../extras/$(name)
; Pull in dependencies from the three previous packages
Requires=tiopf_source,tiopf_demos,tiopf_docs
UnInstall=rm -Rf $(Installdir)

[Module11]
; fpcdocs contains the source code for FPC documentation
; Handy if you want to edit it, and if you want to show pop up
; hints in Lazarus
Name=fpcdocs
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=http://svn.freepascal.org/svn/fpcdocs/trunk
UnInstall1=rm -Rf $(Installdir)
  