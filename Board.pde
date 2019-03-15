class Board {
    int boardNumRows, boardNumCols, tileSize, pieceID;
    Tile[][] board, initBoard;
    boolean flip, turn, whiteCheck, blackCheck;
    Tile selectedTile;
    ArrayList<Move> gameMoves;

    Board (int rows, int cols, int tile) {
        boardNumRows = rows;
        boardNumCols = cols;
        tileSize = tile;
        pieceID = 0;
        flip = false;
        turn = true;
        whiteCheck = false;
        blackCheck = false;
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
        pieceID = b.pieceID;
        flip = b.flip;
        turn = b.turn;
        whiteCheck = b.whiteCheck;
        blackCheck = b.blackCheck;
        selectedTile = b.selectedTile;
        gameMoves = new ArrayList<Move>();
        board = new Tile[boardNumRows][boardNumCols];
        initBoard = new Tile[boardNumRows][boardNumCols];
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                board[r][c] = new Tile(r, c);
            }
        }
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

    void addPiece(Piece p) {
        board[p.getRow()][p.getCol()].addPiece(p);
    }

    Piece removePiece(int r, int c) {
        return board[r][c].removePiece();
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
            Tile newPos = board[move.getNewRow()][move.getNewCol()];
            if (newPos.isOccupied()) newPos.drawTile(0, 255, 0);
            else newPos.drawTile(0, 255, 255);
        }
    }

    boolean inBounds(int r, int c) {
        return (0 <= r && r < boardNumRows) && (0 <= c && c < boardNumCols);
    }

    ArrayList<Move> getMoves(int r, int c) {
        if (board[r][c].getPiece() != null); return null;
    }

    Move validTileMove(Tile start, Tile end) {
        //Returns the correct move from start to end if it exists, and null otherwise
        ArrayList<Move> moves = getMoves(start.getRow(), start.getCol());
        for (Move move : moves) {
            if (move.getNewRow() == end.getRow() && move.getNewCol() == end.getCol())
                return move;
        }
        return null;
    }

    void makeMove(Move m) {
        if (board[m.getNewRow()][m.getNewCol()].isOccupied())
            removePiece(m.getNewRow(), m.getNewCol());
        Piece p = removePiece(m.getRow(), m.getCol());
        p.setRow(m.getNewRow());
        p.setCol(m.getNewCol());
        addPiece(p);
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
            if (currentPiece != null) {
                currentPiece.setRow(r);
                currentPiece.setCol(c);
            }
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
    
    /***********************************************/
    /***********************************************/
    /***********************************************/
    
         
    }
    class Piece {
        int row, col, id;
        MoveStep[] moves, captures;
        boolean player, moved = false; //player == true: Player 1/white; player == false: Player 2/black
        PImage pieceImage;
    
        Piece (int r, int c, boolean t, PImage p) {
            row = r;
            col = c;
            id = pieceID++;
            player = t;
            pieceImage = p;
        }
    
        int getRow() {
            return row;
        }
    
        int getCol() {
            return col;
        }
    
        void setRow(int r) {
            row = r;
        }
    
        void setCol(int c) {
            col = c;
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
        
        ArrayList<Move> getMoves(int r, int c) {
            if (!board[r][c].isOccupied())
                return new ArrayList<Move>();
            Piece p = board[r][c].getPiece();
            MoveStep[] moveSteps = p.getMoves();
            MoveStep[] captureSteps = p.getCaptures();
            ArrayList<Move> moves = new ArrayList<Move>();
            continueMoves(moves, moveSteps, p, 0, 0, false);
            continueMoves(moves, captureSteps, p, 0, 0, true);
            return moves;
        }
    
        ArrayList<Move> continueMoves(ArrayList<Move> validMoves, MoveStep[] moveSteps, Piece p, int rowMove, int colMove, boolean capture) { //capture == false: move; capture == true: capture
            if (moveSteps != null) {
                int r = p.getRow();
                int c = p.getCol();
                for (MoveStep moveStep : moveSteps) {
                    int newRowMove = rowMove + moveStep.getRowStep()*(p.getPlayer()^flip?1:-1);
                    int newColMove = colMove + moveStep.getColStep()*(p.getPlayer()^flip?1:-1);
                    //Can check for duplicate moves here
                    if (moveStep.isIntermediate()) { //Knight moves
                        continueMoves(validMoves, moveStep.getNextMove(), p, newRowMove, newColMove, capture);
                    } else if (inBounds(r + newRowMove, c + newColMove)) {
                        if (!board[r+newRowMove][c+newColMove].isOccupied() && !capture) { //Move to empty space
                            validMoves.add(new Move(r, c, newRowMove, newColMove));
                            continueMoves(validMoves, moveStep.getNextMove(), p, newRowMove, newColMove, capture);
                        } else if (board[r+newRowMove][c+newColMove].isOccupied() && capture) {
                            if (board[r+newRowMove][c+newColMove].getPiece().getPlayer() ^ p.getPlayer()) { //Move to opposing occupied space; stops movement
                                validMoves.add(new Move(r, c, newRowMove, newColMove));
                            }
                        } else if (capture) {
                            continueMoves(validMoves, moveStep.getNextMove(), p, newRowMove, newColMove, capture);
                        }
                    }
                }
            }
            return validMoves;
        }
    }
    
    class Pawn extends Piece {
        Pawn (int r, int c, boolean t) {
            super (r, c, t, loadImage(t?"ChessPieces/whitePawn.png":"ChessPieces/blackPawn.png"));
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
        Bishop (int r, int c, boolean t) {
            super (r, c, t, loadImage(t?"ChessPieces/whiteBishop.png":"ChessPieces/blackBishop.png"));
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
        Knight (int r, int c, boolean t) {
            super (r, c, t, loadImage(t?"ChessPieces/whiteKnight.png":"ChessPieces/blackKnight.png"));
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
        Rook (int r, int c, boolean t) {
            super (r, c, t, loadImage(t?"ChessPieces/whiteRook.png":"ChessPieces/blackRook.png"));
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
        Queen (int r, int c, boolean t) {
            super (r, c, t, loadImage(t?"ChessPieces/whiteQueen.png":"ChessPieces/blackQueen.png"));
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
        King (int r, int c, boolean t) {
            super (r, c, t, loadImage(t?"ChessPieces/whiteKing.png":"ChessPieces/blackKing.png"));
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
    
    class Move {
        int row, col, newRow, newCol, capturedRow = -1, capturedCol = -1;
        Piece newPiece; //defaults to old piece
        Move next = null;
        
        Move (int r, int c, int newR, int newC) {
            row = r;
            col = c;
            newRow = newR;
            newCol = newC;
        }
        
        int getRow() {
            return row;
        }
        
        int getCol() {
            return row;
        }
        
        int getNewRow() {
            return newRow;
        }
        
        int getNewCol() {
            return newRow;
        }
        
        int getCapturedRow() {
            return newRow;
        }
        
        int getCapturedCol() {
            return newRow;
        }
        
        void setNew(int r, int c) {
            newRow = r;
            newCol = c;
        }
        
        void setCaptured(int r, int c) {
            capturedRow = r;
            capturedCol = c;
        }
        
        void setNextMove(Move m) {
            next = m;
        }
    }
    
}
