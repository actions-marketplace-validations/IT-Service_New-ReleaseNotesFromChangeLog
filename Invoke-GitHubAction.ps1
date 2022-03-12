#!/usr/bin/env pwsh
Import-Module $PSScriptRoot/lib/GitHubActionsCore;

try
{

	$params = @{ };

	$verboseParam = ( Get-ActionInput -Name 'verbose' );
	if ( -not ( $verboseParam -and ( $verboseParam -ne 'true' ) ) )
	{
		$params.Add( 'Verbose', $true );
		$VerbosePreference = [System.Management.Automation.ActionPreference]::Continue;
	};
	$WarningPreference = [System.Management.Automation.ActionPreference]::Continue;

	$versionParam = ( Get-ActionInput -Name 'version' );
	if ( $versionParam -and ( $versionParam -ne 'latest' ) )
	{
		$LatestVersion = $false;
		$Version = $versionParam;
		Write-Verbose "Version $Version";
	}
	else
	{
		$LatestVersion = $true;
		Write-ActionWarning 'Version does not specified. Used latest version info from change log.';
	};

	$ReleaseNotesRelativePath = ( Get-ActionInput -Name 'release-notes-path' );
	if ( -not $ReleaseNotesRelativePath )
	{
		$ReleaseNotesRelativePath = 'RELEASENOTES.md';
	};
	Write-Verbose "Release notes relative path: $ReleaseNotesRelativePath";

	$ChangeLogRelativePath = ( Get-ActionInput -Name 'change-log-path' );
	if ( -not $ChangeLogRelativePath )
	{
		$ChangeLogRelativePath = 'CHANGELOG.md';
	};
	Write-Verbose "Changelog relative path: $ChangeLogRelativePath";

	$ChangeLog = ( Get-Content -Path ChangeLogRelativePath -Encoding UTF8 );
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
	$releaseNotes | Out-File -Encoding utf8 -FilePath $releaseNotesPath -NoNewLine;
	Write-Verbose "Release notes stored in $releaseNotesPath";
	Set-ActionOutput -Name 'release-notes-path' -Value $releaseNotesPath;

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
