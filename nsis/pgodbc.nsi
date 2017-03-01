; PostgeSQL install Script
; Written by Postgres Professional, Postgrespro.ru
; Author: at the late night, Alexey Slaykovsky

!include "pgodbc.def.nsh"

;--------------------------------
;Include Modern UI
!include "MUI2.nsh"
!include "logiclib.nsh"

!include "WordFunc.nsh"
!include "TextFunc.nsh"
!include "StrRep.nsh"

!include "ReplaceInFile.nsh"
!include "common_macro.nsh"
!include "Utf8Converter.nsh"

!insertmacro VersionCompare

;--------------------------------
;General
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${BUILD_DIR}\installers\${PRODUCT_NAME}_${ADMIN_DEF_VERSION}_${ADMIN_INS_SUFFIX}"

!ifdef Admin64
  InstallDir "$PROGRAMFILES64\${PRODUCT_NAME}\${ADMIN_DEF_VERSION}"
!else
  InstallDir "$PROGRAMFILES32\${PRODUCT_NAME}\${ADMIN_DEF_VERSION}"
!endif

BrandingText "PostgresPro.ru"

;Get installation folder from registry if available
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""

;ShowInstDetails show
;ShowUnInstDetails show

;Request application privileges for Windows Vista
RequestExecutionLevel admin

Var StartMenuFolder

;MUI_COMPONENTSPAGE_SMALLDESC or MUI_COMPONENTSPAGE_NODESC
!define MUI_COMPONENTSPAGE_SMALLDESC

;--------------------------------
;Interface Settings

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "pp_header.bmp" ; optional
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\win-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "Elephant.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "Elephant.bmp"

!define MUI_ABORTWARNING

;--------------------------------
;Pages
;Page custom nsDialogsPage

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "License.txt"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY

;Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_DIR_REGKEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"
!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
;--------------------------------
;Installer Sections

Section "Microsoft Visual C++ ${REDIST_YEAR} Redistributable" secMS
  GetTempFileName $1
  !ifdef Admin64
    File /oname=$1 "${BUILD_DIR}\vcredist\vcredist_x64_${REDIST_YEAR}.exe"
  !else
    File /oname=$1 "${BUILD_DIR}\vcredist\vcredist_x86_${REDIST_YEAR}.exe"
  !endif
  ExecWait "$1  /passive /norestart" $0
  DetailPrint "Visual C++ Redistributable Packages return $0"
  Delete $1
SectionEnd

Section "psqlODBC" psqlODBC
  SetOutPath "$INSTDIR"
  File ${ADMIN_INS_SOURCE_DIR}pgenlist.dll
  File ${ADMIN_INS_SOURCE_DIR}psqlodbc35w.dll
  File ${PG_INS_SOURCE_DIR}lib\libpq.dll
  File ${PG_INS_SOURCE_DIR}bin\libintl.dll
  File ${PG_INS_SOURCE_DIR}bin\libeay32.dll
  File ${PG_INS_SOURCE_DIR}bin\ssleay32.dll
  File ${PG_INS_SOURCE_DIR}bin\libiconv.dll
  !ifdef Admin64
	File ${ADMIN_INS_SOURCE_DIR}pgxalib.dll
	SetRegView 64
  !endif
  ;Store installation folder
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" $INSTDIR
  ;Register drivers
  WriteRegStr HKLM "SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers" "PostgreSQL Unicode" "Installed"
  WriteRegStr HKLM "SOFTWARE\ODBC\ODBCINST.INI\PostgreSQL Unicode" "APILevel" "1"
  WriteRegStr HKLM "SOFTWARE\ODBC\ODBCINST.INI\PostgreSQL Unicode" "ConnectFunctions" "YYN"
  WriteRegStr HKLM "SOFTWARE\ODBC\ODBCINST.INI\PostgreSQL Unicode" "Driver" "$INSTDIR\psqlodbc35w.dll"
  WriteRegStr HKLM "SOFTWARE\ODBC\ODBCINST.INI\PostgreSQL Unicode" "DriverODBCVer" "03.51"
  WriteRegStr HKLM "SOFTWARE\ODBC\ODBCINST.INI\PostgreSQL Unicode" "FileUsage" "0"
  WriteRegStr HKLM "SOFTWARE\ODBC\ODBCINST.INI\PostgreSQL Unicode" "Setup" "$INSTDIR\psqlodbc35w.dll"
  WriteRegStr HKLM "SOFTWARE\ODBC\ODBCINST.INI\PostgreSQL Unicode" "SQLLevel" "1"
  WriteRegStr HKLM "SOFTWARE\ODBC\ODBCINST.INI\PostgreSQL Unicode" "UsageCount" "1"
  !ifdef Admin64
	WriteRegStr HKLM "SOFTWARE\Microsoft\MSDTC\XADLL" "pgxalib.dll" "[#pgxalib.dll]"
  !endif
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  ; write uninstall strings
  WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${ADMIN_DEF_BRANDING}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${ADMIN_DEF_BRANDING}" "DisplayName" "$StartMenuFolder"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${ADMIN_DEF_BRANDING}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${ADMIN_DEF_BRANDING}" "DisplayVersion" "${ADMIN_DEF_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${ADMIN_DEF_BRANDING}" "Publisher" "PostgreSQL Global Development Group"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${ADMIN_DEF_BRANDING}" "EstimatedSize" 1024
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${ADMIN_DEF_BRANDING}" "HelpLink" "http://www.postgresql.org/docs"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${ADMIN_DEF_BRANDING}" "Comments" "The PostgreSQL RDBMS, version ${ADMIN_DEF_VERSION}, packaged by PostgresPro.ru"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${ADMIN_DEF_BRANDING}" "UrlInfoAbout" "http://www.postgresql.org/"

SectionEnd
;--------------------------------
;Descriptions

;--------------------------------
;Languages

!insertmacro MUI_LANGUAGE "English" ;first language is the default language
!insertmacro MUI_LANGUAGE "Russian"

!include translates.nsi

;Language strings
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecMS} $(DESC_SecMS)
; !insertmacro MUI_DESCRIPTION_TEXT ${pgAdmin} $(DESC_PgAdmin)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
;--------------------------------
;Uninstaller Section
  section "uninstall"
    RMDir /r "$INSTDIR"
  	Delete "$INSTDIR\Uninstall.exe"
  	rmDir $INSTDIR
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${ADMIN_DEF_BRANDING}"
	DeleteRegKey HKLM "SOFTWARE\ODBC\ODBCINST.INI\PostgreSQL Unicode"
	DeleteRegKey HKLM "SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers\PostgreSQL Unicode" 
  sectionEnd