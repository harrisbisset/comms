let () =
  print_endline "Launching UDP Server...";
  let () = Logs.set_reporter (Logs.format_reporter ()) in
  let () = Logs.set_level (Some Logs.Info) in
  let server_socket = Server.create_socket () in
  Lwt_main.run @@ Server.handle_request server_socket
;;

(* let () = print_endline @@ Server.handle_order (Bytes.create 1024) *)

(* let x = Server.handle_order (Bytes.create 1024) in
   print_endline x *)
