with Ada.Text_IO;
with RFLX.RFLX_Types;
with RFLX.RSP.Request_Message;
with RFLX.RSP.Request_Message_With_Id;
with RFLX.RFLX_Builtin_Types;

procedure Example
  with SPARK_Mode => On
is

   use RFLX.RSP;

   procedure Print_Buffer (B : RFLX.RFLX_Types.Bytes);

   procedure Print_Buffer (B : RFLX.RFLX_Types.Bytes) is
      pragma SPARK_Mode (Off);

      package Byte_IO
      is new Ada.Text_IO.Modular_IO (RFLX.RFLX_Builtin_Types.Byte);

   begin
      for Elt of B loop
         Byte_IO.Put (Elt, Base => 16);
         Ada.Text_IO.Put (' ');
      end loop;
      Ada.Text_IO.New_Line;

   end Print_Buffer;

   procedure This_Is_Ok is
      Buffer  : RFLX.RFLX_Types.Bytes_Ptr :=
        new RFLX.RFLX_Types.Bytes'(0, 0, 0, 0, 0, 0);
      Context : Request_Message.Context;
   begin
      --  This procedure generates a correctly formated request message as
      --  described in the first part of the blog post.

      Ada.Text_IO.Put_Line ("This is ok:");
      Request_Message.Initialize (Context, Buffer);
      --  Request_Message.Set_Stack_Id (Context, 0);
      Request_Message.Set_Kind (Context, Request_Store);
      Request_Message.Set_Length (Context, 4);
      Request_Message.Set_Payload (Context, (1, 2, 3, 4));

      Request_Message.Take_Buffer (Context, Buffer);

      pragma Assert (not Request_Message.Has_Buffer (Context));

      Print_Buffer (Buffer.all);

      RFLX.RFLX_Types.Free (Buffer);
   end This_Is_Ok;

   procedure This_Is_Bad is
      Buffer  : RFLX.RFLX_Types.Bytes_Ptr :=
        new RFLX.RFLX_Types.Bytes'(0, 0, 0, 0, 0, 0, 0);
      Context : Request_Message_With_Id.Context;
   begin
      --  This procedure uses Request_Message_With_Id which corresponds to
      --  the second part of the blog where a new field is introduced to the
      --  message.

      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("This is Bad:");

      Request_Message_With_Id.Initialize (Context, Buffer);

      --  Uncomment the line below to generate a correct message
      --  Request_Message_With_Id.Set_Stack_Id (Context, 6);

      Request_Message_With_Id.Set_Kind (Context, Request_Store);
      Request_Message_With_Id.Set_Length (Context, 4);
      Request_Message_With_Id.Set_Payload (Context, (1, 2, 3, 4));

      Request_Message_With_Id.Take_Buffer (Context, Buffer);
      pragma Assert (not Request_Message_With_Id.Has_Buffer (Context));

      Print_Buffer (Buffer.all);

      RFLX.RFLX_Types.Free (Buffer);
   end This_Is_Bad;

begin
   This_Is_Ok;
   This_Is_Bad;
end Example;
