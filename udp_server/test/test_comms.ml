let%test_unit "Handle order: empty contents" =
  let ( => ) = [%test_eq: Base.string] in
  Server.OrderBook.handle_order (Bytes.create 0) => "";
  Server.OrderBook.handle_order (Bytes.create 1024) => "";
  Server.OrderBook.handle_order (Bytes.create 9999) => ""
;;

let%test_unit "Handle order: bad contents" =
  let ( => ) = [%test_eq: Base.string] in
  Server.OrderBook.handle_order
    (Bytes.of_string "gd27b8qn9c0niqdhx2098qu91hdnxq2by9nywucoqxn9 8dxnxq q")
  => "";
  Server.OrderBook.handle_order (Bytes.of_string "hello world") => "";
  Server.OrderBook.handle_order (Bytes.of_string "") => ""
;;

let%test_unit "Handle order: quit" =
  let ( => ) = [%test_eq: Base.string] in
  Server.OrderBook.handle_order (Bytes.of_string "quit") => "quit"
;;
