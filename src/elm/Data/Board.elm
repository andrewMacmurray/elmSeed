module Data.Board exposing
    ( blocks
    , coords
    , currentMoveType
    , currentMoves
    , filter
    , filterBlocks
    , findBlockAt
    , fromMoves
    , fromTiles
    , inCurrentMoves
    , isEmpty
    , lastMove
    , moves
    , place
    , placeAt
    , placeMoves
    , secondLastMove
    , size
    , update
    , updateAt
    , updateBlocks
    )

import Data.Board.Block as Block
import Data.Board.Coord as Coord
import Data.Board.Move as Move
import Data.Board.Tile as Tile
import Data.Board.Types exposing (Block, Board, BoardDimensions, Coord, Move)
import Dict
import Helpers.Dict



-- Update


updateAt : Coord -> (Block -> Block) -> Board -> Board
updateAt coord f =
    Dict.update coord <| Maybe.map f


placeMoves : Board -> List Move -> Board
placeMoves =
    List.foldl place


placeAt : Coord -> Block -> Board -> Board
placeAt coord block =
    Move.move coord block |> place


place : Move -> Board -> Board
place move =
    Dict.update (Move.coord move) <| Maybe.map (always <| Move.block move)


updateBlocks : (Block -> Block) -> Board -> Board
updateBlocks f =
    update <| always f


update : (Coord -> Block -> Block) -> Board -> Board
update =
    Dict.map


filterBlocks : (Block -> Bool) -> Board -> Board
filterBlocks f =
    filter <| always f


filter : (Coord -> Block -> Bool) -> Board -> Board
filter =
    Dict.filter



-- Query


size : Board -> Int
size =
    Dict.size


isEmpty : Board -> Bool
isEmpty =
    Dict.isEmpty


coords : Board -> List Coord
coords =
    Dict.keys


blocks : Board -> List Block
blocks =
    Dict.values


moves : Board -> List Move
moves =
    Dict.toList


findBlockAt : Coord -> Board -> Maybe Block
findBlockAt =
    Dict.get


matchBlock : (Block -> Bool) -> Board -> Maybe Move
matchBlock =
    Helpers.Dict.findValue



-- Moves


currentMoves : Board -> List Move
currentMoves =
    filterBlocks Block.isDragging
        >> moves
        >> List.sortBy (Move.block >> Block.moveOrder)


currentMoveType : Board -> Maybe Tile.TileType
currentMoveType =
    filterBursts
        >> matchBlock Block.isDragging
        >> Maybe.andThen Move.tileType


filterBursts : Board -> Board
filterBursts =
    filterBlocks (not << Block.isBurst)


inCurrentMoves : Move -> Board -> Bool
inCurrentMoves move =
    currentMoves >> List.member move


lastMove : Board -> Move
lastMove =
    matchBlock Block.isCurrentMove >> Maybe.withDefault Move.empty


secondLastMove : Board -> Maybe Move
secondLastMove =
    currentMoves
        >> List.reverse
        >> List.drop 1
        >> List.head



-- Create


fromTiles : BoardDimensions -> List Tile.TileType -> Board
fromTiles boardDimensions tiles =
    tiles
        |> List.map Block.static
        |> List.map2 Move.move (makeCoords boardDimensions)
        |> fromMoves


makeCoords : BoardDimensions -> List Coord
makeCoords { x, y } =
    Coord.rangeXY (range x) (range y)


range : Int -> List Int
range n =
    List.range 0 (n - 1)


fromMoves : List Move -> Board
fromMoves =
    Dict.fromList
