class Pawn extends Piece {
        Pawn (boolean p) {
            super (p, loadImage(p?"ChessPieces/whitePawn.png":"ChessPieces/blackPawn.png"));
            MoveStep m1 = new MoveStep(-1, 0);
            MoveStep m2 = new MoveStep(-1, -1);
            MoveStep m3 = new MoveStep(-1, 1);
            moves = new MoveStep[] {m1};
            captures = new MoveStep[] {m2, m3};
        }

        Pawn clonePiece () {
            Pawn newPiece = new Pawn(player);
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
         
            if (board != null && !board.gameMoves.isEmpty()) {
                int r = pos.getRow();
                int c = pos.getCol();
                int dir = player?1:-1;
                Move prev = board.gameMoves.get(board.gameMoves.size() - 1);
                Piece left = board.inBounds(r, c - 1)?board.board[r][c-1]:null;
                Piece right = board.inBounds(r, c + 1)?board.board[r][c+1]:null;
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
