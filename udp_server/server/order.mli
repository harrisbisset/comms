(** Code for order.proto *)

(* generated from "order.proto", do not edit *)

(** {2 Types} *)

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

(** {2 Basic values} *)

(** [default_order_type ()] is the default value for type [order_type] *)
val default_order_type : unit -> order_type

(** [default_proto_order ()] is the default value for type [proto_order] *)
val default_proto_order
  :  ?user_id:string
  -> ?user_order_id:string
  -> ?order_type:order_type
  -> ?symbol:string
  -> ?limit_price:int64
  -> ?quantity:int64
  -> unit
  -> proto_order

(** {2 Protobuf Encoding} *)

(** [encode_pb_order_type v encoder] encodes [v] with the given [encoder] *)
val encode_pb_order_type : order_type -> Pbrt.Encoder.t -> unit

(** [encode_pb_proto_order v encoder] encodes [v] with the given [encoder] *)
val encode_pb_proto_order : proto_order -> Pbrt.Encoder.t -> unit

(** {2 Protobuf Decoding} *)

(** [decode_pb_order_type decoder] decodes a [order_type] binary value from [decoder] *)
val decode_pb_order_type : Pbrt.Decoder.t -> order_type

(** [decode_pb_proto_order decoder] decodes a [proto_order] binary value from [decoder] *)
val decode_pb_proto_order : Pbrt.Decoder.t -> proto_order
