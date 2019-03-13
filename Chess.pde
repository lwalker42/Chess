int numRows = 8, numCols = 8;
int tileSize = 120;

Board board;

void setup () {
    fullScreen();
    //size(1280, 720);
    strokeWeight(0);
    print(height);
    tileSize = (int)(height/numRows*.9);
    board = new Board(numRows, numCols, tileSize);
    board.addPiece(board.new Rook(0, 0, false));
    board.addPiece(board.new Knight(0, 1, false));
    board.addPiece(board.new Bishop(0, 2, false));
    board.addPiece(board.new Queen(0, 3, false));
    board.addPiece(board.new King(0, 4, false));
    board.addPiece(board.new Bishop(0, 5, false));
    board.addPiece(board.new Knight(0, 6, false));
    board.addPiece(board.new Rook(0, 7, false));
    for (int i = 0; i < numCols; i++)
        board.addPiece(board.new Pawn(1, i, false));
    for (int i = 0; i < numCols; i++)
        board.addPiece(board.new Pawn(6, i, true));
    board.addPiece(board.new Rook(7, 0, true));
    board.addPiece(board.new Knight(7, 1, true));
    board.addPiece(board.new Bishop(7, 2, true));
    board.addPiece(board.new Queen(7, 3, true));
    board.addPiece(board.new King(7, 4, true));
    board.addPiece(board.new Bishop(7, 5, true));
    board.addPiece(board.new Knight(7, 6, true));
    board.addPiece(board.new Rook(7, 7, true));
    board.initBoard();
}

void draw () {
    background(175);
    translate(width/2, height/2);
    board.drawBoard();
    board.drawMoves();
}

float mouseXAdjusted() {
    return mouseX - width/2.;
}

float mouseYAdjusted() {
    return mouseY - height/2.;
}

void keyPressed() { 
    if (key == ' ') board.flip();
}

void mousePressed() { 
    board.selectTile();
}
