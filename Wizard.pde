class Wizard extends Piece {
    Wizard (boolean p) {
        super (p, loadImage(p?"ChessPieces/whiteWizard.png":"ChessPieces/blackWizard.png"));
        MoveStep m1 = new MoveStep(1, 1);
        MoveStep m2 = new MoveStep(1, -1);
        MoveStep m3 = new MoveStep(-1, 1);
        MoveStep m4 = new MoveStep(-1, -1);
        m1.setIntermediate(true);
        m2.setIntermediate(true);
        m3.setIntermediate(true);
        m4.setIntermediate(true);
        MoveStep[] m5 = new MoveStep[] {new MoveStep(0, 2), new MoveStep(0, -2), new MoveStep(2, 0), new MoveStep(-2, 0)};
        m1.setNextMove(m5);
        m2.setNextMove(m5);
        m3.setNextMove(m5);
        m4.setNextMove(m5);
        moves = new MoveStep[] {m1, m2, m3, m4};
        captures = new MoveStep[] {m1, m2, m3, m4};
    }

    Wizard clonePiece () {
        Wizard newPiece = new Wizard(player);
        if (moved) newPiece.moved();
        return newPiece;
    }
}
