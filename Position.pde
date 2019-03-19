class Position {
    boolean exists;
    int row, col;

    Position (int r, int c, boolean e) {
        row = r;
        col = c;
        exists = e;
    }

    Position (int r, int c) {
        this(r, c, true);
    }

    Position () {
        exists = false;
    }

    Position clonePosition () {
        return new Position (row, col, exists);
    }

    void clear() {
        exists = false;
    }

    boolean isValid() {
        return exists;
    }

    int getRow() {
        return row;
    }

    int getCol() {
        return col;
    }

    boolean equals(int r, int c) {
        return (row == r) && (col == c) && exists;
    }

    boolean equals(Position pos) {
        return (!exists && !pos.exists) || ((exists && pos.exists) && (row == pos.row) && (col == pos.col));
    }

    void setRow(int r) {
        row = r;
        exists = true;
    }

    void setCol(int c) {
        col = c;
        exists = true;
    }

    void setPosition(int r, int c) {
        row = r;
        col = c;
        exists = true;
    }

    void incrementPosition(int r, int c) {
        row += r;
        col += c;
    }

    void incrementPosition(MoveStep ms) {
        incrementPosition(ms.getRowStep(), ms.getColStep());
    }
}
