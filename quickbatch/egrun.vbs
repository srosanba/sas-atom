Option Explicit ' Forces us to declare all variables


'
'  Program:       egrun.vbs
'
'  Author:        John Leveille, d-Wise
'
'  Date:          14Apr2015
'
'  Purpose:       This script automates SAS Enterprise Guide to perform a batch submit
'                 to the SAS Grid.  It also changes to the proper directory before
'                 invoking the user code, and it retrieves the log and lst file
'                 after the program completes.
'
'  Derived from:  Chris Hemedinger, Blog: The SAS Dummy
'                 http://blogs.sas.com/content/sasdummy/2011/05/03/using-sas-enterprise-guide-to-run-programs-in-batch/
'

Dim app         ' application
Dim project     ' Project object
Dim sasProgram  ' Code object (SAS program)
Dim n           ' counter
Dim objFSO
Dim objFile
Dim programFolder
Dim baseName
Dim fileExt
Dim textStream
Dim sasLogFile
Dim sasLstFile

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.GetFile(WScript.Arguments(2))
programFolder = objFSO.GetParentFolderName(objFSO.GetAbsolutePathName(WScript.Arguments(2)))
baseName = objFSO.GetBaseName(objFile)
fileExt = objFSO.GetExtensionName(objFile)

'determine full paths to log and list files
sasLogfile = programFolder & "\" & baseName & ".log"
sasLstFile = programFolder & "\" & baseName & ".lst"

' Crank up SAS Enterprise Guide in the background
Set app = CreateObject("SASEGObjectModel.Application.7.1")

' Set to your metadata profile name, or "Null Provider" for just Local server
WScript.Echo("Connecting to the SAS metadata server...")
wScript.Echo("Connection profile: " & WScript.Arguments(0))
app.SetActiveProfile(WScript.Arguments(0))
Wscript.Echo("Connected.")
WScript.Echo(vbCrLf) 

' Create a new project
Set project = app.New 
' add a new code object to the project
Set sasProgram = project.CodeCollection.Add
 
' set the results types, overriding app defaults
sasProgram.UseApplicationOptions = False
sasProgram.GenListing = True
sasProgram.GenSasReport = False

 
' Set the server (by Name) and text for the code
sasProgram.Server = WScript.Arguments(1)

sasProgram.Text = sasProgram.Text & vbCrLf & "options nosource;"
sasProgram.Text = sasProgram.Text & vbCrLf & "%let rgv_currfile = " & baseName & "." & fileExt & ";"
sasProgram.Text = sasProgram.Text & vbCrLf & "%let rgv_currfolder = " & programFolder & ";"
sasProgram.Text = sasProgram.Text & vbCrLf & "%put ;"
sasProgram.Text = sasProgram.Text & vbCrLf & "%put NOTE: Executing    &SYSPROCESSNAME;"
sasProgram.Text = sasProgram.Text & vbCrLf & "%put NOTE: Executed at  %sysfunc(time(),time.) %sysfunc(date(),weekdate.);"
sasProgram.Text = sasProgram.Text & vbCrLf & "%put NOTE: Executed by  &SYSUSERID;"
sasProgram.Text = sasProgram.Text & vbCrLf & "%put NOTE: Running SAS  &SYSVLONG under &SYSSCPL;"
sasProgram.Text = sasProgram.Text & vbCrLf & "%put NOTE: Running program: &rgv_currfolder.\&rgv_currfile;"
sasProgram.Text = sasProgram.Text & vbCrLf & "%put ;"
sasProgram.Text = sasProgram.Text & vbCrLf & "options source;"


'Arguments to OpenAsTextStream 1='For Reading'  and 2='Use Default File Fromat'
Set textStream = objFile.OpenAsTextStream(1, -2)
Do While textStream.AtEndOfStream <> True
    sasProgram.Text = sasProgram.Text & vbCrLf & textStream.ReadLine
Loop
textStream.Close

WScript.Echo("Preparing to submit this program...")
WScript.Echo(programFolder & "\" & baseName & "." & fileExt)
'Wscript.Echo(sasProgram.Text)

WScript.Echo(vbCrLf) 
WScript.Echo(">>>> Submitting to the grid.  Please wait while the program runs...")
' Run the code
sasProgram.Run

WScript.Echo("SAS program complete.")


WScript.Echo("Saving the log and list files...")
' Save the log file to LOCAL disk
sasProgram.Log.SaveAs sasLogFile
WScript.Echo("SAS Log: " & sasLogFile) 
 
' Filter through the results and save just the LISTING type
For n=0 to (sasProgram.Results.Count -1)
' Listing type is 7
If sasProgram.Results.Item(n).Type = 7 Then
   ' Save the listing file to LOCAL disk
   sasProgram.Results.Item(n).SaveAs sasLstFile
   WScript.Echo("SAS Listing: " & sasLstFile)
   WScript.Echo(vbCrLf) 
End If
Next

WScript.Echo("Done saving log and lst.  Batch run complete.")

app.Quit