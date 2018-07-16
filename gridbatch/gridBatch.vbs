Option Explicit ' Forces us to declare all variables

'-------------------------------------------------------------------------------
'
'  Program:  gridBatch.vbs
'
'  Purpose:  Submit a SAS job to the grid in Batch
'
'  Details:  Called by gridBatch94.bat (or similar) with the following arguments:
'              0 - EG profile name
'              1 - EG server
'              2 - SAS program file
'              3 - optionally, the keyword WAIT
'
'            Starts SAS EG and calls %gridBatch(SAS program file) which submits
'            the program to the SASGSUB utility.
'
'            It is necessary to start EG because SASGSUB is available from the
'            users EG profile, but is not installed locally on users machines.
'            Therefore, EG is used only as a tool to get to SASGSUB.
'
'            The log from the EG session is saved as H:\gridBatch.log.
'            It is overwritten and reflects the users last submission of this script.
'
'  Requirements:
'
'            The File:      I:\SAS94GridConfig\Lev1\SASAppPGRD94\sasv9.cfg
'            Must contain:  -insert set sasautos "\\drive_i\RHO_APPS\SAS Grid\GridBatch\PROD"
'            And:           gridBatch.sas must reside in that directory
'
'
'  History:  23Jun2016  John Ingersoll
'            07Jul2016  Kevin Hunter      move to VAL
'
'
'  Derived from:  Chris Hemedinger, Blog: The SAS Dummy
'  http://blogs.sas.com/content/sasdummy/2011/05/03/using-sas-enterprise-guide-to-run-programs-in-batch/
'
'-------------------------------------------------------------------------------

Dim app         ' application
Dim project     ' Project object
Dim sasProgram  ' Code object (SAS program)
Dim objArgs     ' passed arguments


WScript.Echo("Connecting to the SAS Grid server " & WScript.Arguments(1) & ", profile " & WScript.Arguments(0))

Set objArgs = WScript.Arguments

' SAS Enterprise Guide in the background
Set app = CreateObject("SASEGObjectModel.Application.7.1")

' Set to the metadata profile name, passed as arg to this script
app.SetActiveProfile(WScript.Arguments(0))

Wscript.Echo("Connected.") 

' Create a new project
Set project = app.New 

' Add a new code object to the project
Set sasProgram = project.CodeCollection.Add
 
' Set the results types, overriding app defaults
sasProgram.UseApplicationOptions = False
sasProgram.GenListing = True
sasProgram.GenSasReport = False

' Set the server, passed as arg to this script
sasProgram.Server = WScript.Arguments(1)


' Create call to %gridBatch macro to be submitted
sasProgram.Text = "%gridBatch(" & WScript.Arguments(2) & ",debug=yes"

' Add WAIT parameter
If objArgs.Count > 3 Then
   If StrComp(WScript,"wait",vbTextCompare) Then sasProgram.Text = sasProgram.Text & ",wait=yes"
End If

' Add closing parenthesis
sasProgram.Text = sasProgram.Text & ")"


' Run the code
WScript.Echo("Submitting " & sasProgram.Text & " ...")
sasProgram.Run
WScript.Echo("Submitted." )


' Save the EG log file to users H: disk
sasProgram.Log.SaveAs "H:\gridBatch.log"

app.Quit