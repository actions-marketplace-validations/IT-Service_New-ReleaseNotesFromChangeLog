# Copyright © 2022 Sergei S. Betke

<#
	.SYNOPSIS
		Create ReleaseNotes.md from ChangeLog.md
#>

[CmdletBinding()]

Param(

	# Relative path to ChangeLog.md file
	[Parameter( Mandatory = $False, Position = 0 )]
	[Alias( 'ChangeLogPath' )]
	[System.String]
	$Path = 'CHANGELOG.md',

	# Relative path to ReleaseNotes.md file
	[Parameter( Mandatory = $False, Position = 1 )]
	[Alias( 'ReleaseNotesPath' )]
	[System.String]
	$Destination = 'RELEASENOTES.md',

	# Project version, for which ReleaseNotes.md must be generated
	[Parameter( Mandatory = $False )]
	[System.String]
	$Version

)

Import-Module $PSScriptRoot/lib/GitHubActionsCore;

try
{
	if ( $Version -ne 'latest' )
	{
		$LatestVersion = $false;
		Write-Verbose "Version $Version";
	}
	else
	{
		$LatestVersion = $true;
		Write-ActionWarning 'Version does not specified. Used latest version info from change log.';
	};

	$ReleaseNotesRelativePath = $Destination;
	Write-Verbose "Release notes relative path: $ReleaseNotesRelativePath";
	$ChangeLogRelativePath = $Path;
	Write-Verbose "Changelog relative path: $ChangeLogRelativePath";

	$ChangeLog = ( Get-Content -Path $ChangeLogRelativePath -Encoding UTF8 );
	$isExpectedSection = $false;
	$isFirstVersionSection = $true;
	$processedVersion = '';
	$releaseNotes = @( $ChangeLog | ForEach-Object {
			$isReleaseSectionHeader = ( $_ -match '##\s+(?:(?<version>\d+\.\d+\.\d+)|\[(?<version>\d+\.\d+\.\d+)\])' );
			if ( $isReleaseSectionHeader )
			{
				$releaseVersion = $Matches[ 'version' ];
				if ( $LatestVersion )
				{
					$isExpectedSection = $isFirstVersionSection;
					$isFirstVersionSection = $false;
				}
				else
				{
					$isExpectedSection = ( $releaseVersion -eq $Version );
				};
				if ( $isExpectedSection )
				{
					$processedVersion = $releaseVersion;
				};
			}
			else
			{
				if ( $isExpectedSection )
				{
					return $_;
				};
			};
		}
	) -join "`r`n";
	$releaseNotes | Out-File -Encoding utf8 -FilePath $ReleaseNotesRelativePath -NoNewLine;
	if ( [System.String]::IsNullOrEmpty( $releaseNotes ) )
	{
		Write-ActionWarning `
			-Message "Change log does not cotains release notes section for specified version." `
			-File $ChangeLogRelativePath;
	};
	Write-Verbose "Release notes stored in $ReleaseNotesRelativePath";
	Set-ActionOutput -Name 'release-notes-path' -Value $ReleaseNotesRelativePath;

	Write-Verbose "Actual project version: $processedVersion";
	Set-ActionOutput -Name 'actual-version' -Value $processedVersion;
}
catch
{
	Set-ActionOutput 'error' $_.ToString();
	$ErrorView = 'NormalView';
	Set-ActionFailed ($_ | Out-String);
}
exit [System.Environment]::ExitCode;
