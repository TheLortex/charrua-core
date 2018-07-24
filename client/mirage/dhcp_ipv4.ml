open Lwt.Infix
open Mirage_protocols_lwt

module Make(Dhcp_client : DHCP_CLIENT) (Ethif : ETHIF)(Arp : ARP) = struct
  (* for now, just wrap a static ipv4 *)
  module I = Static_ipv4.Make(Ethif)(Arp)
  include I

  let update_ip_settings ip (settings: ipv4_config) = 
    I.set_config ~ip:settings.address ~network:settings.network ~gateway:settings.gateway ip

  (* Listen to the DHCP update stream and update configured IP according to it.
   * TODO: Create a Dynamic_IPV4 module for this purpose,
   * that should propagate changes to upper stack.*)
  let connect dhcp ethif arp =
    I.connect ethif arp >>= fun ip ->
    Lwt.ignore_result (Lwt_stream.iter_s (update_ip_settings ip) dhcp);
    Lwt.return ip
end
