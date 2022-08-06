let index_route =
  Dream.get "/"
  @@ fun _ ->
  Dream.html
    {|<!DOCTYPE HTML>
<html>
<head>
  <meta charset="UTF-8">
  <title>Server Hosted Dev</title>
  <script src="public/dist/main.js"></script>
</head>
<body>
  <div id="elm"></div>
  <script>Elm.Main.init({ node: elm, flags: { height: window.innerHeight, width: window.innerWidth } });</script>
</body>
</html>
|}

let javascript_route =
  let loader _root path _request =
    match Public.read path with
    | None -> Dream.empty `Not_Found
    | Some script ->
      Dream.respond script
  in
  Dream.get "/public/**" (Dream.static ~loader "")

let binary_path = "../InferRules/build/distributions/InferRules-1.0-SNAPSHOT/bin/InferRules"

module Input = struct
  type t =
    { left_hand_side : string
    ; right_hand_side : string
    ; language : string
    ; exclude_tokens : string list
    }
  [@@deriving yojson]
end

module Output = struct
  type symbolic =
    { type_ : string [@key "type"]
    ; name : string [@key "Name"]
    ; text : string [@key "Text"]
    }
  [@@deriving yojson]

  type entry =
    { symbolic : symbolic [@key "_1"]
    ; concrete : string [@key "_2"]
    }
  [@@deriving yojson]

  type t =
    { match_ : string [@key "Match"]
    ; replace : string [@key "Replace"]
    ; matches : entry list
    }
  [@@deriving yojson]
end

type result = Output.t [@@deriving yojson]

let api_route =
  Dream.get "/api"
  @@ fun request ->
  match Dream.query request "q" with
  | None -> Dream.respond ~code:500 "Unsupported parameter"
  | Some value ->
    (match Input.t_of_yojson (Yojson.Safe.from_string value) with
     | { left_hand_side; right_hand_side; language; exclude_tokens = _ } ->
       let args =
         Format.sprintf "-b '%s' -a '%s' -l '%s'" left_hand_side right_hand_side language
       in
       let cmd = Format.sprintf "%s %s" binary_path args in
       let channel = Unix.open_process_in cmd in
       let result = In_channel.input_all channel in
       In_channel.close channel;
       (match result_of_yojson @@ Yojson.Safe.from_string result with
        | result -> Dream.respond @@ Yojson.Safe.to_string @@ yojson_of_result result
        | exception Yojson.Json_error s ->
          Dream.respond ~code:500 (Format.sprintf "Error converting command output to JSON: %s" s)
        | exception _ -> Dream.respond ~code:500 "Unknown JSON conversion issue")
     | exception _ -> Dream.respond ~code:500 "Error decoding JSON input")

let () = Dream.run ~interface:"0.0.0.0" @@ Dream.logger @@ Dream.router [ index_route; javascript_route; api_route ]
