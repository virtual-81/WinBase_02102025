# PowerShell скрипт для создания правильных .dproj файлов для Delphi 12

param(
  [string]$ProjectPath = "."
)

function Create-ModernDproj {
  param(
    [string]$ProjectName,
    [string]$ProjectGuid,
    [string]$OutputPath
  )
    
  $dproj = @"
<?xml version="1.0" encoding="utf-8"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <ProjectGuid>$ProjectGuid</ProjectGuid>
    <MainSource>$ProjectName.dpr</MainSource>
    <Base>True</Base>
    <Config Condition="'`$(Config)'==''">Debug</Config>
    <TargetedPlatforms>1</TargetedPlatforms>
    <AppType>Application</AppType>
    <FrameworkType>VCL</FrameworkType>
    <ProjectVersion>19.5</ProjectVersion>
    <Platform Condition="'`$(Platform)'==''">Win32</Platform>
  </PropertyGroup>
  
  <PropertyGroup Condition="'`$(Config)'=='Base' or '`$(Base)'!=''">
    <Base>true</Base>
  </PropertyGroup>
  
  <PropertyGroup Condition="('`$(Platform)'=='Win32' and '`$(Base)'=='true') or '`$(Base_Win32)'!=''">
    <Base_Win32>true</Base_Win32>
    <CfgParent>Base</CfgParent>
    <Base>true</Base>
  </PropertyGroup>
  
  <PropertyGroup Condition="'`$(Config)'=='Debug' or '`$(Cfg_2)'!=''">
    <Cfg_2>true</Cfg_2>
    <CfgParent>Base</CfgParent>
    <Base>true</Base>
  </PropertyGroup>
  
  <PropertyGroup Condition="'`$(Base)'!=''">
    <SanitizedProjectName>$ProjectName</SanitizedProjectName>
    <DCC_Namespace>System;Xml;Data;Datasnap;Web;Soap;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell;`$(DCC_Namespace)</DCC_Namespace>
    <DCC_DCCCompiler>DCC32</DCC_DCCCompiler>
    <DCC_DependencyCheckOutputName>$ProjectName.exe</DCC_DependencyCheckOutputName>
    <DCC_ImageBase>00400000</DCC_ImageBase>
    <DCC_UnitAlias>WinTypes=Windows;WinProcs=Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE;`$(DCC_UnitAlias)</DCC_UnitAlias>
    <DCC_Platform>x86</DCC_Platform>
    <DCC_K>false</DCC_K>
    <DCC_N>false</DCC_N>
    <DCC_S>false</DCC_S>
    <DCC_F>false</DCC_F>
    <DCC_E>false</DCC_E>
  </PropertyGroup>
  
  <PropertyGroup Condition="'`$(Cfg_2)'!=''">
    <DCC_Define>DEBUG;`$(DCC_Define)</DCC_Define>
    <DCC_Optimize>false</DCC_Optimize>
    <DCC_GenerateStackFrames>true</DCC_GenerateStackFrames>
  </PropertyGroup>
  
  <ItemGroup>
    <DelphiCompile Include="`$(MainSource)">
      <MainSource>MainSource</MainSource>
    </DelphiCompile>
    <BuildConfiguration Include="Base">
      <Key>Base</Key>
    </BuildConfiguration>
    <BuildConfiguration Include="Debug">
      <Key>Cfg_2</Key>
      <CfgParent>Base</CfgParent>
    </BuildConfiguration>
  </ItemGroup>
  
  <ProjectExtensions>
    <Borland.Personality>Delphi.Personality.12</Borland.Personality>
    <Borland.ProjectType>VCLApplication</Borland.ProjectType>
    <BorlandProject>
      <Delphi.Personality>
        <Source>
          <Source Name="MainSource">$ProjectName.dpr</Source>
        </Source>
        <VersionInfo>
          <VersionInfo Name="IncludeVerInfo">False</VersionInfo>
          <VersionInfo Name="AutoIncBuild">False</VersionInfo>
          <VersionInfo Name="MajorVer">1</VersionInfo>
          <VersionInfo Name="MinorVer">0</VersionInfo>
          <VersionInfo Name="Release">0</VersionInfo>
          <VersionInfo Name="Build">0</VersionInfo>
          <VersionInfo Name="Debug">False</VersionInfo>
          <VersionInfo Name="PreRelease">False</VersionInfo>
          <VersionInfo Name="Special">False</VersionInfo>
          <VersionInfo Name="Private">False</VersionInfo>
          <VersionInfo Name="DLL">False</VersionInfo>
          <VersionInfo Name="Locale">1049</VersionInfo>
          <VersionInfo Name="CodePage">1251</VersionInfo>
        </VersionInfo>
        <VersionInfoKeys>
          <VersionInfoKeys Name="CompanyName"></VersionInfoKeys>
          <VersionInfoKeys Name="FileDescription">$ProjectName</VersionInfoKeys>
          <VersionInfoKeys Name="FileVersion">1.0.0.0</VersionInfoKeys>
          <VersionInfoKeys Name="InternalName">$ProjectName</VersionInfoKeys>
          <VersionInfoKeys Name="LegalCopyright"></VersionInfoKeys>
          <VersionInfoKeys Name="LegalTrademarks"></VersionInfoKeys>
          <VersionInfoKeys Name="OriginalFilename">$ProjectName.exe</VersionInfoKeys>
          <VersionInfoKeys Name="ProductName">$ProjectName</VersionInfoKeys>
          <VersionInfoKeys Name="ProductVersion">1.0.0.0</VersionInfoKeys>
          <VersionInfoKeys Name="Comments"></VersionInfoKeys>
        </VersionInfoKeys>
      </Delphi.Personality>
      <Platforms>
        <Platform value="Win32">True</Platform>
      </Platforms>
    </BorlandProject>
    <ProjectFileVersion>12</ProjectFileVersion>
  </ProjectExtensions>
  
  <Import Project="`$(BDS)\Bin\CodeGear.Delphi.Targets" Condition="Exists('`$(BDS)\Bin\CodeGear.Delphi.Targets')"/>
</Project>
"@

  Set-Content -Path $OutputPath -Value $dproj -Encoding UTF8
  Write-Host "Создан: $OutputPath" -ForegroundColor Green
}

