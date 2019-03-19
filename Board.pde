import java.util.Iterator;

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
                Piece p = newBoard.clonePiece(board, r, c); //<>//
                Piece initP = newBoard.clonePiece(initBoard, r, c);
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
            return b[r][c].clonePiece(this);
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
                    ArrayList<Move> moves = getMoves(r, c);
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

    ArrayList<Move> getMoves(int r, int c) {
        Position pos = new Position(r, c);
        return getMoves(pos);
    }

    ArrayList<Move> getMoves(Position pos) {
        return getPiece(pos).getMoves(pos);
    }

    void makeMove(Move m) {
        for (; m != null; m = m.getNextMove()) {
            if (m.getCaptured().isValid())
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

    /***********************************************/
    /***********************************************/
    /***********************************************/

    abstract class Piece {
        protected MoveStep[] moves, captures;
        protected boolean player, moved = false; //player == true: Player 1/white; player == false: Player 2/black
        protected PImage pieceImage;

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

        abstract Piece clonePiece (Board b);

        ArrayList<Move> getValidMoves(Position pos) {
                ArrayList<Move> moves = getMoves(pos); //<>//
            for (Iterator<Move> iterator = moves.iterator(); iterator.hasNext(); ) {
                Move move = iterator.next();
                Board temp = cloneBoard();
                temp.makeMove(move);
                if (temp.inCheck(player)) {
                    iterator.remove();
                }
            }
            return moves;
        }

        ArrayList<Move> getMoves(Position pos) {
                if (!isOccupied(pos))
                return new ArrayList<Move>();
            ArrayList<Move> possibleMoves = new ArrayList<Move>();
            continueMoves(possibleMoves, moves, pos, pos.clonePosition(), false);
            continueMoves(possibleMoves, captures, pos, pos.clonePosition(), true);
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
                    } else if (inBounds(newEnd)) {
                        if (!isOccupied(newEnd) && !capture) { //Move to empty space
                            Move move = new Move(start, newEnd);
                            move.setNewPiece(this);
                            possibleMoves.add(move);
                            continueMoves(possibleMoves, moveStep.getNextMove(), start, newEnd, capture);
                        } else if (isOccupied(newEnd) && capture) {
                            if (getPiece(newEnd).getPlayer() ^ player) { //Move to opposing occupied space; stops movement
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

    class Pawn extends Piece {
        Pawn (boolean p) {
            super (p, loadImage(p?"ChessPieces/whitePawn.png":"ChessPieces/blackPawn.png"));
            MoveStep m1 = new MoveStep(-1, 0);
            MoveStep m2 = new MoveStep(-1, -1);
            MoveStep m3 = new MoveStep(-1, 1);
            moves = new MoveStep[] {m1};
            captures = new MoveStep[] {m2, m3};
        }

        Pawn clonePiece (Board b) {
            Pawn newPiece = b.new Pawn(player);
            if (moved) newPiece.moved();
            return newPiece;
        }

        ArrayList<Move> getMoves(Position pos) {
            MoveStep[] normalMoveSteps = moves;
            if (!moved) {
                MoveStep m1 = new MoveStep(-1, 0);
                MoveStep m2 = new MoveStep(-1, 0);
                m1.setNextMove(m2);
                moves = new MoveStep[] {m1};
            }
            ArrayList<Move> possibleMoves = super.getMoves(pos);
            moves = normalMoveSteps;
         
            if (!gameMoves.isEmpty()) {
                int r = pos.getRow();
                int c = pos.getCol();
                int dir = player?1:-1;
                Move prev = gameMoves.get(gameMoves.size() - 1);
                Piece left = inBounds(r, c - 1)?Board.this.board[r][c-1]:null;
                Piece right = inBounds(r, c + 1)?Board.this.board[r][c+1]:null;
                if (left != null && left instanceof Pawn && (left.getPlayer() ^ player) && prev.getStart().equals(r - 2 * dir, c - 1) && prev.getEnd().equals(r, c - 1)) {
                    Move enP = new Move(r, c, r - dir, c - 1);
                    enP.setNewPiece(this);
                    enP.setCaptured(r, c - 1);
                    possibleMoves.add(enP);
                } else if (right != null && right instanceof Pawn && (right.getPlayer() ^ player) && prev.getStart().equals(r - 2 * dir, c + 1) && prev.getEnd().equals(r, c + 1)) {
                    Move enP = new Move(r, c, r - dir, c + 1);
                    enP.setNewPiece(this);
                    enP.setCaptured(r, c + 1);
                    possibleMoves.add(enP);
                }
                    
            }
            
            return possibleMoves;
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

        Bishop clonePiece (Board b) {
            Bishop newPiece = b.new Bishop(player);
            if (moved) newPiece.moved();
            return newPiece;
        }
    }


    class Knight extends Piece { //Can also explicitly specify Knight moves as (2, 1) without intermediate steps 
        Knight (boolean p) {
            super (p, loadImage(p?"ChessPieces/whiteKnight.png":"ChessPieces/blackKnight.png"));
            MoveStep m1 = new MoveStep(2, 0);
            MoveStep m2 = new MoveStep(-2, 0);
            MoveStep m3 = new MoveStep(0, 2);
            MoveStep m4 = new MoveStep(0, -2);
            m1.setIntermediate(true);
            m2.setIntermediate(true);
            m3.setIntermediate(true);
            m4.setIntermediate(true);
            MoveStep[] m5 = new MoveStep[] {new MoveStep(0, 1), new MoveStep(0, -1)};
            MoveStep[] m6 = new MoveStep[] {new MoveStep(1, 0), new MoveStep(-1, 0)};
            m1.setNextMove(m5);
            m2.setNextMove(m5);
            m3.setNextMove(m6);
            m4.setNextMove(m6);
            moves = new MoveStep[] {m1, m2, m3, m4};
            captures = new MoveStep[] {m1, m2, m3, m4};
        }

        Knight clonePiece (Board b) {
            Knight newPiece = b.new Knight(player);
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

        Rook clonePiece (Board b) {
            Rook newPiece = b.new Rook(player);
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

        Queen clonePiece (Board b) {
            Queen newPiece = b.new Queen(player);
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

        King clonePiece (Board b) {
            King newPiece = b.new King(player);
            if (moved) newPiece.moved();
            return newPiece;
        }
    }

    /***********************************************/
    /***********************************************/
    /***********************************************/

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
            newPiece = p.clonePiece(Board.this);
        }

        void setNextMove(Move m) {
            next = m;
        }
    }

    /***********************************************/
    /***********************************************/
    /***********************************************/

    class Position {
        boolean exists;
        int row, col;

        Position (int r, int c, boolean e) {
            row = r;
            col = c;
            exists = e;
        }

        Position (int r, int c) {
            this(r, c, true);
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

        boolean equals(int r, int c) {
            return (row == r) && (col == c) && exists;
        }

        boolean equals(Position pos) {
            return (!exists && !pos.exists) || ((exists && pos.exists) && (row == pos.row) && (col == pos.col));
        }

        void setRow(int r) {
        assert 0 <= r && r < boardNumRows && exists: 
            "Position out of bounds";
            row = r;
            exists = true;
        }

        void setCol(int c) {
        assert exists && 0 <= c && c < boardNumCols: 
            "Position out of bounds";
            col = c;
            exists = true;
        }

        void setPosition(int r, int c) {
        assert 0 <= r && r < boardNumRows && 0 <= c && c < boardNumCols: 
            "Position out of bounds";
            row = r;
            col = c;
            exists = true;
        }

        void incrementPosition(int r, int c) {
            //assert exists && 0 <= row + r && row + r < boardNumRows && 0 <= col + c && col + c < boardNumCols: "Position out of bounds";
            row += r;
            col += c;
        }

        void incrementPosition(MoveStep ms) {
            incrementPosition(ms.getRowStep(), ms.getColStep());
        }
    }
}
