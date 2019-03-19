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
