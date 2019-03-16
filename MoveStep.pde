class MoveStep {
    int rowStep, colStep;
    MoveStep[] next = null;
    boolean intermediateStep = false;

    MoveStep (int r, int c) {
        rowStep = r;
        colStep = c;
    }
    
    int getRowStep() {
        return rowStep;
    }

    int getColStep() {
        return colStep;
    }
    
    void setIntermediate(boolean m) {
        intermediateStep = m;
    }

    boolean isIntermediate() {
        return intermediateStep;
    }

    MoveStep[] getNextMove() {
        return next;
    }

    void setNextMove(MoveStep m) {
        next = new MoveStep[] {m};
    }

    void setNextMove(MoveStep[] m) {
        next = m;
    }
}
