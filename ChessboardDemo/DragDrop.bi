'DragDrop.bi
'QB64PE 4.2.0/Windows
'Drag a rectangular area and drop it on a target rectangle, in graphics mode.
'Variable and method declarations for $INCLUDE usage.

Type DragDropSourceStruct
    As Integer x1, x2, y1, y2 ' ,categoryId
    'As Long col
	as integer row, col
End Type

Type DragDropTargetStruct
    As Integer x1, x2, y1, y2 ' ,categoryId
	as integer row, col
End Type

Dim Shared As _Byte DragDropState
Dim Shared As Long Scrn, DragDropBg, DragDropImage
Dim Shared As Integer DragDropSourceIndex, DragDropMouseX, DragDropMouseY, DragDropImageDX, DragDropImageDY, DragDropTargetIndex

'in your main program
'Dim Shared DragDropSources(0 To numberofsources-1) As DragDropSourceStruct
'Dim Shared DragDropTargets(0 To numberoftargets-1) As DragDragDropTargetStruct

