abstract class Piece {
    protected MoveStep[] moves, captures;
    protected boolean player, moved = false; //player == true: Player 1/white; player == false: Player 2/black
    protected PImage pieceImage;
    Board board = null;
    

    Piece (boolean p, PImage i) {
        player = p;
        pieceImage = i;
    }

    void moved() {
        moved = true;
    }

    MoveStep[] getMoves () {
        return moves;
    }

    MoveStep[] getCaptures () {
        return captures;
    }

    boolean getPlayer () {
        return player;
    }

    PImage getPieceImage() {
        return pieceImage;
    }
    
    void setBoard(Board b) {
        board = b;
    }
    
    Board getBoard() {
        return board;
    }

    abstract Piece clonePiece ();

    ArrayList<Move> getValidMoves(Position pos) {
            ArrayList<Move> moves = getMoves(pos, true);
            moves.addAll(getMoves(pos, false));
        for (Iterator<Move> iterator = moves.iterator(); iterator.hasNext(); ) {
            Move move = iterator.next();
            print ("row: " + move.getEnd().getRow() + ", col: " + move.getEnd().getCol() + "\n");
            if (board.tryMove(move).inCheck(player)) {
                iterator.remove();
            }
        }
        return moves;
    }

    ArrayList<Move> getMoves(Position pos, boolean capture) {
        ArrayList<Move> possibleMoves = new ArrayList<Move>();
            if (!board.isOccupied(pos))
            return possibleMoves;
        continueMoves(possibleMoves, moves, pos, pos.clonePosition(), capture);
        return possibleMoves;
    }

    void continueMoves(ArrayList<Move> possibleMoves, MoveStep[] moveSteps, Position start, Position end, boolean capture) { //capture == false: move; capture == true: capture
        //print("Piece: "+getClass()+", row: "+start.getRow()+", col: "+start.getCol()+", newRow: "+end.getRow()+", newCol: "+end.getCol()+"\n");
        if (moveSteps != null) {
            for (MoveStep moveStep : moveSteps) {
                int dir = player?1:-1;
                Position newEnd = end.clonePosition();
                newEnd.incrementPosition(moveStep.getRowStep()*dir, moveStep.getColStep()*dir);
                //Can check for duplicate moves here
                if (moveStep.isIntermediate()) { //Knight moves
                    continueMoves(possibleMoves, moveStep.getNextMove(), start, newEnd, capture);
                } else if (board.inBounds(newEnd)) {
                    if (!board.isOccupied(newEnd) && !capture) { //Move to empty space
                        Move move = new Move(start, newEnd);
                        move.setNewPiece(this);
                        possibleMoves.add(move);
                        continueMoves(possibleMoves, moveStep.getNextMove(), start, newEnd, capture);
                    } else if (board.isOccupied(newEnd) && capture) {
                        if (board.getPiece(newEnd).getPlayer() ^ player) { //Move to opposing occupied space; stops movement
                            Move move = new Move(start, newEnd);
                            move.setNewPiece(this);
                            move.setCaptured(newEnd);
                            possibleMoves.add(move);
                        }
                    } else if (capture) {
                        continueMoves(possibleMoves, moveStep.getNextMove(), start, newEnd, capture);
                    }
                }
            }
        }
    }
}
