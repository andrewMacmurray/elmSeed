module Scene.Hub exposing
    ( Destination(..)
    , Model
    , Msg
    , getContext
    , init
    , menuOptions
    , update
    , updateContext
    , view
    )

import Browser.Dom as Dom
import Config.Level as Level
import Context exposing (Context)
import Countdown
import Element exposing (..)
import Element.Info as Info
import Element.Layout as Layout
import Element.Palette as Palette
import Element.Scale as Scale
import Element.Text as Text
import Exit exposing (continue, exitWith)
import Html exposing (Html)
import Lives exposing (Lives)
import Task exposing (Task)
import Utils.Delay exposing (sequence)
import View.Menu as Menu



-- Model


type alias Model =
    { context : Context
    , info : Info.State Level.Id
    }


type Msg
    = ShowLevelInfo Level.Id
    | HideLevelInfo
    | SetInfoState (Info.State Level.Id)
    | SetCurrentLevel Level.Id
    | ScrollHubTo Level.Id
    | ClearCurrentLevel
    | StartLevel Level.Id
    | ExitToLevel Level.Id
    | ExitToGarden
    | ScrolledToLevel


type Destination
    = ToLevel Level.Id
    | ToGarden



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }


menuOptions : List (Menu.Option Msg)
menuOptions =
    [ Menu.option ExitToGarden "Garden"
    ]



-- Init


init : Level.Id -> Context -> ( Model, Cmd Msg )
init level context =
    ( initialState context
    , sequence
        [ ( 1000, ScrollHubTo level )
        , ( 1500, ClearCurrentLevel )
        ]
    )


initialState : Context -> Model
initialState context =
    { context = context
    , info = Info.visible (Level.idFromRaw_ 1 2)
    }



-- Update


update : Msg -> Model -> Exit.With Destination ( Model, Cmd Msg )
update msg model =
    case msg of
        SetInfoState infoWindow ->
            continue { model | info = infoWindow } []

        ShowLevelInfo levelProgress ->
            continue { model | info = Info.visible levelProgress } []

        HideLevelInfo ->
            continue model
                [ sequence
                    [ ( 0, SetInfoState (Info.leaving model.info) )
                    , ( 1000, SetInfoState Info.hidden )
                    ]
                ]

        ScrollHubTo level ->
            continue model [ scrollHubToLevel level ]

        SetCurrentLevel level ->
            continue { model | context = Context.setCurrentLevel level model.context } []

        ClearCurrentLevel ->
            continue { model | context = Context.clearCurrentLevel model.context } []

        ScrolledToLevel ->
            continue model []

        StartLevel level ->
            continue model
                [ sequence
                    [ ( 0, SetCurrentLevel level )
                    , ( 10, SetInfoState (Info.leaving model.info) )
                    , ( 600, SetInfoState Info.hidden )
                    , ( 100, ExitToLevel level )
                    ]
                ]

        ExitToLevel level ->
            exitWith (ToLevel level) model

        ExitToGarden ->
            exitWith ToGarden model


scrollHubToLevel : Level.Id -> Cmd Msg
scrollHubToLevel level =
    Level.toStringId level
        |> Dom.getElement
        |> Task.andThen scrollLevelToView
        |> Task.attempt (always ScrolledToLevel)


scrollLevelToView : Dom.Element -> Task Dom.Error ()
scrollLevelToView { element, viewport } =
    Dom.setViewportOf "hub" 0 <| element.y - viewport.height / 2



-- View


view : Model -> Html Msg
view model =
    Layout.view
        [ inFront (topBar model)
        , inFront (viewInfo model)
        ]
        none



--    div [ handleHideInfo model ]
--        [ renderTopBar model
--        , renderInfo model
--        , div
--            [ id "hub"
--            , style
--                [ height <| toFloat model.context.window.height
--                , paddingTop 60
--                ]
--            , class "w-100 fixed overflow-y-scroll momentum-scroll z-2"
--            ]
--            (renderWorlds model)
--        ]
--
--


topBar : Model -> Element msg
topBar model =
    column
        [ width fill
        , Palette.background1
        , padding Scale.small
        ]
        [ el [ centerX, scale 0.5 ] (html (Lives.view model.context.lives))
        , el [ centerX ] (countdown model.context.lives)
        ]


