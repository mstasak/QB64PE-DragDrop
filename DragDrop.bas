'DragDrop.bas
'QB64PE 4.2.0/Windows
'Drag a rectangular area and drop it on a target rectangle, in graphics mode.
'Drag sources could use transparency to present a non-rectangular shape within a transparent border.
'User code is responsible for updating the screen after drops (line 89 below).

Option _Explicit
Dim Shared Scrn As Long

'DragDrop.bi section
Type DragDropSourceStruct
    As Integer x1, x2, y1, y2 ' ,categoryId
    As Long col
End Type

Type DragDragDropTargetStruct
    As Integer x1, x2, y1, y2 ' ,categoryId
End Type

Dim Shared As _Byte DragDropState
Dim Shared As Long DragDropBg, DragDropImage
Dim Shared As Integer DragDropSourceIndex, DragDropMouseX, DragDropMouseY, DragDropImageDX, DragDropImageDY, DragDropTargetIndex
'End DragDrop.bi section

Dim Shared DragDropSources(0 To 8 ^ 3 - 1) As DragDropSourceStruct
Dim Shared DragDropTargets(0 To 4) As DragDragDropTargetStruct

Dim As Integer i, j, k, x, y, tileIndex
Dim As Long col

Scrn = _NewImage(800, 800, 32)
Screen Scrn
$Color:32
Cls , Black

Print "Drag from a colored rectangle below:"

x = 1
y = 15
tileIndex = 0

For i = 0 To 7
    For j = 0 To 7
        For k = 0 To 7
            col = _RGB(i * 32, j * 32, k * 32)
            DragDropSources(tileIndex).x1 = x
            DragDropSources(tileIndex).x2 = x + 31
            DragDropSources(tileIndex).y1 = y
            DragDropSources(tileIndex).y2 = y + 15
            DragDropSources(tileIndex).col = col
            tileIndex = tileIndex + 1
            Line (x, y)-(x + 31, y + 15), col, BF
            x = x + 36
            If x >= 1 + 16 * 36 Then
                x = 1
                y = y + 20
            End If
        Next k
    Next j
Next i

Locate 44, 1
Print "Drop on a box below:"
y = y + 50
x = 100
For i = 0 To 4
    Line (x, y)-(x + 31, y + 31), White, B
    DragDropTargets(i).x1 = x
    DragDropTargets(i).y1 = y
    DragDropTargets(i).x2 = x + 31
    DragDropTargets(i).y2 = y + 31
    x = x + 50
Next i
DragDropInit
Do
    DragDropDoEvents

    Select Case DragDropState
        'Case 0: 'uninitialized   Case 2: 'dragging   Case 3: 'canceled   Case 6: Exit Do 'shut down
        Case 1: 'ready for drag
            _Delay 0.1
        Case 4: 'drop failed
            Beep
            DragDropResume
        Case 5: 'drop succeeded
            Dim target As DragDragDropTargetStruct
            target = DragDropTargets(DragDropTargetIndex)
            'recolor target
            Line (target.x1, target.y1)-(target.x2, target.y2), DragDropSources(DragDropSourceIndex).col, BF
            DragDropResume
    End Select
Loop While InKey$ <> _CHR_ESC
DragDropTerminate

Screen 0
_FreeImage Scrn
System


'Begin DragDrop.bm
'between()% - test if v% is between vMin% and vMax%
Function between% (v%, vMin%, vMax%)
    between% = v% >= vMin% _AndAlso v% <= vMax%
End Function

'set up to perform drags and drops
Sub DragDropInit
    DragDropState = 1
End Sub

'monitor mouse and perform drag operations on screen
Sub DragDropDoEvents
    Dim As _Byte mouseInputReady, lPressed, lReleased
    Dim As Integer mX, mY
    mX = DragDropMouseX
    mY = DragDropMouseY

    Do
        mouseInputReady = _MouseInput
        If mouseInputReady Then
            lPressed = _MouseButton(1)
            mX = _MouseX
            mY = _MouseY
            If DragDropState = 1 _AndAlso lPressed Then
                DragDropBegin mX, mY
            End If
            If DragDropState = 2 _AndAlso Not lPressed Then
                lReleased = _TRUE
                Exit Do
            End If
        End If
    Loop While mouseInputReady
    If DragDropState = 2 _AndAlso lReleased Then
        DragDropEnd mX, mY
        Do 'flush pending mouse events
            mouseInputReady = _MouseInput
        Loop While mouseInputReady
    ElseIf DragDropState = 2 _AndAlso ((mX <> DragDropMouseX) Or (mY <> DragDropMouseY)) Then
        'move drag image
        DragDropImageShow (_FALSE)
        DragDropMouseX = mX
        DragDropMouseY = mY
        DragDropImageShow (_TRUE)
    End If
