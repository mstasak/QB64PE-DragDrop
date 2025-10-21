'DragDrop.bas
'QB64PE 4.2.0/Windows
'Drag a rectangular area and drop it on a target rectangle, in graphics mode.
'Drag sources could use transparency to present a non-rectangular shape within a transparent border.
'User code is responsible for updating the screen after drops (line 89 below).

Option _Explicit

'$Include: 'DragDrop.bi'

Dim Shared DragDropSources(0 To 63) As DragDropSourceStruct
Dim Shared DragDropTargets(0 To 63) As DragDropTargetStruct


Const BlackPawn = -1, BlackKnight = -2, BlackBishop = -3, BlackRook = -4, BlackQueen = -5, BlackKing = -6
Const EmptySquare = 0
Const WhitePawn = 1, WhiteKnight = 2, WhiteBishop = 3, WhiteRook = 4, WhiteQueen = 5, WhiteKing = 6

Dim piecenames(EmptySquare To WhiteKing) As String
piecenames(0) = "Empty Square"
piecenames(1) = "Pawn"
piecenames(2) = "Knight"
piecenames(3) = "Bishop"
piecenames(4) = "Rook"
piecenames(5) = "Queen"
piecenames(6) = "King"

Dim As Integer i, j
'Dim As Long col

Dim Shared squares(0 To 7, 0 To 7) As _Byte
For i = 0 To 7
    squares(1, i) = BlackPawn
    squares(6, i) = WhitePawn
Next i
squares(0, 0) = BlackRook
squares(0, 1) = BlackKnight
squares(0, 2) = BlackBishop
squares(0, 3) = BlackQueen
squares(0, 4) = BlackKing
squares(0, 5) = BlackBishop
squares(0, 6) = BlackKnight
squares(0, 7) = BlackRook
squares(7, 0) = WhiteRook
squares(7, 1) = WhiteKnight
squares(7, 2) = WhiteBishop
squares(7, 3) = WhiteQueen
squares(7, 4) = WhiteKing
squares(7, 5) = WhiteBishop
squares(7, 6) = WhiteKnight
squares(7, 7) = WhiteRook



Dim PieceFilenames(BlackKing To WhiteKing) As String
PieceFilenames(BlackKing) = "Chess_kdt45.svg"
PieceFilenames(BlackQueen) = "Chess_qdt45.svg"
PieceFilenames(BlackRook) = "Chess_rdt45.svg"
PieceFilenames(BlackBishop) = "Chess_bdt45.svg"
PieceFilenames(BlackKnight) = "Chess_ndt45.svg"
PieceFilenames(BlackPawn) = "Chess_pdt45.svg"
PieceFilenames(EmptySquare) = ""
'PieceNames(0, 6) = "Chess_wemptysq.svg"

PieceFilenames(WhitePawn) = "Chess_plt45.svg"
PieceFilenames(WhiteKnight) = "Chess_nlt45.svg"
PieceFilenames(WhiteBishop) = "Chess_blt45.svg"
PieceFilenames(WhiteRook) = "Chess_rlt45.svg"
PieceFilenames(WhiteQueen) = "Chess_qlt45.svg"
PieceFilenames(WhiteKing) = "Chess_klt45.svg"
'PieceNames(1, 6) = "Chess_bemptysq.svg"

Scrn = _NewImage(800, 800, 32)
Screen Scrn
$Color:32
Cls , Black

Dim Shared pieceImages(BlackKing To WhiteKing) As Long
For i = BlackKing To WhiteKing
    If i <> EmptySquare Then pieceImages(i) = _LoadImage(PieceFilenames(i), 32)
Next i