# Проекты для конвертации с их GUID'ами
$projects = @{
  "wbase"   = "{FD7DA613-1E37-461E-A44A-5553F19FCEEB}"
  "wbdstat" = "{73D30CE2-DA83-4EA5-A7EA-BD98B73D3CB5}"
}

$subprojects = @{
  "ascor\ascor"           = "{1210C114-10C7-4607-9121-25D64AFA2271}"
  "wbd2ftp\wbd2ftp"       = "{102FCA71-2F5D-4295-9CD0-56F7F530AF2A}"
  "wbd2csv\wbd2csv"       = "{A1B2C3D4-E5F6-7890-ABCD-1234567890AB}"
  "wbasetosql\wbasetosql" = "{B2C3D4E5-F6G7-8901-BCDE-2345678901BC}"
  "wbdview\wbdview"       = "{C3D4E5F6-G7H8-9012-CDEF-3456789012CD}"
}

Write-Host "Создание современных .dproj файлов для Delphi 12..." -ForegroundColor Cyan

# Создание основных проектов
foreach ($project in $projects.Keys) {
  $outputPath = Join-Path $ProjectPath "$project.dproj"
  if (Test-Path "$ProjectPath\$project.dpr") {
    Create-ModernDproj -ProjectName $project -ProjectGuid $projects[$project] -OutputPath $outputPath
  }
  else {
    Write-Host "Пропущен $project - файл .dpr не найден" -ForegroundColor Yellow
  }
}

# Создание подпроектов
foreach ($subproject in $subprojects.Keys) {
  $projectName = Split-Path $subproject -Leaf
  $outputPath = Join-Path $ProjectPath "$subproject.dproj"
  if (Test-Path "$ProjectPath\$subproject.dpr") {
    Create-ModernDproj -ProjectName $projectName -ProjectGuid $subprojects[$subproject] -OutputPath $outputPath
  }
  else {
    Write-Host "Пропущен $subproject - файл .dpr не найден" -ForegroundColor Yellow
  }
}

Write-Host "`nГотово! Все .dproj файлы созданы в современном формате." -ForegroundColor Green
Write-Host "Теперь можно открывать проекты в Delphi 12." -ForegroundColor Green
