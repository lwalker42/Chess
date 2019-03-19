import java.util.Iterator;

class Board {
    private int boardNumRows, boardNumCols, tileSize;
    private boolean flip, turn, whiteCheck, blackCheck;
    private Position selected;
    private Piece[][] board, initBoard;
    private ArrayList<Move> gameMoves;

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
    }

    Board cloneBoard () { //Copy constructor
        Board newBoard = new Board (boardNumRows, boardNumCols, tileSize);
        newBoard.flip = flip;
        newBoard.turn = turn;
        newBoard.whiteCheck = whiteCheck;
        newBoard.blackCheck = blackCheck;
        newBoard.selected = selected.clonePosition();
        for (Move move : gameMoves)
            newBoard.gameMoves.add(move); //need to clone move
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                Piece p = newBoard.clonePiece(board, r, c);
                if (p != null)
                    p.setBoard(newBoard);
                Piece initP = newBoard.clonePiece(initBoard, r, c);
                if (initP != null)
                    initP.setBoard(newBoard);
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

    boolean inBounds(Position pos) {
        return inBounds(pos.getRow(), pos.getCol());
    }

    boolean isOccupied(int row, int col) {
        return board[row][col] != null;
    }

    boolean isOccupied(Position pos) {
        assert pos.isValid() : "invalid position";
        return board[pos.getRow()][pos.getCol()] != null;
    }
    
    Piece getPiece(int row, int col) {
        assert inBounds(row, col) : "Out of bounds";
        return board[row][col];
    }

    Piece getPiece(Position pos) {
        assert pos.isValid() : "invalid position";
        return getPiece(pos.getRow(), pos.getCol());
    }
    
    Piece getInitPiece(int row, int col) {
        assert inBounds(row, col) : "Out of bounds";
        return initBoard[row][col];
    }

    Piece getInitPiece(Position pos) {
        assert pos.isValid() : "invalid position";
        return getPiece(pos.getRow(), pos.getCol());
    }
    
    void addPiece(int row, int col, Piece p) {
        if (isOccupied(row, col))
            throw new RuntimeException("Trying to move piece to occupied space (" + row + ", " + col + ")\n");
        else {
            board[row][col] = p;
            if (p != null)
                p.setBoard(this);
        }
    }

    void addPiece(Position pos, Piece p) {
        assert pos.isValid() : 
        "invalid position";
        addPiece(pos.getRow(), pos.getCol(), p);
    }

    Piece removePiece(int row, int col) {
        if (!isOccupied(row, col))
            throw new RuntimeException("Trying to move piece from unoccupied space (" + row + ", " + col + ")\n");
        else {
            Piece p = board[row][col];
            board[row][col] = null;
            p.setBoard(null);
            return p;
        }
    }

    Piece removePiece(Position pos) {
        assert pos.isValid() : 
        "invalid position";
        return removePiece(pos.getRow(), pos.getCol());
    }

    Position getMouseOver() {
        Position pos = new Position();
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                if (isMouseOver(r, c)) {
                    pos.setPosition(r, c);
                    return pos;
                }
            }
        }
        return pos;
    }

    boolean isMouseOver(int row, int col) {
        float mouseXAdjusted =  mouseX - width/2.;
        float mouseYAdjusted =  mouseY - height/2.;
        float rowAdjusted = flip?(boardNumRows/2. - row - 1) * tileSize:(row - boardNumRows/2.) * tileSize;
        float colAdjusted = flip?(boardNumCols/2. - col - 1) * tileSize:(col - boardNumCols/2.) * tileSize;
        return (colAdjusted <= mouseXAdjusted && mouseXAdjusted < colAdjusted + tileSize) 
            && (rowAdjusted <= mouseYAdjusted && mouseYAdjusted < rowAdjusted + tileSize);
    }

    void drawBoard() {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                if (selected.equals(r, c))
                    drawTile(r, c, 255, 255, 255);
                else if (isMouseOver(r, c))
                    drawTile(r, c, 255, 0, 0);
                else if (whiteCheck && isOccupied(r, c) && board[r][c] instanceof King && board[r][c].getPlayer())
                    drawTile(r, c, 0, 0, 0);
                else if (blackCheck && isOccupied(r, c) && board[r][c] instanceof King && !board[r][c].getPlayer())
                    drawTile(r, c, 0, 0, 0);
                else
                    drawTile(r, c);
            }
        }
        drawMoves();
    }

    void drawTile(int row, int col, int r, int g, int b) {
        float rowAdjusted = flip?(boardNumRows/2. - row - 1) * tileSize:(row - boardNumRows/2.) * tileSize;
        float colAdjusted = flip?(boardNumCols/2. - col - 1) * tileSize:(col - boardNumCols/2.) * tileSize;
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
        if (selected.isValid()) {
            ArrayList<Move> moves = getValidMoves(selected);
            for (Move move : moves) {
                Position pos = move.getEnd();
                if (isOccupied(pos)) drawTile(pos.getRow(), pos.getCol(), 0, 255, 0);
                else drawTile(pos.getRow(), pos.getCol(), 0, 255, 255);
            }
        }
    }

    Board tryMove(Move m) {
        Board tempBoard = cloneBoard();
        tempBoard.makeMove(m);
        return tempBoard;
    }

    boolean inCheck(boolean player) {
        for (int r = 0; r < boardNumRows; r++) {
            for (int c = 0; c < boardNumCols; c++) {
                if (isOccupied(r, c) && board[r][c].getPlayer() ^ player) {
                    ArrayList<Move> moves = getMoves(r, c, true);
                    for (Move move : moves) {
                        if (move.getCaptured().isValid() && isOccupied(move.getCaptured())) {
                            Piece capturedPiece = getPiece(move.getCaptured());
                            if (capturedPiece instanceof King && capturedPiece.getPlayer() == player)
                                return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    ArrayList<Move> getValidMoves(int r, int c) {
        Position pos = new Position(r, c);
        return getValidMoves(pos);
    }

    ArrayList<Move> getValidMoves(Position pos) {
        return getPiece(pos).getValidMoves(pos);
    }

    ArrayList<Move> getMoves(int r, int c, boolean capture) {
        Position pos = new Position(r, c);
        return getMoves(pos, capture);
    }

    ArrayList<Move> getMoves(Position pos, boolean capture) {
        return getPiece(pos).getMoves(pos, capture);
    }

    void makeMove(Move m) {
        for (; m != null; m = m.getNextMove()) {
            if (m.getCaptured().isValid() && isOccupied(m.getCaptured()))
                removePiece(m.getCaptured());
            removePiece(m.getStart());
            addPiece(m.getEnd(), m.getNewPiece());
            getPiece(m.getEnd()).moved(); 
            gameMoves.add(m);
        }
        selected.clear();
        turn = !turn;
        whiteCheck = inCheck(true);
        blackCheck = inCheck(false);
    }

    Move getValidMove(Position start, Position end) {
        ArrayList<Move> moves = getValidMoves(start);
        for (Move move : moves) {
            if (move.getEnd().equals(end))
                return move;
        }
        return null;
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
                Move m = getValidMove(selected, pos);
                if (m == null) 
                    selected.clear();
                else
                    makeMove(m);
            }
        }
    }

    void flip() {
        flip = !flip;
    }
}
