class Board {
    int boardNumRows, boardNumCols, tileSize;
    boolean flip, turn, whiteCheck, blackCheck;
    Position selected;
    Piece[][] board, initBoard;
    ArrayList<Move> gameMoves;

    Board (int rows, int cols, int tile) {
        boardNumRows = rows;
        boardNumCols = cols;
        tileSize = tile;
        flip = false;
        turn = true;
        whiteCheck = false;
        blackCheck = false;
        selected = new Position();
        gameMoves = new ArrayList<Move>();
        board = new Piece[boardNumRows][boardNumCols];
        initBoard = new Piece[boardNumRows][boardNumCols];
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                board[r][c] = null;
            }
        }
    }

    Board cloneBoard () { //Copy constructor
        Board newBoard = new Board (boardNumRows, boardNumCols, tileSize);
        newBoard.flip = flip;
        newBoard.turn = turn;
        newBoard.selected = selected.clonePosition();
        for (Move move : gameMoves)
            newBoard.gameMoves.add(move);
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                Piece p = board[r][c].clonePiece();
                Piece initP = initBoard[r][c].clonePiece();
                newBoard.board[r][c] = p;
                newBoard.initBoard[r][c] = initP;
            }
        }
        return newBoard;
    }

    void initBoard() {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                initBoard[r][c] = board[r][c].clonePiece();
            }
        }
    }

    void resetBoard() {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                board[r][c] = initBoard[r][c].clonePiece();
            }
        }
        gameMoves.clear();
    }

    void addPiece(int row, int col, Piece p) {
        if (board[row][col] != null)
            throw new RuntimeException("Trying to move piece to occupied space (" + row + ", " + col + ")\n");
        else
            board[row][col] = p;
    }

    Piece removePiece(int row, int col) {
        if (board[row][col] == null)
            throw new RuntimeException("Trying to move piece from unoccupied space (" + row + ", " + col + ")\n");
        else {
            Piece p = board[row][col];
            board[row][col] = null;
            return p;
        }
    }

    Position getMouseOver() {
        Position pos = new Position();
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                if (isMouseOver(r, c))
                    pos.setPosition(r, c);
            }
        }
        return pos;
    }
    
    boolean isMouseOver(int row, int col) {
        float rowAdjusted = (row - boardNumRows/2.) * tileSize;
        float colAdjusted = (col - boardNumCols/2.) * tileSize;
        return (colAdjusted <= mouseXAdjusted() && mouseXAdjusted() < colAdjusted + tileSize) 
            && (rowAdjusted <= mouseYAdjusted() && mouseYAdjusted() < rowAdjusted + tileSize);
    }

    void drawBoard() {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                Tile t = board[r][c];  // don't forget to add Piece.moved to constructor and cloner (line 233-ish)
                if (t == selectedTile)
                    t.drawTile(255, 255, 255);
                else if (t.isMouseOver())
                    t.drawTile(255, 0, 0);
                else
                    t.drawTile();
            }
        }
    }

    void drawMoves() {
        ArrayList<Move> moves = new ArrayList<Move>();
        if (selectedTile != null) {
            moves = getMoves(selectedTile.getRow(), selectedTile.getCol());
        }/* else {
         for (int r = 0; r < boardNumRows; r++) {
         for (int c = 0; c < boardNumCols; c++) {
         Tile t = board[r][c];
         if (t.isMouseOver()) {
         moves = getMoves(r, c);
         }
         }
         }
         }*/
        for (Move move : moves) {
            Tile newPos = board[move.getFinalPosR()][move.getFinalPosC()];
            if (newPos.isOccupied()) newPos.drawTile(0, 255, 0);
            else newPos.drawTile(0, 255, 255);
        }
    }

    boolean inBounds(int r, int c) {
        return (0 <= r && r < boardNumRows) && (0 <= c && c < boardNumCols);
    }

    ArrayList<Move> getMoves(int r, int c) {
        if (!board[r][c].isOccupied())
            return new ArrayList<Move>();
        Piece p = board[r][c].getPiece();
        MoveStep[] moveSteps = p.getMoves();
        MoveStep[] captureSteps = p.getCaptures();
        ArrayList<Move> moves = new ArrayList<Move>();
        continueMoves(moves, moveSteps, p, r, c, 0, 0, false);
        continueMoves(moves, captureSteps, p, r, c, 0, 0, true);
        return moves;
    }

    ArrayList<Move> continueMoves(ArrayList<Move> validMoves, MoveStep[] moveSteps, Piece p, int r, int c, int rowMove, int colMove, boolean capture) { //capture == false: move; capture == true: capture
        if (moveSteps != null) {
            for (MoveStep moveStep : moveSteps) {
                int newRowMove = rowMove + moveStep.getRowStep()*(p.getPlayer()^flip?1:-1);
                int newColMove = colMove + moveStep.getColStep()*(p.getPlayer()^flip?1:-1);
                //Can check for duplicate moves here
                if (moveStep.isIntermediate()) { //Knight moves
                    continueMoves(validMoves, moveStep.getNextMove(), p, r, c, newRowMove, newColMove, capture);
                } else if (inBounds(r + newRowMove, c + newColMove)) {
                    if (!board[r+newRowMove][c+newColMove].isOccupied() && !capture) { //Move to empty space
                        validMoves.add(new Move(r, c, newRowMove, newColMove));
                        continueMoves(validMoves, moveStep.getNextMove(), p, r, c, newRowMove, newColMove, capture);
                    } else if (board[r+newRowMove][c+newColMove].isOccupied() && capture) {
                        if (board[r+newRowMove][c+newColMove].getPiece().getPlayer() ^ p.getPlayer()) { //Move to opposing occupied space; stops movement
                            validMoves.add(new Move(r, c, newRowMove, newColMove));
                        }
                    } else if (capture) {
                        continueMoves(validMoves, moveStep.getNextMove(), p, r, c, newRowMove, newColMove, capture);
                    }
                }
            }
        }
        return validMoves;
    }

    Move validTileMove(Tile start, Tile end) {
        //Returns the correct move from start to end if it exists, and null otherwise
        ArrayList<Move> moves = getMoves(start.getRow(), start.getCol());
        for (Move move : moves) {
            if (move.getFinalPosR() == end.getRow() && move.getFinalPosC() == end.getCol())
                return move;
        }
        return null;
    }

    void makeMove(Move m) {
        if (board[m.getFinalPosR()][m.getFinalPosC()].isOccupied())
            removePiece(m.getFinalPosR(), m.getFinalPosC());
        Piece p = removePiece(m.getRow(), m.getCol());
        addPiece(m.getFinalPosR(), m.getFinalPosC(), p);
        p.moved();

        selectedTile = null;
        gameMoves.add(m);
        turn = !turn;
    }

    void selectTile() {
        Tile t = getMouseOver();
        if (selectedTile == null) {
            if (t != null && t.isOccupied() && (turn == t.getPiece().getPlayer()))
                selectedTile = t;
        } else {
            if (t == null || t == selectedTile) {
                selectedTile = null;
            } else if (t.isOccupied() && t.getPiece().getPlayer() == selectedTile.getPiece().getPlayer()) {
                selectedTile = t;
            } else {
                Move m = validTileMove(selectedTile, t);
                if (m == null) 
                    selectedTile = null;
                else
                    makeMove(m);
            }
        }
    }

    void flip() {
        flip = !flip;
        Piece[][] tmp = new Piece[boardNumRows][boardNumCols];
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                tmp[r][c] = board[boardNumRows-r-1][boardNumCols-c-1];
            }
        }
        board = tmp;
    }

    /***********************************************/
    /***********************************************/
    /***********************************************/

    abstract class Piece {
        MoveStep[] moves, captures;
        boolean player, moved = false; //player == true: Player 1/white; player == false: Player 2/black
        PImage pieceImage; //add moved to constructor and cloner

        Piece (boolean t, PImage p) {
            player = t;
            pieceImage = p;
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
        
        abstract Piece clonePiece ();
    }

    class Pawn extends Piece {
        Pawn (boolean t) {
            super (t, loadImage(t?"ChessPieces/whitePawn.png":"ChessPieces/blackPawn.png"));
            MoveStep m1 = new MoveStep(-1, 0);
            MoveStep m2 = new MoveStep(-1, -1);
            MoveStep m3 = new MoveStep(-1, 1);
            moves = new MoveStep[] {m1};
            captures = new MoveStep[] {m2, m3};
        }

        MoveStep[] getMoves () {
            return moved?moves:(MoveStep[])append(moves, new MoveStep(-2, 0));
        }
        
        Pawn clonePiece () {
            return new Pawn(player);
        }
    }


    class Bishop extends Piece {
        Bishop (boolean t) {
            super (t, loadImage(t?"ChessPieces/whiteBishop.png":"ChessPieces/blackBishop.png"));
            MoveStep m1 = new MoveStep(1, 1);
            MoveStep m2 = new MoveStep(1, -1);
            MoveStep m3 = new MoveStep(-1, 1);
            MoveStep m4 = new MoveStep(-1, -1);
            m1.setNextMove(m1);
            m2.setNextMove(m2);
            m3.setNextMove(m3);
            m4.setNextMove(m4);
            moves = new MoveStep[] {m1, m2, m3, m4};
            captures = new MoveStep[] {m1, m2, m3, m4};
        }
        
        Bishop clonePiece () {
            return new Bishop(player);
        }
    }


    class Knight extends Piece { //Can also explicitly specify Knight moves as (2, 1) without intermediate steps 
        Knight (boolean t) {
            super (t, loadImage(t?"ChessPieces/whiteKnight.png":"ChessPieces/blackKnight.png"));
            MoveStep m1 = new MoveStep(2, 0, true);
            MoveStep m2 = new MoveStep(-2, 0, true);
            MoveStep m3 = new MoveStep(0, 2, true);
            MoveStep m4 = new MoveStep(0, -2, true);
            MoveStep[] m5 = new MoveStep[] {new MoveStep(0, 1), new MoveStep(0, -1)};
            MoveStep[] m6 = new MoveStep[] {new MoveStep(1, 0), new MoveStep(-1, 0)};
            m1.setNextMove(m5);
            m2.setNextMove(m5);
            m3.setNextMove(m6);
            m4.setNextMove(m6);
            moves = new MoveStep[] {m1, m2, m3, m4};
            captures = new MoveStep[] {m1, m2, m3, m4};
        }
        
        Knight clonePiece () {
            return new Knight(player);
        }
    }


    class Rook extends Piece {
        Rook (boolean t) {
            super (t, loadImage(t?"ChessPieces/whiteRook.png":"ChessPieces/blackRook.png"));
            MoveStep m1 = new MoveStep(1, 0);
            MoveStep m2 = new MoveStep(-1, 0);
            MoveStep m3 = new MoveStep(0, 1);
            MoveStep m4 = new MoveStep(0, -1);
            m1.setNextMove(m1);
            m2.setNextMove(m2);
            m3.setNextMove(m3);
            m4.setNextMove(m4);
            moves = new MoveStep[] {m1, m2, m3, m4};
            captures = new MoveStep[] {m1, m2, m3, m4};
        }
        
        Rook clonePiece () {
            return new Rook(player);
        }
    }


    class Queen extends Piece {
        Queen (boolean t) {
            super (t, loadImage(t?"ChessPieces/whiteQueen.png":"ChessPieces/blackQueen.png"));
            MoveStep m1 = new MoveStep(1, 1);
            MoveStep m2 = new MoveStep(1, -1);
            MoveStep m3 = new MoveStep(-1, 1);
            MoveStep m4 = new MoveStep(-1, -1);
            MoveStep m5 = new MoveStep(1, 0);
            MoveStep m6 = new MoveStep(-1, 0);
            MoveStep m7 = new MoveStep(0, 1);
            MoveStep m8 = new MoveStep(0, -1);
            m1.setNextMove(m1);
            m2.setNextMove(m2);
            m3.setNextMove(m3);
            m4.setNextMove(m4);
            m5.setNextMove(m5);
            m6.setNextMove(m6);
            m7.setNextMove(m7);
            m8.setNextMove(m8);
            moves = new MoveStep[] {m1, m2, m3, m4, m5, m6, m7, m8};
            captures = new MoveStep[] {m1, m2, m3, m4, m5, m6, m7, m8};
        }
        
        Queen clonePiece () {
            return new Queen(player);
        }
    }


    class King extends Piece {
        King (boolean t) {
            super (t, loadImage(t?"ChessPieces/whiteKing.png":"ChessPieces/blackKing.png"));
            MoveStep m1 = new MoveStep(1, 1);
            MoveStep m2 = new MoveStep(1, -1);
            MoveStep m3 = new MoveStep(-1, 1);
            MoveStep m4 = new MoveStep(-1, -1);
            MoveStep m5 = new MoveStep(1, 0);
            MoveStep m6 = new MoveStep(-1, 0);
            MoveStep m7 = new MoveStep(0, 1);
            MoveStep m8 = new MoveStep(0, -1);
            moves = new MoveStep[] {m1, m2, m3, m4, m5, m6, m7, m8};
            captures = new MoveStep[] {m1, m2, m3, m4, m5, m6, m7, m8};
        }
        
        King clonePiece () {
            return new King(player);
        }
    }

    /***********************************************/
    /***********************************************/
    /***********************************************/

    class Position {
        boolean exists;
        int row, col;

        Position (int r, int c, boolean e) {
            assert !e || (0 <= r && r < boardNumRows && 0 <= c && c < boardNumCols): "Position out of bounds";
            row = r;
            col = c;
            exists = e;
        }

        Position () {
            exists = false;
        }

        Position clonePosition () {
            return new Position (row, col, exists);
        }

        void clear() {
            exists = false;
        }

        boolean isPosition() {
            return exists;
        }

        int getRow() {
            return row;
        }

        int getCol() {
            return col;
        }

        void setRow(int r) {
            assert 0 <= r && r < boardNumRows && exists: "Position out of bounds";
            row = r;
            exists = true;
        }

        void setCol(int c) {
            assert exists && 0 <= c && c < boardNumCols: "Position out of bounds";
            col = c;
            exists = true;
        }

        void setPosition(int r, int c) {
            assert 0 <= r && r < boardNumRows && 0 <= c && c < boardNumCols: "Position out of bounds";
            row = r;
            col = c;
            exists = true;
        }
    }
}
