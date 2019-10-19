module Data.Board.Tile exposing
    ( addBearing
    , baseSizeX
    , baseSizeY
    , clearBurstType
    , getSeedType
    , getTileType
    , growSeedPod
    , growingOrder
    , hasLine
    , hash
    , isBurst
    , isCurrentMove
    , isDragging
    , isEmpty
    , isFalling
    , isGrowing
    , isLeaving
    , isSeed
    , leavingOrder
    , map
    , moveOrder
    , removeBearing
    , scale
    , seedName
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
    )

import Data.Board.Types exposing (..)
import Data.Window as Window


map : a -> (TileType -> a) -> TileState -> a
map default fn =
    getTileType
        >> Maybe.map fn
        >> Maybe.withDefault default


growingOrder : TileState -> Int
growingOrder tileState =
    case tileState of
        Growing _ order ->
            order

        _ ->
            0


leavingOrder : TileState -> Int
leavingOrder tileState =
    case tileState of
        Leaving _ order ->
            order

        _ ->
            0


isEmpty : TileState -> Bool
isEmpty tileState =
    case tileState of
        Empty ->
            True

        _ ->
            False


isLeaving : TileState -> Bool
isLeaving tileState =
    case tileState of
        Leaving _ _ ->
            True

        _ ->
            False


isDragging : TileState -> Bool
isDragging tileState =
    case tileState of
        Dragging _ _ _ ->
            True

        _ ->
            False


isGrowing : TileState -> Bool
isGrowing tileState =
    case tileState of
        Growing _ _ ->
            True

        _ ->
            False


isFalling : TileState -> Bool
isFalling tileState =
    case tileState of
        Falling _ _ ->
            True

        _ ->
            False


hasLine : TileState -> Bool
hasLine tileState =
    case tileState of
        Dragging _ _ Left ->
            True

        Dragging _ _ Right ->
            True

        Dragging _ _ Up ->
            True

        Dragging _ _ Down ->
            True

        _ ->
            False


moveOrder : TileState -> Int
moveOrder tileState =
    case tileState of
        Dragging _ moveOrder_ _ ->
            moveOrder_

        _ ->
            0


isCurrentMove : TileState -> Bool
isCurrentMove tileState =
    case tileState of
        Dragging _ _ Head ->
            True

        _ ->
            False


setToDragging : MoveOrder -> TileState -> TileState
setToDragging moveOrder_ tileState =
    case tileState of
        Static tileType ->
            Dragging tileType moveOrder_ Head

        Active tileType ->
            Dragging tileType moveOrder_ Head

        x ->
            x


setToActive : TileState -> TileState
setToActive tileState =
    case tileState of
        Static tileType ->
            Active tileType

        x ->
            x


setActiveToStatic : TileState -> TileState
setActiveToStatic tileState =
    case tileState of
        Active tileType ->
            Static tileType

        x ->
            x


removeBearing : TileState -> TileState
removeBearing tileState =
    case tileState of
        Dragging tileType moveOrder_ _ ->
            Dragging tileType moveOrder_ Head

        x ->
            x


setStaticToFirstMove : TileState -> TileState
setStaticToFirstMove tileState =
    case tileState of
        Static tileType ->
            Dragging tileType 1 Head

        x ->
            x


addBearing : Bearing -> TileState -> TileState
addBearing bearing tileState =
    case tileState of
        Dragging tileType moveOrder_ _ ->
            Dragging tileType moveOrder_ bearing

        x ->
            x


setGrowingToStatic : TileState -> TileState
setGrowingToStatic tileState =
    case tileState of
        Growing (Seed seedType) _ ->
            Static (Seed seedType)

        x ->
            x


growSeedPod : SeedType -> TileState -> TileState
growSeedPod seedType tileState =
    case tileState of
        Growing SeedPod n ->
            Growing (Seed seedType) n

        x ->
            x


