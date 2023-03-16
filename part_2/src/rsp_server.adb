with Ada.Text_IO;

with Interfaces; use Interfaces;

with GNAT.Sockets; use GNAT.Sockets;
with RSP_Server_Task;

with Server_Session;

procedure RSP_Server is

   Server_Port : constant := 4242;

   Server_Socket, Client_Socket : Socket_Type;
   Address : Sock_Addr_Type;
   Client_Id : Interfaces.Unsigned_32 := 0;

   Max_Number_Of_Clients : constant := 16;

   Clients : array (1 .. Max_Number_Of_Clients) of RSP_Server_Task.Instance;

begin
   Address.Addr := Any_Inet_Addr;
   Address.Port := Server_Port;

   Create_Socket (Server_Socket);

   Set_Socket_Option (Server_Socket, Socket_Level, (Reuse_Address, True));

   Bind_Socket (Server_Socket, Address);

   Listen_Socket (Server_Socket);

   loop
      Ada.Text_IO.Put_Line ("Accepting connection on port" & Server_Port'Img
                            & "...");
      Accept_Socket (Server_Socket, Client_Socket, Address);

      if Client_Socket /= No_Socket then
         Client_Id := Client_Id + 1;
         Ada.Text_IO.Put_Line ("Connection Open. Client #" & Client_Id'Img);

         Find_Available:
         for C of Clients loop
            if C'Callable then
               C.Start (Client_Socket, Client_Id);
               Client_Socket := No_Socket;
               exit Find_Available;
            end if;
         end loop Find_Available;

         if Client_Socket /= No_Socket then
            Ada.Text_IO.Put_Line ("Cannot find task for client...");
            Close_Socket (Client_Socket);
         end if;

      end if;
   end loop;

end RSP_Server;
