<#
.DESCRIPTION 
Downloads and starts the interactive installer for the latest build of AdobeDC
.AUTHOR
https://github.com/japocock/
.NOTES
Use verbose output for detailed information.
#>
function Install-AdobeReaderDC
{  
	[cmdletbinding()]
	param()

	function New-TemporaryDirectory{
		$tempDirectoryBase = [System.IO.Path]::GetTempPath();
		$newTempDirPath = [String]::Empty;
		Do {
			[string] $name = [System.Guid]::NewGuid();
			$newTempDirPath = (Join-Path $tempDirectoryBase $name);
		} While (Test-Path $newTempDirPath);

		$create=New-Item -ItemType Directory -Path $newTempDirPath;
		return $create.FullName
	}


	$DownloadFolder = New-TemporaryDirectory
	Write-Verbose "Download folder: $DownloadFolder" 
	$FTPFolderUrl = "ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/"
	Write-Verbose "Adobe URL: $FTPFolderUrl" 
	#Connect to Adobe FTP site and get directory listing
	$FTPRequest = [System.Net.FtpWebRequest]::Create("$FTPFolderUrl") 
	$FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
	$FTPResponse = $FTPRequest.GetResponse()
	$ResponseStream = $FTPResponse.GetResponseStream()
	$FTPReader = New-Object System.IO.Streamreader -ArgumentList $ResponseStream
	$DirList = $FTPReader.ReadToEnd()
	Write-Verbose "Directory list: $DirList"     	

    #From Directory Listing get last entry.
	$LatestUpdate = $DirList -split '[\r\n]' | Where {$_} | Select -Last 1 -Skip 1
	Write-Verbose "Parsed latest build: $LatestUpdate"

	#build file name
	$LatestBuild = "AcroRdrDC" + $LatestUpdate + "_en_US.exe"
	Write-Verbose "Parsed latest filename: $LatestBuild"

	#URI for latest file
	$DownloadURL = "$FTPFolderUrl$LatestUpdate/$LatestBuild"
	Write-Verbose "Parsed download URL: $DownloadURL"

	#Download Folder
	$destination = "$DownloadFolder\adobeDC.exe"
	Write-Verbose "Download folder: $destination "

	#Perform the download
	Write-Verbose "Downloading..."
    Invoke-WebRequest -Uri $DownloadURL -OutFile $destination

    Write-Verbose "Running installer..."
    & "$destination"
}




