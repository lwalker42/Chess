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
