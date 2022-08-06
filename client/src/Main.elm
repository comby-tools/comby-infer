module Main exposing (Msg(..), main, update, view)

import Browser
import Html exposing (a, button, code, div, pre, text, textarea)
import Html.Attributes exposing (cols, href, rows, target)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Url.Builder



-- ROUTES


deployUrl =
    "https://auto-comby.fly.dev"


localUrl =
    "http://localhost:8080"


apiUrl request =
    Url.Builder.crossOrigin deployUrl [ "api" ] [ Url.Builder.string "q" request ]


type alias Model =
    { leftHandSide : String
    , rightHandSide : String
    , response : Maybe Response
    , error : Maybe String
    }


initialModel : Model
initialModel =
    { leftHandSide = "count = 0\nfor e in es:\n count += e\nprint(count)", rightHandSide = "count = np.sum(es)", response = Nothing, error = Nothing }


main =
    Browser.element
        { init =
            \() ->
                ( initialModel, Cmd.none )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = Submit
    | OnResponse (Result Http.Error Response)
    | OnLeftHandSide String
    | OnRightHandSide String


update msg model =
    case msg of
        Submit ->
            let
                request =
                    Encode.object
                        [ ( "left_hand_side", Encode.string model.leftHandSide )
                        , ( "right_hand_side", Encode.string model.rightHandSide )
                        , ( "language", Encode.string "Python" ) -- FIXME Hardcoded
                        , ( "exclude_tokens", Encode.list (\_ -> Encode.string "") [] ) -- TODO
                        ]
            in
            ( model
            , Http.get
                { url = apiUrl (Encode.encode 0 request)
                , expect = Http.expectJson OnResponse responseDecoder
                }
            )

        OnResponse (Ok response) ->
            ( { model | response = Just response }, Cmd.none )

        OnResponse (Err err) ->
            let
                error =
                    case err of
                        Http.BadBody s ->
                            Just ("bad body: " ++ s)

                        _ ->
                            Nothing
            in
            ( { model | error = error }, Cmd.none )

        OnLeftHandSide leftHandSide ->
            ( { model | leftHandSide = leftHandSide }, Cmd.none )

        OnRightHandSide rightHandSide ->
            ( { model | rightHandSide = rightHandSide }, Cmd.none )


view model =
    div []
        [ div [] [ text "left" ]
        , textarea [ onInput OnLeftHandSide, rows 10, cols 80 ] [ text model.leftHandSide ]
        , div [] [ text "right" ]
        , textarea [ onInput OnRightHandSide, rows 10, cols 80 ] [ text model.rightHandSide ]
        , div [] [ button [ onClick Submit ] [ text "submit" ] ]
        , div [] [ text "Output" ]
        , case model.response of
            Just { match, replace } ->
                div []
                    [ pre [] [ code [] [ text match ] ]
                    , pre [] [ code [] [ text "->" ] ]
                    , pre [] [ code [] [ text replace ] ]
                    , div [] []
                    , div [] [ a [ href ("https://comby.live/index.html#" ++ combyLink model.leftHandSide match replace), target "_blank" ] [ text "see in comby.live" ] ]
                    ]

            Nothing ->
                div [] []
        , case model.error of
            Just msg ->
                div [] [ text ("Error: " ++ msg) ]

            Nothing ->
                div [] []
        ]


combyLink source match replace =
    Encode.encode 0
        (Encode.object
            [ ( "source", Encode.string source )
            , ( "match", Encode.string match )
            , ( "rule", Encode.string "where true" )
            , ( "rewrite", Encode.string replace )
            , ( "language", Encode.string ".generic" )
            , ( "substitution_kind", Encode.string "in_place" )
            , ( "id", Encode.int 0 )
            ]
        )


type alias Response =
    { match : String
    , replace : String
    , matches : List Entry
    }


type alias Entry =
    { symbolic : Symbolic
    , concrete : String
    }


type alias Symbolic =
    { type_ : String
    , name : String
    , text : String
    }


responseDecoder : Decode.Decoder Response
responseDecoder =
    Decode.succeed Response
        |> Pipeline.required "Match" Decode.string
        |> Pipeline.required "Replace" Decode.string
        |> Pipeline.required "matches" (Decode.list entryDecoder)


entryDecoder : Decode.Decoder Entry
entryDecoder =
    Decode.succeed Entry
        |> Pipeline.required "_1" symbolicDecoder
        |> Pipeline.required "_2" Decode.string


symbolicDecoder : Decode.Decoder Symbolic
symbolicDecoder =
    Decode.succeed Symbolic
        |> Pipeline.required "type" Decode.string
        |> Pipeline.required "Name" Decode.string
        |> Pipeline.required "Text" Decode.string
