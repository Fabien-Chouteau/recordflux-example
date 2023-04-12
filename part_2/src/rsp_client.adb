pragma SPARK_Mode;

with System.Storage_Elements; use System.Storage_Elements;

with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with RFLX.RFLX_Types;
with RFLX.RFLX_Builtin_Types;
with RFLX.RSP.RSP_Message;

with Test_Channel;

procedure RSP_Client is
   use RFLX.RFLX_Builtin_Types;

   Buffer : RFLX.RFLX_Types.Bytes_Ptr :=
     new RFLX.RFLX_Types.Bytes'(1 .. 256 + 3 => 0);

   procedure Receive is
      use RFLX.RSP.RSP_Message;
      use RFLX.RSP;

      Last : RFLX.RFLX_Builtin_Types.Length;

      Ctx : Context;

      procedure Free is new Ada.Unchecked_Deallocation
        (RFLX.RFLX_Builtin_Types.Bytes,
         RFLX.RFLX_Builtin_Types.Bytes_Ptr);

      Answer : RFLX.RFLX_Builtin_Types.Bytes_Ptr;

   begin
      Test_Channel.Receive (Test_Channel.Client, Answer);

      Ada.Text_IO.Put ("[Client] receive: ");
      Test_Channel.Print_Buffer (Answer.all);

      Initialize (Ctx,
                  Answer,
                  RFLX.RFLX_Types.To_Last_Bit_Index (Answer'Last));

      Verify_Message (Ctx);

      if Well_Formed_Message (Ctx) then
         case Get_Kind (Ctx) is

         when Request_Msg =>
            Ada.Text_IO.Put ("[Client] Got Resquest_Message");

            when Answer_Msg =>

               case Get_Answer_Kind (Ctx) is

               when Answer_Data =>

                  declare
                     Len : constant RFLX.RSP.Length := Get_Answer_Length (Ctx);
                     Payload : RFLX.RFLX_Types.Bytes (1 .. Index (Len));
                  begin
                     Get_Answer_Payload (Ctx, Payload);
                     Ada.Text_IO.Put ("[Client] Got Answer_Data: ");
                     Test_Channel.Print_Buffer (Payload);
                  end;

               when Answer_Result =>

                  Ada.Text_IO.Put_Line ("[Client] Got Answer_Result: " &
                                          Get_Answer_Server_Result (Ctx)'Img);

               end case;
         end case;
      else
         Ada.Text_IO.Put_Line ("[Client] Got invalid answer");
      end if;

      Take_Buffer (Ctx, Answer);

      Free (Answer);
   end Receive;

   procedure Send_Packet (Buffer : RFLX.RFLX_Types.Bytes) is
   begin
      Ada.Text_IO.Put ("[Client] send: ");
      Test_Channel.Print_Buffer (Buffer);

      Test_Channel.Send (Test_Channel.Server, Buffer);

      Receive;
   end Send_Packet;

   procedure Store (Id   : RFLX.RSP.Stack_Identifier;
                    Data : RFLX.RFLX_Types.Bytes)
   is
      use RFLX.RSP.RSP_Message;

      Last : RFLX.RFLX_Builtin_Types.Index;
      Ctx : Context;
   begin

      Initialize (Ctx, Buffer);

      Set_Kind (Ctx, RFLX.RSP.Request_Msg);
      Set_Request_Stack_Id (Ctx, Id);
      Set_Request_Kind (Ctx, RFLX.RSP.Request_Store);
      Set_Request_Length (Ctx, Data'Length);
      Set_Request_Payload (Ctx, Data);

      pragma Assert (Well_Formed_Message (Ctx));

      Take_Buffer (Ctx, Buffer);

      Last := Buffer'First + Index (Byte_Size (Ctx)) - 1;
      Send_Packet (Buffer.all (Buffer'First .. Last));
   end Store;

   procedure Get (Id : RFLX.RSP.Stack_Identifier) is
      use RFLX.RSP.RSP_Message;

      Last : RFLX.RFLX_Builtin_Types.Index;
      Ctx : Context;
   begin

      Initialize (Ctx, Buffer);

      Set_Kind (Ctx, RFLX.RSP.Request_Msg);
      Set_Request_Stack_Id (Ctx, Id);
      Set_Request_Kind (Ctx, RFLX.RSP.Request_Get);
      pragma Assert (Well_Formed_Message (Ctx));

      Take_Buffer (Ctx, Buffer);

      Last := Buffer'First + Index (Byte_Size (Ctx)) - 1;
      Send_Packet (Buffer.all (Buffer'First .. Last));
   end Get;

begin

   Store (5, RFLX.RFLX_Types.Bytes'(1, 2, 3, 4));
   Store (5, RFLX.RFLX_Types.Bytes'(1, 2, 3, 4));
   Store (5, RFLX.RFLX_Types.Bytes'(1, 2, 3, 4));
   Get (5);

   delay 3.0;
end RSP_Client;
