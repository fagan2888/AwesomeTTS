'Unicode File
'
' This is a modified version by Arthur Helfstein Fragoso, so it can work well with AwesomeTTS for Anki.
'
'great resource of vbs functions: http://ss64.com/vb/
'
'
'    Copyright 2011 Peter Bennett
'
'    This file is part of Jampal.
'
'    Jampal is free software: you can redistribute it and/or modIfy
'    it under the terms of the GNU General Public License as published by
'    the Free Software Foundation, either version 3 of the License, or
'    (at your option) any later version.
'
'    Jampal is distributed in the hope that it will be useful,
'    but WITHOUT ANY WARRANTY without even the implied warranty of
'    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'    GNU General Public License for more details.
'
'    You should have received a copy of the GNU General Public License
'    along with Jampal.  If not, see <http://www.gnu.org/licenses/>.

doWaveFile = False
doMultWaveFiles = False
pFileName = Null            ' Name of output wav file
pUnicodeFileName = Null     ' name of input text file
rate=-999
volume=-999
samples=44100
channels=2
pVoice=Null
pEncoding = Null
needFileName = False
needRate = False
needVolume = False
needWord = False
needPron = False
needUnicodeFileName = False
needSamples = False
needChannels = False
needVoice = False
needEncoding = False
doSetVoice = False
doInstruct = False
doLexiconAdd = False
doListVoices = False
doDecodeHexUnicode = False
isCscript = True        ' Identifies if we are running CScript
needDebugging = False

pVoice=Null
needVoice = False


dim tts
set tts = createobject("sapi.spvoice")


Dim argv
Set argv = WScript.Arguments




For Each arg in argv
    If needVoice Then
        pVoice=arg
        needVoice = False
	doSetVoice = True
    ElseIf needFileName Then
        pFileName=arg
        needFileName = False
    ElseIf arg = "-voice" Then
        needVoice = True
    ElseIf arg = "-vl" Then
        doListVoices = True
    ElseIf arg = "-o" Then
        doWaveFile = True
        needFileName = True
    ElseIf arg = "-hex" Then
        doDecodeHexUnicode = True
    Else
        texttospeak = texttospeak  & " " & arg
    End If
Next


if doListVoices then
    Set voiceList = tts.getVoices
    list = "--Voice List--"
    For Each strVoice in voiceList
        list = list & vbLf
        list = list & strVoice.GetAttribute("Name")
    Next
    printOut(list)
    WScript.Quit (0)
End if


if doDecodeHexUnicode Then
    texttospeak = HexToUnicode(Trim(texttospeak))
    pVoice = HexToUnicode(Trim(pVoice))
End If

if doSetVoice Then
    setVoice tts,pVoice
End If



if Not IsNull(pFileName) Then
    If Len(pFileName) > 4 _
        And LCase(Mid(pFileName,Len(pFilename) -3)) = ".wav" Then
        pFileName = Mid(pFileName,1,Len(pFilename) -4)
    End If
    pFileName = pFileName & ".wav"

    Set outputFile = CreateObject("SAPI.SpFileStream")
    Set format = outputFile.format
    format.Type = getWaveType(samples,channels)
    Set outputFile.Format = format
    outputFile.Open pFileName, 3
    Set tts.AudioOutputStream = outputFile
End If


tts.speak texttospeak


Function getWaveType(samples, channels)
    getWaveType = 34
    If samples =  8000 Then 
        getWaveType = 6
    ElseIf samples = 16000 Then 
        getWaveType = 18
    ElseIf samples = 22050 Then 
        getWaveType = 22
    ElseIf samples = 44100 Then 
        getWaveType = 34
    ElseIf samples = 48000 Then 
        getWaveType = 38
    Else
        printErr("Invalid samples "&samples)
    End If
    If channels = 1 Then
    ElseIf channels = 2 Then
        getWaveType = getWaveType + 1
    Else
        printErr("Invalid channel number "&channels)
    End If
End Function


Function setVoice(hSpeaker, voice)
    Set list = hSpeaker.GetVoices("Name="&voice)
    If list.Count <> 1 Then
        printOut("ERROR "&list.Count&" voices match "&voice)
        setVoice = False
        Exit Function
    End If
    Set hSpeaker.Voice = list.Item(0)
    setVoice = True
End Function


Sub printOut (text)
    if isCscript Then
	WScript.StdOut.Write text
    Else
        WScript.Echo text
    End If
End Sub


Function StringToHex(ByRef pstrString)
	Dim llngIndex
	Dim llngMaxIndex
	Dim lstrHex
	llngMaxIndex = Len(pstrString)
	For llngIndex = 1 To llngMaxIndex
		lstrHex = lstrHex & Right( Hex(AscW(Mid(pstrString, llngIndex, 1))), 2)
		'lstrHex = lstrHex & "%" & Hex(AscW(Mid(pstrString, llngIndex, 1)))
		'printOut Hex(AscW(Mid(pstrString, llngIndex, 1)))
	Next
	StringToHex = lstrHex
End Function


Function HexToUnicode(ByRef pstrHex)
	Dim llngIndex
	Dim llngMaxIndex
	Dim lstrString
	llngMaxIndex = Len(pstrHex)
	For llngIndex = 1 To llngMaxIndex Step 4
		lstrString = lstrString & ChrW("&h" & Mid(pstrHex, llngIndex, 4))
		'printOut "&h" & Mid(pstrHex, llngIndex, 4)
	Next
	HexToUnicode = lstrString
End Function
