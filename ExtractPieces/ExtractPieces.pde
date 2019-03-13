size(792, 264);
PImage pieces = loadImage("../ChessPieces/ChessPiecesAll.png");
//clear();
image(pieces, 0, 0);
pieces.get(0, 0, 792/6, 264/2).save("../ChessPieces/whiteRook.png");
pieces.get(792/6, 0, 792/6, 264/2).save("../ChessPieces/whiteKnight.png");
pieces.get(2*792/6, 0, 792/6, 264/2).save("../ChessPieces/whiteBishop.png");
pieces.get(3*792/6, 0, 792/6, 264/2).save("../ChessPieces/whiteQueen.png");
pieces.get(4*792/6, 0, 792/6, 264/2).save("../ChessPieces/whiteKing.png");
pieces.get(5*792/6, 0, 792/6, 264/2).save("../ChessPieces/whitePawn.png");

pieces.get(0, 264/2, 792/6, 264/2).save("../ChessPieces/blackRook.png");
pieces.get(792/6, 264/2, 792/6, 264/2).save("../ChessPieces/blackKnight.png");
pieces.get(2*792/6, 264/2, 792/6, 264/2).save("../ChessPieces/blackBishop.png");
pieces.get(3*792/6, 264/2, 792/6, 264/2).save("../ChessPieces/blackQueen.png");
pieces.get(4*792/6, 264/2, 792/6, 264/2).save("../ChessPieces/blackKing.png");
pieces.get(5*792/6, 264/2, 792/6, 264/2).save("../ChessPieces/blackPawn.png");
