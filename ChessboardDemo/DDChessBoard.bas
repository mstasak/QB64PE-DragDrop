'DragDrop.bas
'QB64PE 4.2.0/Windows
'Drag a rectangular area and drop it on a target rectangle, in graphics mode.
'Drag sources could use transparency to present a non-rectangular shape within a transparent border.
'User code is responsible for updating the screen after drops (line 89 below).

Option _Explicit

'$Include: 'DragDrop.bi'

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


'$Include: 'DragDrop.bm'
