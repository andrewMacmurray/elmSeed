module Views.Board.Html exposing (..)

import Data.Tiles exposing (growingOrder, isLeaving, leavingOrder, tileColorMap, tilePaddingMap)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseDown, onMouseEnter, onMouseUp)
import Model exposing (..)
import Views.Board.Styles exposing (..)
import Helpers.Style exposing (classes, px, styles, translate)


renderBoard : Model -> Html Msg
renderBoard model =
    boardLayout model
        [ div [] <| renderTiles model ]


renderTiles : Model -> List (Html Msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (renderTile model)


boardLayout : Model -> List (Html Msg) -> Html Msg
boardLayout model =
    div
        [ class "relative z-3 center flex flex-wrap"
        , style
            [ ( "width", px <| boardWidth model )
            , boardOffsetTop model
            ]
        ]


boardWidth : Model -> Float
boardWidth { tileSettings, boardSettings } =
    tileSettings.sizeX * toFloat (boardSettings.sizeX)


renderTile : Model -> Move -> Html Msg
renderTile model (( coord, tile ) as move) =
    div
        [ style <|
            styles
                [ tileWidthHeightStyles model
                , tileCoordsStyles model coord
                , leavingStyles model move
                ]
        , class "dib flex items-center justify-center absolute pointer"
        , hanldeMoveEvents model move
        ]
        [ innerTile model move
        , tracer model move
        ]


handleStop : Model -> List (Attribute Msg)
handleStop model =
    if model.isDragging && model.moveType /= Just Square then
        [ onMouseUp <| StopMove Line ]
    else
        []


hanldeMoveEvents : Model -> Move -> Attribute Msg
hanldeMoveEvents model move =
    if model.isDragging then
        onMouseEnter <| CheckMove move
    else
        onMouseDown <| StartMove move


tracer : Model -> Move -> Html Msg
tracer model (( coord, tile ) as move) =
    div
        [ class <|
            classes
                [ "absolute br-100"
                , tileColorMap tile
                ]
        , style <|
            styles
                [ moveTracerStyles model move
                , [ tilePaddingMap tile ]
                , growingStyles model move
                , enteringStyles model move
                , fallingStyles model move
                ]
        ]
        []


innerTile : Model -> Move -> Html Msg
innerTile model (( coord, tile ) as move) =
    div
        [ class <|
            classes
                [ "br-100 absolute"
                , tileColorMap tile
                ]
        , style <|
            styles
                [ [ tilePaddingMap tile ]
                , draggingStyles model move
                , growingStyles model move
                , enteringStyles model move
                , fallingStyles model move
                ]
        ]
        []