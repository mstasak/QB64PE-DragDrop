# DragDrop.bas
Drag and drop rectangular areas on a graphics screen.
QB64 PE 4.2.0 on Windows
Might be useful to somebody.  It's a little long, but one file and should be flexible. (.bi and .bm markers included)
Possible modifications:
- kinder feedback when dropping on an invalid area (currently BEEPs).
- demo with irregular shapes in transparent rectangular containers.  Maybe Chess pieces and board?
- source and target categories, to prevent unrelated/invalid drag-drop operations on one screen.
- demo with removal of source upon dragging (move vs copy effects)
- decorate image while dragging to indicate move( ) vs copy(+), valid vs invalid target (Ø)
- multi-file demo to test if .bi, .bm works as expected.
- cluster the DragDropX variables into a UDT structure, to minimize variable name count.