setDraggingBurstType : TileType -> TileState -> TileState
setDraggingBurstType tileType tileState =
    case tileState of
        Dragging (Burst _) moveOrder_ bearing ->
            Dragging (Burst <| Just tileType) moveOrder_ bearing

        x ->
            x


clearBurstType : TileState -> TileState
clearBurstType tileState =
    case tileState of
        Dragging (Burst _) moveOrder_ bearing ->
            Dragging (Burst Nothing) moveOrder_ bearing

        Leaving (Burst _) moveOrder_ ->
            Leaving (Burst Nothing) moveOrder_

        x ->
            x


setToFalling : Int -> TileState -> TileState
setToFalling fallingDistance tileState =
    case tileState of
        Static tile ->
            Falling tile fallingDistance

        Falling tile _ ->
            Falling tile fallingDistance

        x ->
            x


setEnteringToStatic : TileState -> TileState
setEnteringToStatic tileState =
    case tileState of
        Entering tile ->
            Static tile

        x ->
            x


setFallingToStatic : TileState -> TileState
setFallingToStatic tileState =
    case tileState of
        Falling tile _ ->
            Static tile

        x ->
            x


setLeavingToEmpty : TileState -> TileState
setLeavingToEmpty tileState =
    case tileState of
        Leaving _ _ ->
            Empty

        x ->
            x


setDraggingToStatic : TileState -> TileState
setDraggingToStatic tileState =
    case tileState of
        Dragging tile _ _ ->
            Static <| resetBurstType tile

        x ->
            x


setDraggingToGrowing : TileState -> TileState
setDraggingToGrowing tileState =
    case tileState of
        Dragging SeedPod order _ ->
            Growing SeedPod order

        x ->
            x


setDraggingToLeaving : TileState -> TileState
setDraggingToLeaving tileState =
    case tileState of
        Dragging tile order _ ->
            Leaving tile order

        x ->
            x


getTileType : TileState -> Maybe TileType
getTileType tileState =
    case tileState of
        Static tile ->
            Just tile

        Dragging tile _ _ ->
            Just tile

        Leaving tile _ ->
            Just tile

        Falling tile _ ->
            Just tile

        Entering tile ->
            Just tile

        Growing tile _ ->
            Just tile

        Active tile ->
            Just tile

        Empty ->
            Nothing


isSeed : TileType -> Bool
isSeed tileType =
    case tileType of
        Seed _ ->
            True

        _ ->
            False


isBurst : TileType -> Bool
isBurst tileType =
    case tileType of
        Burst _ ->
            True

        _ ->
            False


resetBurstType : TileType -> TileType
resetBurstType tileType =
    case tileType of
        Burst _ ->
            Burst Nothing

        x ->
            x


getSeedType : TileType -> Maybe SeedType
getSeedType tileType =
    case tileType of
        Seed seedType ->
            Just seedType

        _ ->
            Nothing


hash : TileType -> String
hash tileType =
    case tileType of
        Rain ->
            "Rain"

        Sun ->
            "Sun"

        SeedPod ->
            "SeedPod"

        Seed seedType ->
            seedName seedType

        Burst tile ->
            hashBurst tile


hashBurst : Maybe TileType -> String
hashBurst =
    Maybe.map (\tile -> "Burst" ++ hash tile) >> Maybe.withDefault "BurstEmpty"


seedName : SeedType -> String
seedName seedType =
    case seedType of
        Sunflower ->
            "Sunflower"

        Chrysanthemum ->
            "Chrysanthemum"

        Cornflower ->
            "Cornflower"

        Lupin ->
            "Lupin"

        Marigold ->
            "Marigold"

        Rose ->
            "Rose"


scale : Window.Window -> Float
scale window =
    case Window.size window of
        Window.Small ->
            0.8

        Window.Medium ->
            0.98

        Window.Large ->
            1.2


baseSizeX : number
baseSizeX =
    55


baseSizeY : number
baseSizeY =
    51
