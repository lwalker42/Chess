class Move {
    int row, col, rowMove, colMove;

    Move (int r, int c, int rDiff, int cDiff) {
        row = r;
        col = c;
        rowMove = rDiff;
        colMove = cDiff;
    }

    int getRow() {
        return row;
    }

    void setRow(int r) {
        row = r;
    }

    int getCol() {
        return col;
    }

    void setCol(int c) {
        col = c;
    }

    int getRowMove() {
        return rowMove;
    }

    void setRowMove(int rm) {
        rowMove = rm;
    }

    int getColMove() {
        return colMove;
    }

    void setColMove(int cm) {
        colMove = cm;
    }

    int getFinalPosR() {
        return row + rowMove;
    }

    int getFinalPosC() {
        return col + colMove;
    }
}
