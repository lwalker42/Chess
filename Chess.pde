int numRows = 8, numCols = 8;
int tileSize = 120;

Board chessBoard;

void setup () {
    fullScreen();
    //size(1280, 720);
    strokeWeight(0);
    tileSize = (int)(height/numRows*.9);
    chessBoard = new Board(numRows, numCols, tileSize);
    chessBoard.addPiece(0, 2, new Rook(false));
    chessBoard.addPiece(0, 1, new Knight(false));
    chessBoard.addPiece(0, 0, new Bishop(false));
    chessBoard.addPiece(0, 4, new Queen(false));
    chessBoard.addPiece(0, 3, new King(false));
    chessBoard.addPiece(0, 5, new Bishop(false));
    chessBoard.addPiece(0, 6, new Knight(false));
    chessBoard.addPiece(0, 7, new Rook(false));
    for (int i = 0; i < numCols; i++)
        chessBoard.addPiece(1, i, new Pawn(false));
    for (int i = 0; i < numCols; i++)
        chessBoard.addPiece(6, i, new Pawn(true));
    chessBoard.addPiece(7, 0, new Rook(true));
    chessBoard.addPiece(7, 1, new Knight(true));
    chessBoard.addPiece(7, 2, new Bishop(true));
    chessBoard.addPiece(7, 3, new Queen(true));
    chessBoard.addPiece(7, 6, new King(true));
    chessBoard.addPiece(7, 7, new Bishop(true));
    chessBoard.addPiece(7, 4, new Knight(true));
    chessBoard.addPiece(7, 5, new Rook(true));
    chessBoard.initBoard();
}

void draw () {
    background(175);
    translate(width/2, height/2);
    chessBoard.drawBoard();
}

void keyPressed() { 
    if (key == ' ') chessBoard.flip();
    else if (key == 'r') chessBoard.resetBoard();
}

void mousePressed() { 
    chessBoard.selectTile();
}
