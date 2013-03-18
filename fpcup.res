        ��  ��                  g:  8   F I L E   F P C U P _ I N I         0	        [general]
; You CAN NOT specify options like lazdir here. Please use the command line for that. Run fpcup --help for details
; Users: you can override if a module is executed, e.g. to run the synapse module regardless of the fpcup maintainers settings below:
;synapsetrunk=1
;fpspreadsheet=1

[ALIASfpcURL]
2.7.1=http://svn.freepascal.org/svn/fpc/trunk/
trunk=http://svn.freepascal.org/svn/fpc/trunk/
2.6.2=http://svn.freepascal.org/svn/fpc/tags/release_2_6_2
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
; note: held back because problems with tachartaxisutils on linux x64 (Nov 2012)
;AddPackage8=$(lazarusdir)\components\tachart\tachartaggpas.lpk
; won't compile...: tachartfpvectorial
; TAChart.  you might want to add some backend packages
;AddPackage9=$(lazarusdir)\components\tachart\tachartlazaruspkg.lpk
; Rx components; additional GUI components
AddPackage10=$(lazarusdir)\components\rx\rx.lpk
; This shows that you can add a package by name instead of full path
AddPackage11=cody

[FPCUPModule2]
; lhelp CHM help viewer for Lazarus, and associated package.
; A CHM help viewer is required in order to view CHM help from within Lazarus
; Note: since 1.0.x, lhelp is automatically built as required by Lazarus.
; As running make clean/make distclean for x64 LCL compilation on Windows removes
; lhelp.exe and Lazarus doesn't appear to be smart enough to compile it again, let's
; just disable this altogether.
Name=lhelp
Enabled=0
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

[FPCUPModule9]
; Lazarus resource file creator
; Note: could also be generated by
; make tools
; (which requires LCL+nogui widgetset, e.g. provided by lazbuild)
Name=lazres
Enabled=1
Workingdir=$(lazarusdir)/tools
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(lazarusdir)/tools/lazres.lpi

[FPCUPModule10]
; Synapse development/trunk version
; http://www.ararat.cz/synapse/doku.php
Name=synapsetrunk
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=https://synalist.svn.sourceforge.net/svnroot/synalist/trunk
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/laz_synapse.lpk
AddPackage1=$(Installdir)/laz_synapse.lpk
UnInstall1=rm -Rf $(Installdir)

[FPCUPModule11]
; Bindings to the SANE *nix scanner library
Name=pascalsane
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=http://ocrivist.googlecode.com/svn/PascalSane/
UnInstall1=rm -Rf $(Installdir)

[FPCUPModule12]
; Leptonica (layout recognition) library bindings
Name=leptonica
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=http://ocrivist.googlecode.com/svn/leptonica/
UnInstall1=rm -Rf $(Installdir)

[FPCUPModule13]
; Tesseract OCR library interface
; probably for old 2.04 version
; nwe version 3 is rewritten... see bug:
; https://code.google.com/p/tesseract-ocr/issues/detail?id=362
Name=tesseract
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=http://ocrivist.googlecode.com/svn/tessintf/
UnInstall1=rm -Rf $(Installdir)

[FPCUPModule14]
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

[FPCUPModule15]
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
// Tachart seems to be broken now and then, but I suppose we'd better leave it in:
AddPackage15=tachartlazaruspkg
AddPackage16=todolistlaz
AddPackage17=turbopoweripro

[FPCUPModule16]
; Zeos database components (testing branch => seem the most reliable)
; See
; http://http://zeos.firmos.at/
; http://wiki.lazarus.freepascal.org/ZeosDBO
Name=zeostesting
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=http://svn.code.sf.net/p/zeoslib/code-0/branches/testing/
UnInstall1=rm -Rf $(Installdir)
AddPackage1=$(Installdir)\packages\lazarus\zcomponent.lpk

[FPCUPModule17]
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

[FPCUPModule18]
; RX controls
; There are some rx controls incorporated into Lazarus; others are
; still part of a separate project in Lazarus CCR
; http://wiki.lazarus.freepascal.org/rx
Name=rx
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=https://lazarus-ccr.svn.sourceforge.net/svnroot/lazarus-ccr/components/rx
; Compile the non-visual package
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/rxnew.lpk
; ... and mark the visual package for installation into Lazarus:
AddPackage1=$(Installdir)/dcl_rx_ctrl.lpk
UnInstall=rm -Rf $(Installdir)

