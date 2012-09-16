        ��  ��                  �3  8   F I L E   F P C U P _ I N I         0	        [general]
; You CAN NOT specify options like lazdir here. Please use the command line for that. Run fpcup --help for details
; Users: you can override if a module is executed, e.g. to run the synapse module regardless of the fpcup maintainers settings below:
;synapsetrunk=1
;fpspreadsheet=1
;tiopf=1

[ALIASfpcURL]
2.7.1=http://svn.freepascal.org/svn/fpc/trunk/
trunk=http://svn.freepascal.org/svn/fpc/trunk/
2.6.1=http://svn.freepascal.org/svn/fpc/branches/fixes_2_6
fixes=http://svn.freepascal.org/svn/fpc/branches/fixes_2_6
2.6.0=http://svn.freepascal.org/svn/fpc/tags/release_2_6_0

[ALIASlazURL]
trunk=http://svn.freepascal.org/svn/lazarus/trunk
1.1=http://svn.freepascal.org/svn/lazarus/trunk
1.0=http://svn.freepascal.org/svn/lazarus/tags/lazarus_1_0

[FPCUPModule1]
; These IDE packages can be handy when developing
; they were selected by the fpcup maintainers.
; Please feel free to add your own.
Name=suggestedpackages
Enabled=1
; Note: the next lines show you can use either Windows \ or Unix / in a path
; .... but not both in the same line

; To add a package to the list, use AddPackage<n>
; You will need to recompile the IDE, e.g. using the USERIDE sequence in fpcup
; (which is done for you in the default setup)
; DBF components:
AddPackage1=$(lazarusdir)\components\tdbf\dbflaz.lpk
;Apparently not a GUI package?? fpcunitconsolerunner.lpk
; FPC unit test package; handy when creating/running tests:
AddPackage2=$(lazarusdir)/components/fpcunit/ide/fpcunitide.lpk
;Apparently not a GUI package?? fpcunittestrunner.lpk
; Build daemon/service applications:
AddPackage3=$(lazarusdir)\components\daemon\lazdaemon.lpk
; Lazarus data dictionary support; handy with lazdatadesktop
AddPackage4=$(lazarusdir)\components\datadict\lazdatadict.lpk
; Dataset export package:
AddPackage5=$(lazarusdir)\components\dbexport\lazdbexport.lpk
; Reporting
; You can add the lazreport pdf export package if you want
AddPackage6=$(lazarusdir)\components\lazreport\source\lazreport.lpk
; Leakview: allows you to view heaptrc reports:
AddPackage7=$(lazarusdir)\components\leakview\leakview.lpk
; AggPas backend for TAChart
AddPackage8=$(lazarusdir)\components\tachart\tachartaggpas.lpk
; won't compile...: tachartfpvectorial
; TAChart.  you might want to add some backend packages
AddPackage9=$(lazarusdir)\components\tachart\tachartlazaruspkg.lpk
; Rx components; additional GUI components
AddPackage10=$(lazarusdir)\components\rx\rx.lpk
; This shows that you can add a package by name instead of full path
AddPackage11=cody

[FPCUPModule2]
; lhelp CHM help viewer for Lazarus, and associated package.
; A CHM help viewer is required in order to view CHM help from within Lazarus
; Note: todo: since r37749, bigide probably builds lhelp. investigate and remove this package then.
Name=lhelp
Enabled=1
Workingdir=$(lazarusdir)/components/chmhelp/lhelp
; Build the lhelp program:
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(lazarusdir)/components/chmhelp/lhelp/lhelp.lpr
; ... and add the chm help package to the IDE.
; We specify the full path to make sure it is in the known list of packages, even if we did not build bigide before:
AddPackage1=$(lazarusdir)\components\chmhelp\packages\idehelp\chmhelppkg.lpk
; Use the RegisterHelpViewer to register the executable as a Lazarus help viewer.
RegisterHelpViewer=$(Workingdir)/$(name)

[FPCUPModule3]
; A database helper tool for Lazarus
Name=lazdatadesktop
Enabled=1
Workingdir=$(lazarusdir)/tools/lazdatadesktop
InstallExecute1=$(lazarusdir)/lazbuild  --primary-config-path=$(LazarusPrimaryConfigPath) $(lazarusdir)/tools/lazdatadesktop/lazdatadesktop.lpr
RegisterExternalTool=$(lazarusdir)/tools/lazdatadesktop/lazdatadesktop
;Additional RegisterExternalTool* commands:
;RegisterExternalToolCmdLineParams=string
;RegisterExternalToolWorkingDirectory=string
;RegisterExternalToolScanOutputForFPCMessages=0|1
;RegisterExternalToolScanOutputForMakeMessages=0|1
;RegisterExternalToolHideMainForm=0|1