End Sub

'shut down DragDrop, release resources
Sub DragDropTerminate
    If DragDropState = 2 Then DragDropImageShow _FALSE
    DragDropReleaseImages
    DragDropState = 6
End Sub

'show or hide the image being dragged over the screen, at the mouse cursor
Sub DragDropImageShow (visible%)
    Dim tile As DragDropSourceStruct
    tile = DragDropSources(DragDropSourceIndex)
    If visible% Then
        'save bg from current loc
        _PutImage , Scrn, DragDropBg, (DragDropMouseX + DragDropImageDX, DragDropMouseY + DragDropImageDY)-(DragDropMouseX + DragDropImageDX + tile.x2 - tile.x1, DragDropMouseY + DragDropImageDY + tile.y2 - tile.y1)
        _PutImage (DragDropMouseX + DragDropImageDX, DragDropMouseY + DragDropImageDY), DragDropImage, Scrn
    Else
        _PutImage (DragDropMouseX + DragDropImageDX, DragDropMouseY + DragDropImageDY), DragDropBg, Scrn
    End If
End Sub

'when left button is down, this is called to begin dragging
Sub DragDropBegin (x%, y%)
    Dim As Integer i
    Dim tile As DragDropSourceStruct
    For i = LBound(DragDropSources) To UBound(DragDropSources)
        tile = DragDropSources(i)
        if between(x%, tile.x1,tile.x2) _andalso _
           between(y%, tile.y1,tile.y2) then
            'keep selected object
            DragDropSourceIndex = i
            DragDropMouseX = x%
            DragDropMouseY = y%
            DragDropImageDX = tile.x1 - x% 'offset from mouse point to top left corner of drag source
            DragDropImageDY = tile.y1 - y%
            DragDropReleaseImages 'drop and recreate images based on current drag source size
            'save bg from current loc
            DragDropBg = _NewImage(tile.x2 - tile.x1 + 1, tile.y2 - tile.y1 + 1, 32)
            '_PutImage , Scrn, DragDropBg, (tile.x1, tile.y1)-(tile.x2, tile.y2)
            'set up draggable drop, nodrop images
            DragDropImage = _NewImage(tile.x2 - tile.x1 + 1, tile.y2 - tile.y1 + 1, 32)
            _PutImage , Scrn, DragDropImage, (tile.x1, tile.y1)-(tile.x2, tile.y2)
            'draw drag image
            DragDropImageShow _TRUE
            DragDropState = 2 'dragging
            Exit Sub
        End If
    Next i
End Sub

'called when dragging, after user releases left mouse button
Sub DragDropEnd (x%, y%)
    Dim i As Integer, target As DragDragDropTargetStruct
    'verify valid drop target
    DragDropTargetIndex = -1
    DragDropState = 4 '4 if invalid drop target
    For i = LBound(DragDropTargets) To UBound(DragDropTargets)
        target = DragDropTargets(i)
        If between(x%, target.x1, target.x2) _AndAlso between(y%, target.y1, target.y2) Then
            DragDropState = 5 'valid drop target
            DragDropTargetIndex = i
            Exit For
        End If
    Next i
    DragDropImageShow _FALSE
End Sub

'begin another dragdrop cycle (start waiting for left mouse button press again)
Sub DragDropResume
    DragDropState = 1
End Sub

'free inmage resources
Sub DragDropReleaseImages
    If DragDropImage <> 0 Then
        _FreeImage DragDropImage
        DragDropImage = 0
    End If
    If DragDropBg <> 0 Then
        _FreeImage DragDropBg
        DragDropBg = 0
    End If
End Sub
'End DragDrop.bm

