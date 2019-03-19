    class Move {
        Position start, end, captured;
        Piece newPiece = null; //defaults to old piece
        Move next = null;

        Move (int r, int c, int newR, int newC) {
            start = new Position(r, c);
            end = new Position(newR, newC);
            captured = new Position();
        }

        Move (Position start, Position end) {
            this(start.getRow(), start.getCol(), end.getRow(), end.getCol());
        }

        Position getStart () {
            return start;
        }

        Position getEnd () {
            return end;
        }

        Position getCaptured () {
            return captured;
        }

        Piece getNewPiece() {
            return newPiece;
        }
        
        Move getNextMove() {
            return next;
        }

        void setStart(int r, int c) {
            start.setPosition(r, c);
        }

        void setEnd(int r, int c) {
            end.setPosition(r, c);
        }

        void setCaptured(int r, int c) {
            captured.setPosition(r, c);
        }

        void setCaptured(Position pos) {
            captured = pos.clonePosition();
        }

        void setNewPiece(Piece p) {
            newPiece = p.clonePiece();
        }

        void setNextMove(Move m) {
            next = m;
        }
    }