[FPCUPModule4]
; Lazarus DocEditor; used to edit fpdoc (FPC and Lazarus) documentation files
; Can be used as an external tool in Lazarus
Name=doceditor
Enabled=1
Workingdir=$(lazarusdir)/doceditor
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(lazarusdir)/doceditor/lazde.lpr
RegisterExternalTool=$(lazarusdir)/doceditor/lazde

[FPCUPModule5]
; Synapse networking library
; http://www.ararat.cz/synapse/doku.php
Name=synapse
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=https://synalist.svn.sourceforge.net/svnroot/synalist/trunk
; Compile the package (not strictly necessary, but nice to notice errors immediately)...
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/laz_synapse.lpk
; .. now use AddPackage to add this package to the Lazarus install list:
AddPackage1=$(Installdir)/laz_synapse.lpk
UnInstallExecute1=rm -Rf $(Installdir)

[FPCUPModule6]
; Lazarus Code and Components Repository
; includes fpspreadsheet etc. You can also enable individual parts (see e.g. below for fpspreadsheet)
Name=lazarus_ccr
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=https://lazarus-ccr.svn.sourceforge.net/svnroot/lazarus-ccr
UnInstall=rm -Rf $(Installdir)

[FPCUPModule7]
; The fpSpreadsheet library offers a convenient way to generate and read spreadsheet documents
; http://wiki.lazarus.freepascal.org/FPSpreadsheet
Name=fpspreadsheet
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=https://lazarus-ccr.svn.sourceforge.net/svnroot/lazarus-ccr/components/fpspreadsheet
; Compile the non-visual package
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/laz_fpspreadsheet.lpk
; ... and mark them for installation into Lazarus:
AddPackage1=$(Installdir)/laz_fpspreadsheet.lpk
AddPackage2=$(Installdir)/laz_fpspreadsheet_visual.lpk
UnInstall=rm -Rf $(Installdir)

[FPCUPModule8]
; The TechInsite Object Persistence Framework (tiOPF) is an Open Source framework of Delphi/Object Pascal code that simplifies the mapping of an object oriented business model into a relational database. 
; It also offers utility classes
; Source code component; will be pulled in by module 10
Name=tiopf_source
Enabled=0
; tiopf likes to be installed in a certain directory
Installdir=$(fpcdir)/../extras/tiopf/Source
SVNURL=https://tiopf.svn.sourceforge.net/svnroot/tiopf/tiOPF2/Trunk
; These two packages must only be compiled, not installed into Lazarus:
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/Compilers/FPC/tiOPF.lpk
InstallExecute2=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/Compilers/FPC/tiopflcl.lpk
; Help integration for tiopf; can be installed from within Lazarus if required
InstallExecute3=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/Compilers/FPC/tiOPFHelpIntegration.lpk
; For the Integrated Help to work, Lazarus needs to know how to find the html help files. Please read the tiOPFHelpIntegration.txt file located in \Source\Compilers\FPC for further instructions.
; we don't install this by default then:
;AddPackage1=$(Installdir)/Compilers/FPC/tiOPFHelpIntegration.lpk
UnInstall=rm -Rf $(Installdir)

[FPCUPModule9]
; The TechInsite Object Persistence Framework (tiOPF) is an Open Source framework of Delphi/Object Pascal code that simplifies the mapping of an object oriented business model into a relational database. 
; It also offers utility classes
; Demos component; will be pulled in by module 10
Name=tiopf_demos
Enabled=0
; tiopf likes to be installed in a certain directory
Installdir=$(fpcdir)/../extras/tiopf/Demos
SVNURL=https://tiopf.svn.sourceforge.net/svnroot/tiopf/tiOPF2_Demos
UnInstall=rm -Rf $(Installdir)

[FPCUPModule10]
; The TechInsite Object Persistence Framework (tiOPF) is an Open Source framework of Delphi/Object Pascal code that simplifies the mapping of an object oriented business model into a relational database. 
; It also offers utility classes
; Documentation component; will be pulled in by module 10
Name=tiopf_docs
Enabled=0
; tiopf likes to be installed in a certain directory
Installdir=$(fpcdir)/../extras/tiopf/Docs
SVNURL=https://tiopf.svn.sourceforge.net/svnroot/tiopf/tiOPF2_Docs
UnInstall=rm -Rf $(Installdir)

