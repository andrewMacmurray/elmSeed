module Data.Levels exposing
    ( Cache
    , Id
    , Level
    , LevelConfig
    , Tutorial(..)
    , World
    , WorldConfig
    , Worlds
    , completed
    , config
    , empty
    , fromCache
    , getKeysForWorld
    , getLevel
    , getLevels
    , idFromRaw_
    , isFirstLevelOfWorld
    , isLastLevelOfWorld
    , level
    , next
    , number
    , previous
    , reached
    , seedType
    , toCache
    , toStringId
    , tutorial
    , withTutorial
    , world
    , worlds
    , worldsList
    )

import Css.Color exposing (Color)
import Data.Board.Types exposing (BoardDimensions, Coord, SeedType, TileType)
import Data.Board.Wall as Wall
import Data.Level.Setting.Start as Start
import Data.Level.Setting.Tile as Tile exposing (Probability, TargetScore)
import Dict exposing (Dict)



-- Level Id


type Id
    = Id Cache


type alias Cache =
    { worldId : Int
    , levelId : Int
    }


fromCache : Cache -> Id
fromCache { worldId, levelId } =
    Id <| Cache worldId levelId


toCache : Id -> Cache
toCache key =
    { worldId = worldId_ key
    , levelId = levelId_ key
    }


empty : Id
empty =
    idFromRaw_ 1 1


toStringId : Id -> String
toStringId key =
    String.join "-"
        [ "world"
        , String.fromInt <| worldId_ key
        , "level"
        , String.fromInt <| levelId_ key
        ]



-- Query Worlds


type Worlds
    = Worlds (Dict Int World)


type World
    = World
        { levels : Levels
        , seedType : SeedType
        , backdropColor : Color
        , textColor : Color
        , textCompleteColor : Color
        , textBackgroundColor : Color
        }


type alias WorldConfig =
    { seedType : SeedType
    , backdropColor : Color
    , textColor : Color
    , textCompleteColor : Color
    , textBackgroundColor : Color
    }


type alias Levels =
    Dict Int Level


type Level
    = Level
        { tiles : List Tile.Setting
        , walls : List Wall.Config
        , startTiles : List Start.Tile
        , boardDimensions : BoardDimensions
        , moves : Int
        , tutorial : Maybe Tutorial
        }


type alias LevelConfig =
    { tileSettings : List Tile.Setting
    , walls : List Wall.Config
    , startTiles : List Start.Tile
    , boardDimensions : BoardDimensions
    , moves : Int
    }


type Tutorial
    = Sun
    | Rain
    | Seed
    | SeedPod



-- Query Worlds And Levels with Key


getLevel : Worlds -> Id -> Maybe Level
getLevel worlds_ id =
    worlds_
        |> getWorld_ id
        |> Maybe.map unboxLevels_
        |> Maybe.andThen (getLevel_ id)


getLevels : Worlds -> Id -> Maybe (List Level)
getLevels worlds_ id =
    worlds_
        |> getWorld_ id
        |> Maybe.map (unboxLevels_ >> Dict.toList >> List.map Tuple.second)


getKeysForWorld : Worlds -> Id -> Maybe (List Id)
getKeysForWorld worlds_ id =
    worlds_
        |> getWorld_ id
        |> Maybe.map (unboxLevels_ >> levelKeys (worldId_ id))


getWorld_ : Id -> Worlds -> Maybe World
getWorld_ id worlds_ =
    Dict.get (worldId_ id) (unboxWorlds_ worlds_)


getLevel_ : Id -> Levels -> Maybe Level
getLevel_ id levels =
    Dict.get (levelId_ id) levels


isLastLevelOfWorld : Worlds -> Id -> Bool
isLastLevelOfWorld worlds_ id =
    worlds_
        |> getWorld_ id
        |> Maybe.map unboxLevels_
        |> Maybe.map (\l -> Dict.size l == levelId_ id)
        |> Maybe.withDefault False


isFirstLevelOfWorld : Id -> Bool
isFirstLevelOfWorld id =
    levelId_ id == 1


next : Worlds -> Id -> Id
next worlds_ id =
    if isLastLevelOfWorld worlds_ id then
        idFromRaw_ (worldId_ id + 1) 1

    else
        idFromRaw_ (worldId_ id) (levelId_ id + 1)


previous : Worlds -> Id -> Id
previous worlds_ id =
    if isFirstLevelOfWorld id then
        let
            wId =
                worldId_ id - 1

            lId =
                getWorldSizeFromIndex_ worlds_ wId |> Maybe.withDefault 1
        in
        idFromRaw_ wId lId

    else
        idFromRaw_ (worldId_ id) (levelId_ id - 1)


