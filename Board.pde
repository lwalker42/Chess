class Board {
    int boardNumRows, boardNumCols, tileSize;
    Tile[][] board, initBoard;
    boolean flip, turn;
    Tile selectedTile;
    ArrayList<Move> gameMoves;

    Board (int rows, int cols, int tile) {
        boardNumRows = rows;
        boardNumCols = cols;
        tileSize = tile;
        flip = false;
        turn = true;
        selectedTile = null;
        gameMoves = new ArrayList<Move>();
        board = new Tile[boardNumRows][boardNumCols];
        initBoard = new Tile[boardNumRows][boardNumCols];
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                board[r][c] = new Tile(r, c);
            }
        }
    }

    Board (Board b) { //Copy constructor
        boardNumRows = b.boardNumRows;
        boardNumCols = b.boardNumCols;
        tileSize = b.tileSize;
        flip = b.flip;
        turn = b.turn;
        selectedTile = b.selectedTile;
        gameMoves = new ArrayList<Move>();
        board = new Tile[boardNumRows][boardNumCols];
        initBoard = new Tile[boardNumRows][boardNumCols];
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                board[r][c] = b.board[r][c];
                initBoard[r][c] = b.initBoard[r][c];
            }
        }
    }

    Board tryMove (Move m) {
        Board tempBoard = new Board(this);
        tempBoard.makeMove(m);
        return tempBoard;
    }

    void initBoard() {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                initBoard[r][c] = board[r][c];
            }
        }
    }

    void resetBoard() {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                board[r][c] = initBoard[r][c];
            }
        }
        gameMoves.clear();
    }

    void addPiece(int r, int c, Piece p) {
        board[r][c].addPiece(p);
    }

    Piece removePiece(int r, int c) {
        return board[r][c].removePiece();
    }

    boolean inBounds(int r, int c) {
        return (0 <= r && r < boardNumRows) && (0 <= c && c < boardNumCols);
    }

    Tile getMouseOver() {
        for (int r = 0; r < boardNumRows; r++)
            for (int c = 0; c < boardNumCols; c++)
                if (board[r][c].isMouseOver())
                    return board[r][c];
        return null;
    }

    void drawBoard() {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                Tile t = board[r][c];
                if (t == selectedTile)
                    t.drawTile(255, 255, 255);
                else if (t.isMouseOver())
                    t.drawTile(255, 0, 0);
                else if (inCheck(true) && board[r][c].isOccupied() && board[r][c].getPiece() instanceof King && board[r][c].getPiece().getPlayer())
                    t.drawTile(0, 0, 0);
                else if (inCheck(false) && board[r][c].isOccupied() && board[r][c].getPiece() instanceof King && !board[r][c].getPiece().getPlayer())
                    t.drawTile(0, 0, 0);
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

    boolean inCheck(boolean player) {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                if (board[r][c].isOccupied() && (board[r][c].getPiece().getPlayer() ^ player)) {
                    ArrayList<Move> moves = getMoves(r, c);
                    for (Move move : moves) {
                        int newRow = move.getFinalPosR();
                        int newCol = move.getFinalPosC();
                        if (board[newRow][newCol].isOccupied()) {
                            Piece p = board[newRow][newCol].getPiece();
                            if ((p instanceof King) && !(p.getPlayer() ^ player))
                                return true;
                        }
                    }
                }
            }
        }
        return false;
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

    void addIfSafe(ArrayList<Move> validMoves, Move move) {return;
        /*Board temp = tryMove(move);
        if (!temp.inCheck(turn))
            validMoves.add(move);*/
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
        Tile[][] tmp = new Tile[boardNumRows][boardNumCols];
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                tmp[r][c] = board[boardNumRows-r-1][boardNumCols-c-1];
                tmp[r][c].setLocation(r, c);
            }
        }
        board = tmp;
    }


    /***********************************************/
    /***********************************************/
    /***********************************************/
    class Tile {
        int row, col;
        float rowAdjusted, colAdjusted;
        Piece currentPiece = null;
        boolean impassable = false;

        Tile (int r, int c) {
            row = r;
            col = c;
            adjustRowCol();
        }

        Tile (int r, int c, boolean i) {
            this(r, c);
            impassable = i;
        }

        int getRow() {
            return row;
        }

        int getCol() {
            return col;
        }

        Piece getPiece() {
            return currentPiece;
        }

        void adjustRowCol() {
            rowAdjusted = (row - boardNumRows/2.) * tileSize;
            colAdjusted = (col - boardNumCols/2.) * tileSize;
        }

        void setLocation(int r, int c) {
            row = r;
            col = c;
            adjustRowCol();
        }

        boolean isOccupied () {
            return currentPiece != null;
        }

        void addPiece (Piece p) {
            if (currentPiece != null) {
                throw new RuntimeException("Trying to move piece to occupied space (" + row + ", " + col + ")\n");
            }
            currentPiece = p;
        }

        Piece removePiece () {
            if (currentPiece == null) {
                throw new RuntimeException("Trying to move piece from unoccupied space (" + row + ", " + col + ")\n");
            }
            Piece p = currentPiece;
            currentPiece = null;
            return p;
        }


        boolean isMouseOver() {
            return (colAdjusted <= mouseXAdjusted() && mouseXAdjusted() < colAdjusted + tileSize) 
                && (rowAdjusted <= mouseYAdjusted() && mouseYAdjusted() < rowAdjusted + tileSize);
        }

        void drawTile() {
            if ((row % 2) == (col % 2))
                fill(#f0d9b5); //light color
            else 
            fill(#b58863); //dark color
            /*if (isMouseOver())
             fill(255, 0, 0);*/
            rect(colAdjusted, rowAdjusted, tileSize, tileSize);
            if (currentPiece != null)
                image(currentPiece.getPieceImage(), colAdjusted, rowAdjusted, tileSize, tileSize);
        }

        void drawTile(int r, int g, int b) {
            fill(r, g, b);
            rect(colAdjusted, rowAdjusted, tileSize, tileSize);
            if (currentPiece != null)
                image(currentPiece.getPieceImage(), colAdjusted, rowAdjusted, tileSize, tileSize);
        }
    }

    /***********************************************/
    /***********************************************/
    /***********************************************/

    class Piece {
        MoveStep[] moves, captures;
        boolean player, moved = false; //player == true: Player 1/white; player == false: Player 2/black
        PImage pieceImage;

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
    }

    class Pawn extends Piece {
        Pawn (boolean p) {
            super (p, loadImage(p?"ChessPieces/whitePawn.png":"ChessPieces/blackPawn.png"));
            MoveStep m1 = new MoveStep(-1, 0);
            MoveStep m2 = new MoveStep(-1, -1);
            MoveStep m3 = new MoveStep(-1, 1);
            moves = new MoveStep[] {m1};
            captures = new MoveStep[] {m2, m3};
        }

        MoveStep[] getMoves () {
            return moved?moves:(MoveStep[])append(moves, new MoveStep(-2, 0));
        }
    }


    class Bishop extends Piece {
        Bishop (boolean p) {
            super (p, loadImage(p?"ChessPieces/whiteBishop.png":"ChessPieces/blackBishop.png"));
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
    }


    class Knight extends Piece { //Can also explicitly specify Knight moves as (2, 1) without intermediate steps 
        Knight (boolean p) {
            super (p, loadImage(p?"ChessPieces/whiteKnight.png":"ChessPieces/blackKnight.png"));
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
    }


    class Rook extends Piece {
        Rook (boolean p) {
            super (p, loadImage(p?"ChessPieces/whiteRook.png":"ChessPieces/blackRook.png"));
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
    }


    class Queen extends Piece {
        Queen (boolean p) {
            super (p, loadImage(p?"ChessPieces/whiteQueen.png":"ChessPieces/blackQueen.png"));
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
    }


    class King extends Piece {
        King (boolean p) {
            super (p, loadImage(p?"ChessPieces/whiteKing.png":"ChessPieces/blackKing.png"));
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
    }

    /***********************************************/
    /***********************************************/
    /***********************************************/
}