[FPCUPModule19]
; LazPaint painting program with layer support etc
Name=lazpaint
Enabled=0
Installdir=$(fpcdir)/../extras/$(name)
SVNURL=svn://svn.code.sf.net/p/lazpaint/code/
; no idea if there are .lpks that may need to be installed. Please update if using this.
; InstallExecute1=
; AddPackage1=
UnInstall=rm -Rf $(Installdir)

[FPCUPModule20]
; Create Lazarus Windows installer
Name=installerlazwin
; For the installer, we place some SVN directories below the installdir;
; the user need not worry about these.
; Note: the output setup executable will not be put there.
Installdir=$(fpcdir)/../$(name)
Enabled=0
CreateInstaller1=Windows
Uninstall=rm -Rf $(Installdir)

[FPCUPModule21]
; lnet FPC/Lazarus package
; lnet is a small network library, an alternative to e.g. Synapse
; see http://wiki.lazarus.freepascal.org/lNet
Name=lnet
Installdir=$(fpcdir)/../extras/$(name)
Enabled=1
; we only want the trunk branch as otherwise we'd get all old releases
SVNURL=http://svn.freepascal.org/svn/fpcprojects/lnet/trunk
; compile the non-visual package
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/lazaruspackage/lnetbase.lpk
; and mark the visual package for installation:
AddPackage1=$(Installdir)\lazaruspackage\lnetvisual.lpk
; no idea if there are .lpks that may need to be installed. Please update if using this.
; InstallExecute1=
; AddPackage1=
UnInstall=rm -Rf $(Installdir)

[FPCUPModule22]
; fpcup source code itself
Name=fpcup
Installdir=$(fpcdir)/../extras/$(name)
Enabled=1
HGURL=https://bitbucket.org/reiniero/fpcup
; We need to have a working hgversion first...
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/hgversion.lpi
; .... then compile fpcup
InstallExecute2=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/fpcup.lpi
UnInstall=rm -Rf $(Installdir)

[FPCUPModule23]
; Vampyre imaging library
Name=vampyre
Installdir=$(fpcdir)/../extras/$(name)
Enabled=0
HGURL=http://imaginglib.hg.sourceforge.net:8000/hgroot/imaginglib/imaginglib
; compile vampyre package
InstallExecute1=$(lazarusdir)/lazbuild --primary-config-path=$(LazarusPrimaryConfigPath) $(Installdir)/Extras/IdePackages/vampyreimagingpackage.lpk
; or use AddPackage if it is a designtime package (todo: check)
UnInstall=rm -Rf $(Installdir)

[FPCUpModule24]
; tiOPF object-persistence framework
Name=tiopf
Installdir=$(fpcdir)/../extras/$(name)
Enabled=0
GITURL=git://git.code.sf.net/p/fpgui/code       
UnInstall=rm -Rf $(Installdir)

[FPCUPModule25]
; Packaging addin for creating Debian packages from your Lazarus project
Name=lazpackager
Installdir=$(fpcdir)/../extras/$(name)
Enabled=1
GITURL=https://github.com/prof7bit/LazPackager.git
UnInstall=rm -Rf $(Installdir)

[FPCUPModule26]
; JSON saving/loading from grid
Name=ljgridutils
Installdir=$(fpcdir)/../extras/$(name)
Enabled=0
GITURL=https://github.com/silvioprog/ljgridutils.git
UnInstall=rm -Rf $(Installdir)

[FPCUPModule27]
; Brook web application server framework
Name=brookframework
Installdir=$(fpcdir)/../extras/$(name)
Enabled=0
GITURL=https://github.com/silvioprog/brookframework.git
UnInstall=rm -Rf $(Installdir)

[FPCUPModule28]
; Greyhound is an ORM (database persistence) framework for FPC/Lazarus
Name=greyhound
Installdir=$(fpcdir)/../extras/$(name)
Enabled=0
GITURL=https://github.com/mdbs99/Greyhound.git
UnInstall=rm -Rf $(Installdir)

[FPCUpModule29]
; Experimental bindings for the mupdf pdf visualization library
Name=mupdf
Installdir=$(fpcdir)/../extras/$(name)
Enabled=0
GITURL=https://github.com/blestan/lazmupdf.git
UnInstall=rm -Rf $(Installdir)
 