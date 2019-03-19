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

    Knight clonePiece () {
        Knight newPiece = new Knight(player);
        if (moved) newPiece.moved();
        return newPiece;
    }
}