reached : Id -> Id -> Bool
reached (Id current) (Id target) =
    current.worldId > target.worldId || (current.worldId == target.worldId && current.levelId >= target.levelId)


completed : Id -> Id -> Bool
completed (Id current) (Id target) =
    current.worldId > target.worldId || (current.worldId == target.worldId && current.levelId > target.levelId)


tutorial : Worlds -> Id -> Maybe Tutorial
tutorial worlds_ =
    getLevel worlds_ >> Maybe.andThen tutorial_


tutorial_ : Level -> Maybe Tutorial
tutorial_ (Level l) =
    l.tutorial


config : Level -> LevelConfig
config (Level l) =
    { tileSettings = l.tiles
    , startTiles = l.startTiles
    , walls = l.walls
    , boardDimensions = l.boardDimensions
    , moves = l.moves
    }


seedType : Worlds -> Id -> Maybe SeedType
seedType worlds_ id =
    worlds_
        |> getWorld_ id
        |> Maybe.map (\(World w) -> w.seedType)



-- Construct Worlds And Levels


worlds : List World -> Worlds
worlds =
    List.indexedMap (\i w -> ( i + 1, w ))
        >> Dict.fromList
        >> Worlds


world : WorldConfig -> List Level -> World
world c levels =
    World
        { seedType = c.seedType
        , backdropColor = c.backdropColor
        , textColor = c.textColor
        , textCompleteColor = c.textCompleteColor
        , textBackgroundColor = c.textBackgroundColor
        , levels = makeLevels_ levels
        }


makeLevels_ : List Level -> Levels
makeLevels_ levels =
    levels
        |> List.indexedMap (\i l -> ( i + 1, l ))
        |> Dict.fromList


level : LevelConfig -> Level
level l =
    Level
        { tiles = l.tileSettings
        , walls = l.walls
        , startTiles = l.startTiles
        , boardDimensions = l.boardDimensions
        , moves = l.moves
        , tutorial = Nothing
        }


withTutorial : Tutorial -> LevelConfig -> Level
withTutorial t l =
    Level
        { tiles = l.tileSettings
        , walls = l.walls
        , startTiles = l.startTiles
        , boardDimensions = l.boardDimensions
        , moves = l.moves
        , tutorial = Just t
        }



-- World Data


number : Worlds -> Id -> Maybe Int
number worlds_ id =
    if levelExists worlds_ id then
        (worldId_ id - 1)
            |> List.range 1
            |> List.map (getWorldSizeFromIndex_ worlds_)
            |> List.foldr accumulateSize (levelId_ id)
            |> Just

    else
        Nothing


accumulateSize : Maybe Int -> Int -> Int
accumulateSize size total =
    total + Maybe.withDefault 0 size


getWorldSizeFromIndex_ : Worlds -> Int -> Maybe Int
getWorldSizeFromIndex_ worlds_ i =
    getWorld_ (idFromRaw_ i 1) worlds_ |> Maybe.map worldSize


worldsList : Worlds -> List ( WorldConfig, List Id )
worldsList worlds_ =
    worlds_
        |> unboxWorlds_
        |> Dict.toList
        |> List.map configWithKeys


configWithKeys : ( Int, World ) -> ( WorldConfig, List Id )
configWithKeys ( worldIndex, world_ ) =
    ( worldConfig world_
    , levelKeys worldIndex <| unboxLevels_ world_
    )


levelKeys : Int -> Levels -> List Id
levelKeys worldIndex levels =
    levels
        |> Dict.toList
        |> List.map Tuple.first
        |> List.map (idFromRaw_ worldIndex)


worldSize : World -> Int
worldSize =
    Dict.size << unboxLevels_



-- Helpers


worldConfig : World -> WorldConfig
worldConfig (World w) =
    { seedType = w.seedType
    , backdropColor = w.backdropColor
    , textColor = w.textColor
    , textCompleteColor = w.textCompleteColor
    , textBackgroundColor = w.textBackgroundColor
    }


levelExists : Worlds -> Id -> Bool
levelExists w id =
    case getLevel w id of
        Nothing ->
            False

        _ ->
            True


unboxLevels_ : World -> Levels
unboxLevels_ (World w) =
    w.levels


levelId_ : Id -> Int
levelId_ (Id { levelId }) =
    levelId


unboxWorlds_ : Worlds -> Dict Int World
unboxWorlds_ (Worlds w) =
    w


worldId_ : Id -> Int
worldId_ (Id { worldId }) =
    worldId


idFromRaw_ : Int -> Int -> Id
idFromRaw_ worldId levelId =
    Id <| Cache worldId levelId
