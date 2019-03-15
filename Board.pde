class Board {
    int boardNumRows, boardNumCols, tileSize;
    boolean flip, turn;
    Position selected;
    Piece[][] board, initBoard;
    ArrayList<Move> gameMoves;

    Board (int rows, int cols, int tile) {
        boardNumRows = rows;
        boardNumCols = cols;
        tileSize = tile;
        flip = false;
        turn = true;
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
                Piece p = clonePiece(board, r, c);
                Piece initP = clonePiece(initBoard, r, c);
                newBoard.board[r][c] = p;
                newBoard.initBoard[r][c] = initP;
            }
        }
        return newBoard;
    }
    
    Piece clonePiece(Piece [][] b, int r, int c) {
        if (b[r][c] == null) 
            return null;
        else
            return b[r][c].clonePiece();
    }
    
    Board tryMove (Move m) {
        Board tempBoard = cloneBoard();
        tempBoard.makeMove(m);
        return tempBoard;
    }

    void initBoard() {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                initBoard[r][c] = clonePiece(board, r, c);
            }
        }
    }

    void resetBoard() {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                board[r][c] = clonePiece(initBoard, r, c);
            }
        }
        gameMoves.clear();
    }
    
    boolean inBounds(int r, int c) {
        return (0 <= r && r < boardNumRows) && (0 <= c && c < boardNumCols);
    }

    boolean isOccupied(int row, int col) {
        return board[row][col] != null;
    }
    
    boolean isOccupied(Position pos) {
        assert pos.isValid() : "invalid position";
        return board[pos.getRow()][pos.getCol()] != null;
    }
    
    Piece getPiece(Position pos) {
        assert pos.isValid() : "invalid position";
        return board[pos.getRow()][pos.getCol()];
    }

    void addPiece(int row, int col, Piece p) {
        if (isOccupied(row, col))
            throw new RuntimeException("Trying to move piece to occupied space (" + row + ", " + col + ")\n");
        else
            board[row][col] = p;
    }
    
    void addPiece(Position pos, Piece p) {
        assert pos.isValid() : "invalid position";
        addPiece(pos.getRow(), pos.getCol(), p);
    }

    Piece removePiece(int row, int col) {
        if (!isOccupied(row, col))
            throw new RuntimeException("Trying to move piece from unoccupied space (" + row + ", " + col + ")\n");
        else {
            Piece p = board[row][col];
            board[row][col] = null;
            return p;
        }
    }
    
    Piece removePiece(Position pos) {
        assert pos.isValid() : "invalid position";
        return removePiece(pos.getRow(), pos.getCol());
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
                if (selected.isSamePosition(r, c))
                    drawTile(r, c, 255, 255, 255);
                else if (isMouseOver(r, c))
                    drawTile(r, c, 255, 0, 0);
                else if (inCheck(true) && isOccupied(r, c) && board[r][c] instanceof King && board[r][c].getPlayer())
                    drawTile(r, c, 0, 0, 0);
                else if (inCheck(false) && isOccupied(r, c) && board[r][c] instanceof King && !board[r][c].getPlayer())
                    drawTile(r, c, 0, 0, 0);
                else
                    drawTile(r, c);
            }
        }
    }

    void drawTile(int row, int col, int r, int g, int b) {
        float rowAdjusted = (row - boardNumRows/2.) * tileSize;
        float colAdjusted = (col - boardNumCols/2.) * tileSize;
        fill(r, g, b);
        rect(colAdjusted, rowAdjusted, tileSize, tileSize);
        if (isOccupied(row, col))
            image(board[row][col].getPieceImage(), colAdjusted, rowAdjusted, tileSize, tileSize);
    }
    
    void drawTile(int row, int col) {
        if ((row % 2) == (col % 2))
            drawTile(row, col, 240, 217, 181); //light color
        else 
            drawTile(row, col, 181, 136, 99); //dark color
        /*if (isMouseOver())
             draw(row, col, 255, 0, 0);*/
    }

    void drawMoves() {
        ArrayList<Move> moves = new ArrayList<Move>();
        if (selected.isValid()) {
            moves = getMoves(selected.getRow(), selected.getCol());
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
            int newRow = move.getFinalPosR();
            int newCol = move.getFinalPosC();
            if (isOccupied(newRow, newCol)) drawTile(newRow, newCol, 0, 255, 0);
            else drawTile(newRow, newCol, 0, 255, 255);
        }
    }

    boolean inCheck(boolean player) {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                if (isOccupied(r, c) && (board[r][c].getPlayer() ^ player)) {
                    ArrayList<Move> moves = getMoves(r, c);
                    for (Move move : moves) {
                        int newRow = move.getFinalPosR();
                        int newCol = move.getFinalPosC();
                        if (isOccupied(newRow, newCol)) {
                            Piece p = board[newRow][newCol];
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
        if (!isOccupied(r, c))
            return new ArrayList<Move>();
        Piece p = board[r][c];
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
                    if (!isOccupied(r+newRowMove, c+newColMove) && !capture) { //Move to empty space
                        validMoves.add(new Move(r, c, newRowMove, newColMove));
                        continueMoves(validMoves, moveStep.getNextMove(), p, r, c, newRowMove, newColMove, capture);
                    } else if (isOccupied(r+newRowMove, c+newColMove) && capture) {
                        if (board[r+newRowMove][c+newColMove].getPlayer() ^ p.getPlayer()) { //Move to opposing occupied space; stops movement
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

    Move validMove(Position start, Position end) {
        //Returns the correct move from start to end if it exists, and null otherwise
        ArrayList<Move> moves = getMoves(start.getRow(), start.getCol());
        for (Move move : moves) {
            if (move.getFinalPosR() == end.getRow() && move.getFinalPosC() == end.getCol())
                return move;
        }
        return null;
    }

    void makeMove(Move m) {
        if (isOccupied(m.getFinalPosR(), m.getFinalPosC()))
            removePiece(m.getFinalPosR(), m.getFinalPosC());
        Piece p = removePiece(m.getRow(), m.getCol());
        addPiece(m.getFinalPosR(), m.getFinalPosC(), p);
        p.moved();

        selected.clear(); 
        gameMoves.add(m);
        turn = !turn;
    }

    void selectTile() {
        Position pos = getMouseOver();
        if (!selected.isValid()) {
            if (pos.isValid() && isOccupied(pos) && (turn == getPiece(pos).getPlayer()))
                selected = pos;
        } else {
            if (!pos.isValid() || pos.equals(selected)) {
                selected.clear();
            } else if (isOccupied(pos) && getPiece(pos).getPlayer() == getPiece(selected).getPlayer()) {
                selected = pos;
            } else {
                Move m = validMove(selected, pos);
                if (m == null) 
                    selected.clear();
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
        
        abstract Piece clonePiece ();
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
        
        Pawn clonePiece () {
            Pawn newPiece = new Pawn(player);
            if (moved) newPiece.moved();
            return newPiece;
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
        
        Bishop clonePiece () {
            Bishop newPiece = new Bishop(player);
            if (moved) newPiece.moved();
            return newPiece;
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
        
        Knight clonePiece () {
            Knight newPiece = new Knight(player);
            if (moved) newPiece.moved();
            return newPiece;
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
        
        Rook clonePiece () {
            Rook newPiece = new Rook(player);
            if (moved) newPiece.moved();
            return newPiece;
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
        
        Queen clonePiece () {
            Queen newPiece = new Queen(player);
            if (moved) newPiece.moved();
            return newPiece;
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
        
        King clonePiece () {
            King newPiece = new King(player);
            if (moved) newPiece.moved();
            return newPiece;
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

        boolean isValid() {
            return exists;
        }

        int getRow() {
            return row;
        }

        int getCol() {
            return col;
        }
        
        boolean isSamePosition(int r, int c) {
            return (row == r) && (col == c) && exists;
        }
        
        boolean equals(Position pos) {
            return (!exists && !pos.exists) || ((exists && pos.exists) && (row == pos.row) && (col == pos.col));
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
