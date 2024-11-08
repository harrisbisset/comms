open Lwt.Infix

let counter : int ref = ref 0
let listen_address : Unix.inet_addr = Unix.inet_addr_loopback
(* This sets the listen_address to the loopback IP address (127.0.0.1), indicating
   that the server will listen for connections from the local machine only. *)

let port : int = 9000
let backlog : int = 10

type order_type =
  { user_id : string
  ; user_order_id : string
  ; order_type : Order.order_type
  ; symbol : string
  ; limit_price : int64
  ; quantity : int64
  ; mutable next_order : order_type option
  ; mutable prev_order : order_type option
  ; mutable parent_limit : limit option
  }

and limit =
  { price : int64
  ; mutable size : int64
  ; volume : int64
  ; mutable parent : limit option
  ; mutable left_child : limit option
  ; mutable right_child : limit option
  ; mutable head_order : order_type
  ; mutable tail_order : order_type
  }

type book =
  { mutable buy_tree : limit option
  ; mutable sell_tree : limit option
  ; mutable lowest_sell : limit option
  ; mutable highest_buy : limit option
  }

let convert_order (rec_order : Order.proto_order) : order_type =
  ({ user_id = rec_order.user_id
   ; user_order_id = rec_order.user_order_id
   ; order_type = rec_order.order_type
   ; symbol = rec_order.symbol
   ; limit_price = rec_order.limit_price
   ; quantity = rec_order.quantity
   ; next_order = None
   ; prev_order = None
   ; parent_limit = None
   }
   : order_type)
;;

module OrderBook = struct
  let order_book : book =
    { buy_tree = None; sell_tree = None; lowest_sell = None; highest_buy = None }
  ;;

  let create_new_tree (order : order_type) : limit option =
    let tree : limit =
      { price = order.limit_price
      ; size = order.quantity
      ; volume = order.quantity
      ; parent = None
      ; left_child = None
      ; right_child = None
      ; tail_order = order
      ; head_order = order
      }
    in
    tree.parent <- Some tree;
    Some tree
  ;;

  (* let create_new_right_child (order : order_type) *)

  let cancel_order (order : order_type) =
    print_endline order.symbol;
    ""
  ;;

  let buy_order (order : order_type) =
    let rec rec_buy_order (order : order_type) (curr_limit : limit) =
      if order.limit_price > curr_limit.price
      then (
        order.parent_limit <- Some curr_limit;
        order.next_order <- Some curr_limit.head_order;
        curr_limit.head_order <- order)
      else (
        match curr_limit.right_child with
        | None ->
          curr_limit.right_child
          <- Some
               { price = order.limit_price
               ; size = order.quantity
               ; volume = order.quantity
               ; parent = order_book.buy_tree
               ; left_child = None
               ; right_child = None
               ; tail_order = order
               ; head_order = order
               };
          order.parent_limit <- curr_limit.right_child
        | Some rc -> rec_buy_order order rc)
    in
    match order_book.buy_tree with
    | None ->
      order_book.buy_tree <- create_new_tree order
    | Some tree -> rec_buy_order order tree
  ;;

  let sell_order (order : order_type) =
    print_endline order.symbol;
    ""
  ;;

  let handle_order (msg : bytes) : string =
    (* verifies whether received correct order *)
    let some_order =
      try
        let proto_order = Order.decode_pb_proto_order (Pbrt.Decoder.of_bytes msg) in
        Some (convert_order proto_order)
      with
      | _ -> None
    in
    match some_order with
    (* if not order, or incorrect order *)
    | None ->
      (match Bytes.to_string msg with
       | "quit" -> "quit"
       | _ -> "")
    (* tries to implement the order, if correct order *)
    | Some order ->
      (match order.order_type with
       | Cancel -> cancel_order order
       | Buy -> buy_order order; ""
       | Sell -> sell_order order)
  ;;
end

let rec handle_request (server_socket : Lwt_unix.file_descr Lwt.t) : unit Lwt.t =
  print_endline "waiting for request";
  let buffer = Bytes.create 1024 in
  print_endline "just created buffer";
  server_socket
  >>= fun server_socket ->
  print_endline "just got server_socket";
  Lwt_unix.recvfrom server_socket buffer 0 1024 []
  >>= fun (num_bytes, client_address) ->
  print_endline "received request";
  let message = Bytes.sub buffer 0 num_bytes in
  let reply = OrderBook.handle_order message in
  match reply with
  | "quit" ->
    print_endline "quitting Server...";
    Lwt_unix.sendto
      server_socket
      (Bytes.of_string reply)
      0
      (String.length reply)
      []
      client_address
    >>= fun _ -> Lwt.return ()
  | _ ->
    print_endline ("replying with: " ^ reply);
    Lwt_unix.sendto
      server_socket
      (Bytes.of_string reply)
      0
      (String.length reply)
      []
      client_address
    >>= fun _ ->
    print_endline "reply sent";
    handle_request (Lwt.return server_socket)
;;

let create_socket () : Lwt_unix.file_descr Lwt.t =
  print_endline "creating server socket";
  let sock = Lwt_unix.socket Lwt_unix.PF_INET Lwt_unix.SOCK_DGRAM 0 in
  Lwt_unix.bind sock @@ Lwt_unix.ADDR_INET (listen_address, port)
  >>= fun () -> Lwt.return sock
;;