[FPCUPModule11]
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

[FPCUPModule12]
; fpcdocs contains the source code for FPC documentation
; Handy if you want to edit it, and if you want to show pop up
; hints in Lazarus
Name=fpcdocs
Enabled=1
Installdir=$(fpcdir)/../extras/$(name)
; RegisterLazDocPath registers the path with xml documentation file
; in Lazarus so you get updated hints when hovering over a keyword
RegisterLazDocPath=$(fpcdir)/../extras/$(name)
SVNURL=http://svn.freepascal.org/svn/fpcdocs/trunk
UnInstall1=rm -Rf $(Installdir)

[FPCUPModule13]
; Lazarus resource file creator
; Note: could also be generated by
; make tools
; (which requires LCL+nogui widgetset, e.g. provided by lazbuild)
Name=lazres
Enabled=1
Workingdir=$(lazarusdir)/tools
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(lazarusdir)/tools/lazres.lpi

[FPCUPModule14]
; Synapse development/trunk version
; http://www.ararat.cz/synapse/doku.php
Name=synapsetrunk
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=https://synalist.svn.sourceforge.net/svnroot/synalist/trunk
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/laz_synapse.lpk
AddPackage1=$(Installdir)/laz_synapse.lpk
UnInstall1=rm -Rf $(Installdir)

[FPCUPModule15]
; Bindings to the SANE *nix scanner library
Name=pascalsane
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=http://ocrivist.googlecode.com/svn/PascalSane/
UnInstall1=rm -Rf $(Installdir)

[FPCUPModule16]
; Leptonica (layout recognition) library bindings
Name=leptonica
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=http://ocrivist.googlecode.com/svn/leptonica/
UnInstall1=rm -Rf $(Installdir)

[FPCUPModule17]
; Tesseract OCR library interface
; probably for old 2.04 version
; nwe version 3 is rewritten... see bug:
; https://code.google.com/p/tesseract-ocr/issues/detail?id=362
Name=tesseract
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=http://ocrivist.googlecode.com/svn/tessintf/
UnInstall1=rm -Rf $(Installdir)

[FPCUPModule18]
; OCRivist program for OCR.
; Uses leptonica, tesseract, pascalsane
; Note: has not been tested; perhaps won't work with Tesseract 3
; might also be easier to run TProcess to call CLI executables
Name=OCRivist
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
; Demo/main program:
SVNURL=http://ocrivist.googlecode.com/svn/trunk/
Requires=pascalsane,leptonica,tesseract
UnInstall1=rm -Rf $(Installdir)

[FPCUPModule19]
; BigIDE packages: the packages that will be used in a big ide build.
; If the bigide sequence fails to permanently mark these for installation
; we can try it this way.
Name=bigidepackages
Enabled=0
; This demonstrates that you can add packages by name instead of filename
AddPackage1=chmhelppkg
AddPackage2=dbflaz
AddPackage3=externhelp
AddPackage4=fpcunitide
AddPackage5=instantfpclaz
AddPackage6=jcfidelazarus
AddPackage7=leakview
AddPackage8=memdslaz
// this seems to not work??
AddPackage9=printer4lazarus
AddPackage10=printers4lazide
AddPackage11=projtemplates
// this seems to not work??
AddPackage12=runtimetypeinfocontrols
AddPackage13=sdflaz
AddPackage14=sqldblaz
// this seems to not work??
AddPackage15=tachartlazaruspkg
AddPackage16=todolistlaz
AddPackage17turbopoweripro

[FPCUPModule20]
; Zeos database components (testing branch => seem the most reliable)
; See
; http://http://zeos.firmos.at/
; http://wiki.lazarus.freepascal.org/ZeosDBO
Name=zeostesting
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=http://zeoslib.svn.sourceforge.net/svnroot/zeoslib/branches/testing
UnInstall1=rm -Rf $(Installdir)
AddPackage1=$(Installdir)\packages\lazarus\zcomponent.lpk

[FPCUPModule21]
; kzdesktop: change the Lazarus IDE layout into a tabbed layout
; See:
;http://lazarus.freepascal.org/index.php/topic,16736.0.html
;http://sourceforge.net/projects/kzdesktop/
Name=kzdesktop
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=http://svn.code.sf.net/p/kzdesktop/code/trunk
UnInstall1=rm -Rf $(Installdir)
AddPackage1=$(Installdir)\kzdesktop_ide.lpk
  