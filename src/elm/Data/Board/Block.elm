module Data.Board.Block exposing
    ( addBearing
    , clearBearing
    , clearBurstType
    , empty
    , fold
    , getTileState
    , growSeedPod
    , growingOrder
    , hasLine
    , isBurst
    , isCurrentMove
    , isDragging
    , isEmpty
    , isFalling
    , isGrowing
    , isLeaving
    , isWall
    , leavingOrder
    , map
    , moveOrder
    , setActiveToStatic
    , setDraggingBurstType
    , setDraggingToGrowing
    , setDraggingToLeaving
    , setDraggingToStatic
    , setEnteringToStatic
    , setFallingToStatic
    , setGrowingToStatic
    , setLeavingToEmpty
    , setStaticToFirstMove
    , setToActive
    , setToDragging
    , setToFalling
    , static
    , tileType
    )

import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)


growingOrder : Block -> Int
growingOrder =
    fold Tile.growingOrder 0


leavingOrder : Block -> Int
leavingOrder =
    fold Tile.leavingOrder 0


isEmpty : Block -> Bool
isEmpty =
    fold Tile.isEmpty False


isLeaving : Block -> Bool
isLeaving =
    fold Tile.isLeaving False


isDragging : Block -> Bool
isDragging =
    fold Tile.isDragging False


isFalling : Block -> Bool
isFalling =
    fold Tile.isFalling False


isGrowing : Block -> Bool
isGrowing =
    fold Tile.isGrowing False


hasLine : Block -> Bool
hasLine =
    fold Tile.hasLine False


moveOrder : Block -> Int
moveOrder =
    fold Tile.moveOrder 0


isCurrentMove : Block -> Bool
isCurrentMove =
    fold Tile.isCurrentMove False


setToDragging : MoveOrder -> Block -> Block
setToDragging =
    map << Tile.setToDragging


setToActive : Block -> Block
setToActive =
    map Tile.setToActive


setActiveToStatic : Block -> Block
setActiveToStatic =
    map Tile.setActiveToStatic


clearBearing : Block -> Block
clearBearing =
    map Tile.removeBearing


setStaticToFirstMove : Block -> Block
setStaticToFirstMove =
    map Tile.setStaticToFirstMove


addBearing : Bearing -> Block -> Block
addBearing =
    map << Tile.addBearing


setDraggingBurstType : TileType -> Block -> Block
setDraggingBurstType =
    map << Tile.setDraggingBurstType


clearBurstType : Block -> Block
clearBurstType =
    map Tile.clearBurstType


setGrowingToStatic : Block -> Block
setGrowingToStatic =
    map Tile.setGrowingToStatic


growSeedPod : SeedType -> Block -> Block
growSeedPod =
    map << Tile.growSeedPod


setToFalling : Int -> Block -> Block
setToFalling =
    map << Tile.setToFalling


setEnteringToStatic : Block -> Block
setEnteringToStatic =
    map Tile.setEnteringToStatic


setFallingToStatic : Block -> Block
setFallingToStatic =
    map Tile.setFallingToStatic


setLeavingToEmpty : Block -> Block
setLeavingToEmpty =
    map Tile.setLeavingToEmpty


setDraggingToStatic : Block -> Block
setDraggingToStatic =
    map Tile.setDraggingToStatic


setDraggingToGrowing : Block -> Block
setDraggingToGrowing =
    map Tile.setDraggingToGrowing


setDraggingToLeaving : Block -> Block
setDraggingToLeaving =
    map Tile.setDraggingToLeaving


tileType : Block -> Maybe TileType
tileType =
    fold Tile.getTileType Nothing


getTileState : Block -> TileState
getTileState =
    fold identity Empty


isWall : Block -> Bool
isWall block =
    case block of
        Wall _ ->
            True

        _ ->
            False


isBurst : Block -> Bool
isBurst =
    let
        burst =
            Tile.getTileType
                >> Maybe.map Tile.isBurst
                >> Maybe.withDefault False
    in
    fold burst False


static : TileType -> Block
static =
    Static >> Space


empty : Block
empty =
    Space Empty


map : (TileState -> TileState) -> Block -> Block
map f block =
    case block of
        Space tileState ->
            Space <| f tileState

        wall ->
            wall


fold : (TileState -> a) -> a -> Block -> a
fold f default block =
    case block of
        Wall _ ->
            default

        Space tileState ->
            f tileState
