with System.Storage_Elements; use System.Storage_Elements;

with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with RFLX.RFLX_Types;
with RFLX.RFLX_Builtin_Types;
with RFLX.RSP.RSP_Message;

with Test_Channel;

procedure RSP_Client is
   use RFLX.RFLX_Builtin_Types;

   procedure Free is new Ada.Unchecked_Deallocation
     (RFLX.RFLX_Builtin_Types.Bytes,
      RFLX.RFLX_Builtin_Types.Bytes_Ptr);

   procedure Receive is
      use RFLX.RSP.RSP_Message;
      use RFLX.RSP;

      Ctx : Context;

      Answer : RFLX.RFLX_Builtin_Types.Bytes_Ptr;

   begin
      loop
         pragma Loop_Invariant (Answer = null);
         Test_Channel.Receive (Test_Channel.Client, Answer);
         exit when Answer /= null;
      end loop;

      pragma Assert (Answer /= null);

      Ada.Text_IO.Put ("[Client] receive: ");
      Test_Channel.Print_Buffer (Answer.all, 16);

      Initialize (Ctx,
                  Answer,
                  RFLX.RFLX_Types.To_Last_Bit_Index (Answer'Last));

      Verify_Message (Ctx);

      if Well_Formed_Message (Ctx) then
         case Get_Kind (Ctx) is

         when Request_Msg =>
            Ada.Text_IO.Put ("[Client] got Resquest_Message");

            when Answer_Msg =>

               case Get_Answer_Kind (Ctx) is

               when Answer_Data =>

                  declare
                     Len : constant RFLX.RSP.Length :=
                       Get_Answer_Payload_Length (Ctx);
                     Payload : RFLX.RFLX_Types.Bytes := (1 .. Index (Len) => 0);
                  begin
                     Get_Answer_Payload_Data (Ctx, Payload);
                     Ada.Text_IO.Put ("[Client] got Answer_Data: ");
                     Test_Channel.Print_Buffer (Payload, 10);
                  end;

               when Answer_Result =>

                  Ada.Text_IO.Put_Line ("[Client] got Answer_Result: " &
                                          Get_Answer_Server_Result (Ctx)'Img);

               end case;
         end case;
      else
         Ada.Text_IO.Put_Line ("[Client] got invalid answer");
      end if;

      Take_Buffer (Ctx, Answer);

      Free (Answer);
   end Receive;

   procedure Send_Packet (Buffer : RFLX.RFLX_Types.Bytes) is
   begin
      Ada.Text_IO.Put ("[Client] send: ");
      Test_Channel.Print_Buffer (Buffer, 16);

      Test_Channel.Send (Test_Channel.Server, Buffer);

      Receive;
   end Send_Packet;

   procedure Store (Id   : RFLX.RSP.Stack_Identifier;
                    Data : RFLX.RFLX_Types.Bytes)
   is
      use RFLX.RSP.RSP_Message;

      Last : RFLX.RFLX_Builtin_Types.Index;
      Ctx : Context;

      Buffer : RFLX.RFLX_Types.Bytes_Ptr :=
        new RFLX.RFLX_Types.Bytes'(1 .. 256 + 3 => 0);

   begin

      Initialize (Ctx, Buffer);

      Set_Kind (Ctx, RFLX.RSP.Request_Msg);
      Set_Request_Stack_Id (Ctx, Id);
      Set_Request_Kind (Ctx, RFLX.RSP.Request_Store);
      Set_Request_Payload_Length (Ctx, Data'Length);
      Set_Request_Payload_Data (Ctx, Data);

      pragma Assert (Well_Formed_Message (Ctx));

      Take_Buffer (Ctx, Buffer);

      Last := Buffer'First + Index (Byte_Size (Ctx)) - 1;
      Send_Packet (Buffer.all (Buffer'First .. Last));

      Free (Buffer);
   end Store;

   procedure Get (Id : RFLX.RSP.Stack_Identifier) is
      use RFLX.RSP.RSP_Message;

      Buffer : RFLX.RFLX_Types.Bytes_Ptr :=
        new RFLX.RFLX_Types.Bytes'(1 .. 256 + 3 => 0);

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

      Free (Buffer);
   end Get;

begin

   Store (5, (1, 2, 3, 4, 5, 6));
   Store (5, (7, 8, 9, 10, 11, 12));
   Store (5, (14, 15, 16, 17, 19, 19, 20, 21));
   Get (5);
end RSP_Client;
