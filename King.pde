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
