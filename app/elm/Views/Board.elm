module Views.Board exposing (..)

import Data.Tiles exposing (tilePaddingMap, tileToCssClass)
import Dict
import Helpers.Style exposing (px)
import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (Coord, Model, Msg, Tile)


renderBoard : Model -> Html Msg
renderBoard model =
    model.board
        |> Dict.toList
        |> List.map (renderTile model)
        |> renderContainer model


renderContainer : Model -> List (Html Msg) -> Html Msg
renderContainer model =
    div
        [ class "relative z-3 center mt5 flex flex-wrap"
        , style [ ( "width", px <| boardWidth model ) ]
        ]


boardWidth : Model -> Int
boardWidth { tileSettings, boardSettings } =
    tileSettings.sizeX * boardSettings.sizeX


renderTile : Model -> ( Coord, Tile ) -> Html Msg
renderTile model ( ( x, y ), tile ) =
    div
        [ style <| baseTileStyles model
        , class "dib flex items-center justify-center relative"
        ]
        [ div
            [ class <| "br-100 absolute " ++ tileToCssClass tile
            , style [ ( "padding", tilePaddingMap tile ) ]
            ]
            []
        ]


baseTileStyles : Model -> List ( String, String )
baseTileStyles { tileSettings } =
    [ ( "width", px tileSettings.sizeX )
    , ( "height", px tileSettings.sizeY )
    ]