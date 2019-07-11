function Get-SpecialFolderPath {
    <#
    .SYNOPSIS
        Retrieves the path of one of the "special" folders and returns it
    .DESCRIPTION
        Reads the environment for the special folders like 'Desktop'm 'Documents', etc. and returns the path as a string
    .EXAMPLE
        PS C:\> Get-SpecialFolder -FolderPath CommonDesktopDirectory
        C:\Users\Public\Desktop
    .INPUTS
        [string]
        [environment+specialfolder]
    .OUTPUTS
        [string]
    .NOTES
        It utilizes the [System.Environment+SpecialFolder] enum to select the correct folder names
        AdminTools	            CommonVideos	        Personal
        ApplicationData	        Cookies	                PrinterShortcuts
        CDBurning	            Desktop	                ProgramFiles
        CommonAdminTools	    DesktopDirectory	    ProgramFilesX86
        CommonApplicationData	Favorites	            Programs
        CommonDesktopDirectory	Fonts	                Recent
        CommonDocuments	        History	                Resources
        CommonMusic	            InternetCache	        SendTo
        CommonOemLinks	        LocalApplicationData	StartMenu
        CommonPictures	        LocalizedResources	    Startup
        CommonProgramFiles	    MyComputer	            System
        CommonProgramFilesX86	MyDocuments	            SystemX86
        CommonPrograms	        MyMusic	                Templates
        CommonStartMenu	        MyPictures	            UserProfile
        CommonStartup	        MyVideos	            Windows
        CommonTemplates	        NetworkShortcuts

    #>
    [cmdletbinding()]
    param(
        [System.Environment+SpecialFolder]$FolderPath
    )
    [System.Environment]::GetFolderPath($FolderPath)
}