Line (1, 31)-(700, 730), Beaver, BF
For i = 0 To 7
    For j = 0 To 7
        drawSquare j, i
        If squares(i, j) <> EmptySquare Then
            drawPiece j, i
        End If
        '_PutImage (31 + x * 80, 61 + y * 80)-(31 + x * 80 + 79, 61 + y * 80 + 79), pieceImages(piece), Scrn
        DragDropSources(i * 8 + j).x1 = 31 + j * 80
        DragDropSources(i * 8 + j).x2 = 31 + j * 80 + 79
        DragDropSources(i * 8 + j).y1 = 61 + i * 80
        DragDropSources(i * 8 + j).y2 = 61 + i * 80 + 79
        DragDropSources(i * 8 + j).row = i
        DragDropSources(i * 8 + j).col = j
        DragDropTargets(i * 8 + j).x1 = 31 + j * 80
        DragDropTargets(i * 8 + j).x2 = 31 + j * 80 + 79
        DragDropTargets(i * 8 + j).y1 = 61 + i * 80
        DragDropTargets(i * 8 + j).y2 = 61 + i * 80 + 79
        DragDropTargets(i * 8 + j).row = i
        DragDropTargets(i * 8 + j).col = j
    Next j
Next i


_Title "Drag and Drop Chessboard"
'Print "Drag from a colored rectangle below:"

DragDropInit
Do
    DragDropDoEvents

    Select Case DragDropState
        '        'Case 0: 'uninitialized   Case 2: 'dragging   Case 3: 'canceled   Case 6: Exit Do 'shut down
        Case 1: 'ready for drag
            _Delay 0.1
        Case 4: 'drop failed
            Beep
            DragDropResume
        Case 5: 'drop succeeded
            'src = DragDropSources(DragDropSourceIndex)
            'tgt = DragDropTargets(DragDropTargetIndex)
            squares(DragDropTargetIndex \ 8, DragDropTargetIndex Mod 8) = squares(DragDropSourceIndex \ 8, DragDropSourceIndex Mod 8)
            If DragDropSourceIndex <> DragDropTargetIndex Then squares(DragDropSourceIndex \ 8, DragDropSourceIndex Mod 8) = EmptySquare
            drawSquare DragDropSourceIndex Mod 8, DragDropSourceIndex \ 8
            drawSquare DragDropTargetIndex Mod 8, DragDropTargetIndex \ 8
            drawPiece DragDropSourceIndex Mod 8, DragDropSourceIndex \ 8
            drawPiece DragDropTargetIndex Mod 8, DragDropTargetIndex \ 8

            '            Dim target As DragDragDropTargetStruct
            '            target = DragDropTargets(DragDropTargetIndex)
            '            'recolor target
            '            Line (target.x1, target.y1)-(target.x2, target.y2), DragDropSources(DragDropSourceIndex).col, BF
            DragDropResume
    End Select
Loop While InKey$ <> _CHR_ESC
DragDropTerminate
For i = BlackKing To WhiteKing
    If i <> EmptySquare Then _FreeImage pieceImages(i)
Next i

Screen 0
_FreeImage Scrn
System

Sub drawSquare (x As Integer, y As Integer)
    Line (31 + x * 80, 61 + y * 80)-(31 + x * 80 + 79, 61 + y * 80 + 79), _IIf((x + y) Mod 2 = 1, DarkGray, LightGray), BF
End Sub

Function DragDropSourceImage& (x As Integer, y As Integer)
    'Line (31 + x * 80, 61 + y * 80)-(31 + x * 80 + 79, 61 + y * 80 + 79), _IIf((x + y) Mod 2 = 1, DarkGray, LightGray), BF
    Dim piece As _Byte
    piece = squares(y, x)
    Dim image As Long
    If piece <> EmptySquare Then
        image = pieceImages(piece)
        '_PutImage (31 + x * 80, 61 + y * 80)-(31 + x * 80 + 79, 61 + y * 80 + 79), pieceImages(piece), Scrn
    End If
    DragDropSourceImage& = image
End Function

Sub drawPiece (x As Integer, y As Integer)
    'Line (31 + x * 80, 61 + y * 80)-(31 + x * 80 + 79, 61 + y * 80 + 79), _IIf((x + y) Mod 2 = 1, DarkGray, LightGray), BF
    Dim piece As _Byte
    piece = squares(y, x)
    Dim image As Long
    If piece <> EmptySquare Then
        image = pieceImages(piece)
        _PutImage (31 + x * 80, 61 + y * 80)-(31 + x * 80 + 79, 61 + y * 80 + 79), pieceImages(piece), Scrn
    End If
End Sub

'$Include: 'DragDrop.bm'
