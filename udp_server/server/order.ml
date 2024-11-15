[@@@ocaml.warning "-27-30-39-44"]

type order_type =
  | Buy
  | Sell
  | Cancel

type proto_order =
  { user_id : string
  ; user_order_id : string
  ; order_type : order_type
  ; symbol : string
  ; limit_price : int64
  ; quantity : int64
  }

let rec default_order_type () : order_type = Buy

let rec default_proto_order
  ?(user_id : string = "")
  ?(user_order_id : string = "")
  ?(order_type : order_type = default_order_type ())
  ?(symbol : string = "")
  ?(limit_price : int64 = 0L)
  ?(quantity : int64 = 0L)
  ()
  : proto_order
  =
  { user_id; user_order_id; order_type; symbol; limit_price; quantity }
;;

type proto_order_mutable =
  { mutable user_id : string
  ; mutable user_order_id : string
  ; mutable order_type : order_type
  ; mutable symbol : string
  ; mutable limit_price : int64
  ; mutable quantity : int64
  }

let default_proto_order_mutable () : proto_order_mutable =
  { user_id = ""
  ; user_order_id = ""
  ; order_type = default_order_type ()
  ; symbol = ""
  ; limit_price = 0L
  ; quantity = 0L
  }
;;

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_order_type (v : order_type) encoder =
  match v with
  | Buy -> Pbrt.Encoder.int_as_varint 0 encoder
  | Sell -> Pbrt.Encoder.int_as_varint 1 encoder
  | Cancel -> Pbrt.Encoder.int_as_varint 2 encoder
;;

let rec encode_pb_proto_order (v : proto_order) encoder =
  Pbrt.Encoder.string v.user_id encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder;
  Pbrt.Encoder.string v.user_order_id encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder;
  encode_pb_order_type v.order_type encoder;
  Pbrt.Encoder.key 3 Pbrt.Varint encoder;
  Pbrt.Encoder.string v.symbol encoder;
  Pbrt.Encoder.key 4 Pbrt.Bytes encoder;
  Pbrt.Encoder.int64_as_varint v.limit_price encoder;
  Pbrt.Encoder.key 5 Pbrt.Varint encoder;
  Pbrt.Encoder.int64_as_varint v.quantity encoder;
  Pbrt.Encoder.key 6 Pbrt.Varint encoder;
  ()
;;

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_order_type d =
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Buy : order_type)
  | 1 -> (Sell : order_type)
  | 2 -> (Cancel : order_type)
  | _ -> Pbrt.Decoder.malformed_variant "order_type"
;;

let rec decode_pb_proto_order d =
  let v = default_proto_order_mutable () in
  let continue__ = ref true in
  let quantity_is_set = ref false in
  let limit_price_is_set = ref false in
  let symbol_is_set = ref false in
  let order_type_is_set = ref false in
  let user_order_id_is_set = ref false in
  let user_id_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None ->
      ();
      continue__ := false
    | Some (1, Pbrt.Bytes) ->
      v.user_id <- Pbrt.Decoder.string d;
      user_id_is_set := true
    | Some (1, pk) -> Pbrt.Decoder.unexpected_payload "Message(proto_order), field(1)" pk
    | Some (2, Pbrt.Bytes) ->
      v.user_order_id <- Pbrt.Decoder.string d;
      user_order_id_is_set := true
    | Some (2, pk) -> Pbrt.Decoder.unexpected_payload "Message(proto_order), field(2)" pk
    | Some (3, Pbrt.Varint) ->
      v.order_type <- decode_pb_order_type d;
      order_type_is_set := true
    | Some (3, pk) -> Pbrt.Decoder.unexpected_payload "Message(proto_order), field(3)" pk
    | Some (4, Pbrt.Bytes) ->
      v.symbol <- Pbrt.Decoder.string d;
      symbol_is_set := true
    | Some (4, pk) -> Pbrt.Decoder.unexpected_payload "Message(proto_order), field(4)" pk
    | Some (5, Pbrt.Varint) ->
      v.limit_price <- Pbrt.Decoder.int64_as_varint d;
      limit_price_is_set := true
    | Some (5, pk) -> Pbrt.Decoder.unexpected_payload "Message(proto_order), field(5)" pk
    | Some (6, Pbrt.Varint) ->
      v.quantity <- Pbrt.Decoder.int64_as_varint d;
      quantity_is_set := true
    | Some (6, pk) -> Pbrt.Decoder.unexpected_payload "Message(proto_order), field(6)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  if not !quantity_is_set then Pbrt.Decoder.missing_field "quantity";
  if not !limit_price_is_set then Pbrt.Decoder.missing_field "limit_price";
  if not !symbol_is_set then Pbrt.Decoder.missing_field "symbol";
  if not !order_type_is_set then Pbrt.Decoder.missing_field "order_type";
  if not !user_order_id_is_set then Pbrt.Decoder.missing_field "user_order_id";
  if not !user_id_is_set then Pbrt.Decoder.missing_field "user_id";
  ({ user_id = v.user_id
   ; user_order_id = v.user_order_id
   ; order_type = v.order_type
   ; symbol = v.symbol
   ; limit_price = v.limit_price
   ; quantity = v.quantity
   }
   : proto_order)
;;
