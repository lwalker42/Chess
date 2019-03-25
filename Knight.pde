class Knight extends Piece { //Can also specify Knight moves with intermediate steps with a move of 2 followed by an orthogonal move of 1 
    Knight (boolean p) {
        super (p, loadImage(p?"ChessPieces/whiteKnight.png":"ChessPieces/blackKnight.png"));
        MoveStep m1 = new MoveStep(2, 1);
        MoveStep m2 = new MoveStep(2, -1);
        MoveStep m3 = new MoveStep(-2, 1);
        MoveStep m4 = new MoveStep(-2, -1);
        MoveStep m5 = new MoveStep(1, 2);
        MoveStep m6 = new MoveStep(-1, 2);
        MoveStep m7 = new MoveStep(1, -2);
        MoveStep m8 = new MoveStep(-1, -2);
        moves = new MoveStep[] {m1, m2, m3, m4, m5, m6, m7, m8};
        captures = new MoveStep[] {m1, m2, m3, m4, m5, m6, m7, m8};
    }

    Knight clonePiece () {
        Knight newPiece = new Knight(player);
        if (moved) newPiece.moved();
        return newPiece;
    }
}
