class Champion extends Piece {
    Champion (boolean p) {
        super (p, loadImage(p?"ChessPieces/whiteChampion.png":"ChessPieces/blackChampion.png"));
        MoveStep m1 = new MoveStep(1, 0);
        MoveStep m2 = new MoveStep(-1, 0);
        MoveStep m3 = new MoveStep(0, 1);
        MoveStep m4 = new MoveStep(0, -1);
        MoveStep m5 = new MoveStep(2, 0);
        MoveStep m6 = new MoveStep(-2, 0);
        MoveStep m7 = new MoveStep(0, 2);
        MoveStep m8 = new MoveStep(0, -2);
        MoveStep m9 = new MoveStep(2, 2);
        MoveStep m10 = new MoveStep(2, -2);
        MoveStep m11 = new MoveStep(-2, 2);
        MoveStep m12 = new MoveStep(-2, -2);
        moves = new MoveStep[] {m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12};
        captures = new MoveStep[] {m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12};
    }

    Champion clonePiece () {
        Champion newPiece = new Champion(player);
        if (moved) newPiece.moved();
        return newPiece;
    }
}