countdown : Lives -> Element msg
countdown lives =
    case Lives.timeTillNextLife lives of
        Nothing ->
            Text.text [ Text.small ] "Full Life"

        Just t ->
            row []
                [ Text.text [ Text.small ] "Next life in: "
                , Text.text [ Text.small, Text.color Palette.pinkRed ] (Countdown.view t)
                ]



-- Info


viewInfo : Model -> Element Msg
viewInfo { info, context } =
    let
        level =
            Info.content info |> Maybe.withDefault Level.first
    in
    case Info.state info of
        Info.Hidden ->
            none

        Info.Visible ->
            Info.view info (Text.text [] "Visible")

        Info.Leaving ->
            Info.view info (Text.text [] "Leaving")



--handleStartLevel : Context -> Level.Id -> Attribute Msg
--handleStartLevel context level =
--    Attribute.applyIf (Lives.remaining context.lives > 0) (onClick <| StartLevel level)
--
--
--infoContent : Context -> Level.Id -> List (Html msg)
--infoContent context level =
--    if Lives.remaining context.lives > 0 then
--        let
--            levelText =
--                Worlds.number level
--                    |> Maybe.map String.fromInt
--                    |> Maybe.map ((++) "Level ")
--                    |> Maybe.withDefault ""
--
--            icons =
--                Worlds.getLevel level
--                    |> Maybe.map infoIcons
--                    |> Maybe.withDefault (span [] [])
--        in
--        [ p [ style [ marginTop 20 ], class "f5 tracked" ] [ text levelText ]
--        , icons
--        , p
--            [ style
--                [ backgroundColor gold
--                , marginBottom 20
--                , marginTop 15
--                ]
--            , class "tracked-mega pv2 ph3 dib br4"
--            ]
--            [ text "PLAY" ]
--        ]
--
--    else
--        renderWaitForNextLife context
--
--
--renderWaitForNextLife : Context -> List (Html msg)
--renderWaitForNextLife context =
--    let
--        timeTillNextLife =
--            Lives.timeTillNextLife context.lives
--                |> Maybe.map renderTime
--                |> Maybe.withDefault ""
--    in
--    [ div [ style [ paddingTop 50, paddingBottom 40 ], class "tracked f4 flex flex-column items-center" ]
--        [ p [ class "ma0" ] [ text "Next life in" ]
--        , p [ style [ color <| rgb 255 226 92, marginTop 25, marginBottom 30 ] ]
--            [ text timeTillNextLife
--            ]
--        , div [ style [ width 40, height 40 ] ] [ Heart.beating ]
--        ]
--    ]
--
--
--infoIcons : Level.Level -> Html msg
--infoIcons level =
--    Level.config level
--        |> .tileSettings
--        |> List.filter Scores.collectible
--        |> List.map renderIcon
--        |> infoIconsContainer
--
--
--infoIconsContainer : List (Html msg) -> Html msg
--infoIconsContainer =
--    div
--        [ style
--            [ marginTop 25
--            , marginBottom 15
--            ]
--        , class "flex justify-center items-end"
--        ]
--
--
--renderIcon : Tile.Setting -> Html msg
--renderIcon { targetScore, tileType } =
--    let
--        tileIcon =
--            case tileType of
--                Rain ->
--                    renderWeather lightBlue
--
--                Sun ->
--                    renderWeather orange
--
--                Seed seed ->
--                    div [ style [ width 35, height 53 ] ] [ Seed.view seed ]
--
--                _ ->
--                    span [] []
--    in
--    div [ class "dib mh3" ]
--        [ div [ class "center flex flex-column" ]
--            [ tileIcon
--            , renderTargetScore targetScore
--            ]
--        ]
--
--
--renderTargetScore : Maybe TargetScore -> Html msg
--renderTargetScore ts =
--    case ts of
--        Just (TargetScore t) ->
--            p [ style [ marginTop 10 ], class "f6 mb0" ] [ text <| String.fromInt t ]
--
--        Nothing ->
--            span [] []
--
--
--renderWeather : String -> Html msg
--renderWeather color =
--    div
--        [ style
--            [ width 25
--            , height 25
--            , marginLeft 2.5
--            , marginRight 2.5
--            , marginBottom 5
--            , background color
--            ]
--        , classes [ "br-100" ]
--        ]
--        []
--
--
--handleHideInfo : Model -> Attribute Msg
--handleHideInfo model =
--    case Info.state model.info of
--        Info.Visible ->
--            onClick HideLevelInfo
--
--        _ ->
--            Attribute.empty
--
--
--
---- Worlds
--
--
--renderWorlds : Model -> List (Html Msg)
--renderWorlds model =
--    List.map (renderWorld model) <| List.reverse Worlds.list
--
--
--renderWorld : Model -> Level.WorldWithLevels -> Html Msg
--renderWorld model { world, levels } =
--    div [ style [ backgroundColor world.backdropColor ], class "pa5 flex" ]
--        [ div
--            [ style [ width 300 ], class "center" ]
--            (List.reverse levels |> List.indexedMap (renderLevel model world))
--        ]
--
--
--renderLevel : Model -> Level.WorldConfig -> Int -> Level.Id -> Html Msg
--renderLevel model config index level =
--    let
--        reachedLevel =
--            Progress.reachedLevel model.context.progress
--
--        levelNumber =
--            Worlds.number level |> Maybe.withDefault 1
--
--        hasReachedLevel =
--            Level.reached reachedLevel level
--
--        isCurrentLevel =
--            level == reachedLevel
--    in
--    div
--        [ styles
--            [ [ width 35
--              , marginTop 50
--              , marginBottom 50
--              , color config.textColor
--              , Style.applyIf hasReachedLevel Style.pointer
--              ]
--            , offsetStyles <| index + 1
--            ]
--        , showInfo level model
--        , class "tc relative"
--        , id <| Level.toStringId level
--        ]
--        [ currentLevelPointer isCurrentLevel
--        , levelIcon level config.seed model
--        , renderNumber levelNumber hasReachedLevel config
--        ]
--
--
--currentLevelPointer : Bool -> Html msg
--currentLevelPointer isCurrentLevel =
--    if isCurrentLevel then
--        div
--            [ style
--                [ top -30
--                , animation "hover" 1500 [ ease, infinite ]
--                ]
--            , class "absolute left-0 right-0"
--            ]
--            [ triangle ]
--
--    else
--        span [] []
--
--
--offsetStyles : Int -> List Style
--offsetStyles levelNumber =
--    Sine.wave
--        { center = [ leftAuto, rightAuto ]
--        , right = [ leftAuto ]
--        , left = []
--        }
--        (levelNumber - 1)
--
--
--renderNumber : Int -> Bool -> Level.WorldConfig -> Html Msg
--renderNumber visibleLevelNumber hasReachedLevel config =
--    if hasReachedLevel then
--        div
--            [ style
--                [ backgroundColor config.textBackgroundColor
--                , marginTop 10
--                , width 25
--                , height 25
--                ]
--            , class "br-100 center flex justify-center items-center"
--            ]
--            [ p [ style [ color config.textCompleteColor ], class "f6" ] [ text <| String.fromInt visibleLevelNumber ] ]
--
--    else
--        p [ style [ color config.textColor ] ]
--            [ text <| String.fromInt visibleLevelNumber ]
--
--
--showInfo : Level.Id -> Model -> Attribute Msg
--showInfo level model =
--    Attribute.applyIf
--        (levelButtonIsActive level model)
--        (onClick (ShowLevelInfo level))
--
--
--levelButtonIsActive : Level.Id -> Model -> Bool
--levelButtonIsActive level model =
--    levelReached level model && Info.isHidden model.info
--
--
--levelReached : Level.Id -> Model -> Bool
--levelReached level model =
--    Level.reached (Progress.reachedLevel model.context.progress) level
--
--
--levelIcon : Level.Id -> Seed -> Model -> Html msg
--levelIcon level seed model =
--    if Level.completed (Progress.reachedLevel model.context.progress) level then
--        Seed.view seed
--
--    else
--        greyedOutSeed
