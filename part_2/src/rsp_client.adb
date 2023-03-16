pragma SPARK_Mode;

with GNAT.Sockets; use GNAT.Sockets;
with System.Storage_Elements; use System.Storage_Elements;

with Ada.Text_IO;

with RFLX.RFLX_Types;
with RFLX.RFLX_Builtin_Types;
with RFLX.RSP.RSP_Message;

with COBS_Socket_Channel;

procedure RSP_Client is
   use RFLX.RFLX_Builtin_Types;

   procedure Print_Buffer (Buffer : Storage_Array);

   Buffer : RFLX.RFLX_Types.Bytes_Ptr :=
     new RFLX.RFLX_Types.Bytes'(1 .. 256 + 3 => 0);

   Address : Sock_Addr_Type;
   Socket  : Socket_Type;
   Channel : COBS_Socket_Channel.Instance;

   procedure Print_Buffer (Buffer : Storage_Array) is
      package Byte_IO
      is new Ada.Text_IO.Modular_IO (Storage_Element);
   begin
      Ada.Text_IO.Put ("Sending COBS data: ");
      for Elt of Buffer loop
         Byte_IO.Put (Elt, Base => 16);
         Ada.Text_IO.Put (' ');
      end loop;
      Ada.Text_IO.New_Line;
   end Print_Buffer;

   procedure Print_Buffer (Buffer : RFLX.RFLX_Builtin_Types.Bytes) is
      package Byte_IO
      is new Ada.Text_IO.Modular_IO (RFLX.RFLX_Builtin_Types.Byte);

   begin
      Ada.Text_IO.Put ("Sending packet: ");
      for Elt of Buffer loop
         Byte_IO.Put (Elt, Base => 16);
         Ada.Text_IO.Put (' ');
      end loop;
      Ada.Text_IO.New_Line;

   end Print_Buffer;

   procedure Send_Packet (Buffer : RFLX.RFLX_Types.Bytes) is
   begin
      Ada.Text_IO.Put ("Sending packet: ");
      Print_Buffer (Buffer);
      Channel.Send (Buffer);
   end Send_Packet;

   procedure Set_Stack (Id : RFLX.RSP.Stack_Identifier)
   is
      use RFLX.RSP.RSP_Message;

      Last : RFLX.RFLX_Builtin_Types.Index;
      Ctx : Context;
   begin

      Initialize (Ctx, Buffer);

      Set_Kind (Ctx, RFLX.RSP.Request_Msg);
      Set_Request_Kind (Ctx, RFLX.RSP.Request_Select_Stack);
      Set_Request_Stack_Id (Ctx, Id);

      Take_Buffer (Ctx, Buffer);
      Last := Buffer'First + Index (Byte_Size (Ctx)) - 1;

      Send_Packet (Buffer.all (Buffer'First .. Last));
   end Set_Stack;

   procedure Store (Data : RFLX.RFLX_Types.Bytes)
   is
      use RFLX.RSP.RSP_Message;

      Last : RFLX.RFLX_Builtin_Types.Index;
      Ctx : Context;
   begin

      Initialize (Ctx, Buffer);

      Set_Kind (Ctx, RFLX.RSP.Request_Msg);
      Set_Request_Kind (Ctx, RFLX.RSP.Request_Store);
      Set_Request_Length (Ctx, Data'Length);
      Set_Request_Payload (Ctx, Data);
      Take_Buffer (Ctx, Buffer);

      Last := Buffer'First + Index (Byte_Size (Ctx)) - 1;
      Send_Packet (Buffer.all (Buffer'First .. Last));
   end Store;

begin

   Address.Addr := Any_Inet_Addr;
   Address.Port := 4242;
   Create_Socket (Socket);

   Connect_Socket (Socket, Address);

   Channel.Initialize (Socket, 0);

   Set_Stack (5);
   delay 1.0;
   Store (RFLX.RFLX_Types.Bytes'(1, 2, 3, 4));
   delay 1.0;
   Close_Socket (Socket);
end RSP_Client;
