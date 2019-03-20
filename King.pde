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

        ArrayList<Move> getMoves(Position pos, boolean capture) {
            ArrayList<Move> possibleMoves = super.getMoves(pos, capture);
            
            if(!capture && !moved && !board.inCheck(player)) {
                int row = pos.getRow();
                int col = pos.getCol();
                for (int c = 0; c < board.boardNumCols; c++) {
                    Piece p = board.getPiece(row, c);
                    if (p != null && !(player ^ p.getPlayer()) && p instanceof Rook && !p.moved) {
                        boolean left = true; //allows for Chess 960 compatability
                        for (int k = 0; k < c; k++) {
                            Piece temp = board.getInitPiece(row, k);
                            if (temp != null && !(player ^ temp.getPlayer()) && temp instanceof Rook) {
                                left = false;
                                break;
                            }
                        }
                        boolean clear = true;
                        for (int k = min(col, board.boardNumCols/2 + (left?-2:2)); k <= max(col, board.boardNumCols/2 + (left?-2:2)); k++) {
                            if (col == k) continue;
                            if (!board.isOccupied(row, k) || board.getPiece(row, k) == this || board.getPiece(row, k) == p){
                                Move m = new Move(row, col, row, k);
                                //print("row: " + row + ", col: " + col + ", row: " + row + ", k: " + k + "\n");
                                m.setNewPiece(this);
                                m.setCaptured(row, k);
                                if (board.tryMove(m).inCheck(player)) {
                                    clear = false;
                                    break;
                                }
                            } else {
                                clear = false;
                                break;
                            }
                        }
                        if (clear) {
                            for (int k = min(c, board.boardNumCols/2 + (left?-1:1)); k <= max(c, board.boardNumCols/2 + (left?-1:1)); k++) {
                                if (c == k) continue;
                                if (board.isOccupied(row, k) && !(board.getPiece(row, k) == this || board.getPiece(row, k) == p)) {
                                    clear = false;
                                    break;
                                }
                            }
                        }
                        if (clear) {
                            Move mK = new Move(row, col, row, board.boardNumCols/2 + (left?-2:2));
                            mK.setNewPiece(this);
                            mK.setCaptured(row, c);
                            Move mR = new Move(row, c, row, board.boardNumCols/2 + (left?-1:1));
                            mR.setNewPiece(p);
                            mK.setNextMove(mR);
                            possibleMoves.add(mK);
                        }
                    }
                }
            }
            
            return possibleMoves;
        }
}
