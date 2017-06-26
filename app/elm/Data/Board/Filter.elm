module Data.Board.Filter exposing (..)

import Data.Moves.Type exposing (currentMoveType)
import Data.Tiles exposing (getTileType)
import Dict
import Model exposing (..)


handleSquareMove : Model -> Model
handleSquareMove model =
    { model
        | currentMove = addAllTilesToMove model.currentMove model.board
        , moveType = Just Square
    }


addAllTilesToMove : List Move -> Board -> List Move
addAllTilesToMove currentMove board =
    currentMove
        |> currentMoveType
        |> Maybe.map (allTilesOfType board)
        |> Maybe.withDefault []


allTilesOfType : Board -> TileType -> List Move
allTilesOfType board tileType =
    board
        |> Dict.filter (\_ tile -> getTileType tile == Just tileType)
        |> Dict.toList
