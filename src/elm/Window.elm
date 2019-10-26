module Window exposing
    ( Size(..)
    , Width(..)
    , Window
    , padding
    , size
    , width
    )

-- Window


type alias Window =
    { width : Int
    , height : Int
    }


type Size
    = Small
    | Medium
    | Large


type Width
    = Narrow
    | MediumWidth
    | Wide



-- Query


size : Window -> Size
size window =
    if smallestDimension window < 480 then
        Small

    else if smallestDimension window > 480 && smallestDimension window < 720 then
        Medium

    else
        Large


width window =
    if window.width >= 980 then
        Wide

    else if window.width >= 580 && window.width < 980 then
        MediumWidth

    else
        Narrow



-- Config


padding : number
padding =
    35



-- Helpers


smallestDimension : Window -> Int
smallestDimension window =
    if window.height >= window.width then
        window.width

    else
        window.height
