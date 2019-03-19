int numRows = 8, numCols = 8;
int tileSize = 120;

Board board;

void setup () {
    fullScreen();
    //size(1280, 720);
    strokeWeight(0);
    tileSize = (int)(height/numRows*.9);
    board = new Board(numRows, numCols, tileSize);
    board.addPiece(0, 0, board.new Rook(false));
    board.addPiece(0, 1, board.new Knight(false));
    board.addPiece(0, 2, board.new Bishop(false));
    board.addPiece(0, 3, board.new Queen(false));
    board.addPiece(0, 4, board.new King(false));
    board.addPiece(0, 5, board.new Bishop(false));
    board.addPiece(0, 6, board.new Knight(false));
    board.addPiece(0, 7, board.new Rook(false));
    for (int i = 0; i < numCols; i++)
        board.addPiece(1, i, board.new Pawn(false));
    for (int i = 0; i < numCols; i++)
        board.addPiece(6, i, board.new Pawn(true));
    board.addPiece(7, 0, board.new Rook(true));
    board.addPiece(7, 1, board.new Knight(true));
    board.addPiece(7, 2, board.new Bishop(true));
    board.addPiece(7, 3, board.new Queen(true));
    board.addPiece(7, 4, board.new King(true));
    board.addPiece(7, 5, board.new Bishop(true));
    board.addPiece(7, 6, board.new Knight(true));
    board.addPiece(7, 7, board.new Rook(true));
    board.initBoard();
}

void draw () {
    background(175);
    translate(width/2, height/2);
    board.drawBoard();
}

void keyPressed() { 
    if (key == ' ') board.flip();
    else if (key == 'r') board.resetBoard();
}

void mousePressed() { 
    board.selectTile();
}
