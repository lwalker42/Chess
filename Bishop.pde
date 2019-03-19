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
