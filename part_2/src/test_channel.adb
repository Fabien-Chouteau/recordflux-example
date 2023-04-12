with Ada.Text_IO;

package body Test_Channel is

   ----------
   -- Send --
   ----------

   procedure Send (This : in out Instance;
                   Msg  :        RFLX.RFLX_Builtin_Types.Bytes)
   is
   begin
      This.Enqueue (new RFLX.RFLX_Builtin_Types.Bytes'(Msg));
   end Send;

   -------------
   -- Receive --
   -------------

   procedure Receive (This    : in out Instance;
                      Msg_Ptr :    out RFLX.RFLX_Builtin_Types.Bytes_Ptr)
   is
   begin
      This.Dequeue (Msg_Ptr);
   end Receive;

   ------------------
   -- Print_Buffer --
   ------------------

   procedure Print_Buffer (Buffer : RFLX.RFLX_Builtin_Types.Bytes) is
      package Byte_IO
      is new Ada.Text_IO.Modular_IO (RFLX.RFLX_Builtin_Types.Byte);

   begin
      for Elt of Buffer loop
         Byte_IO.Put (Elt, Base => 16);
         Ada.Text_IO.Put (' ');
      end loop;
      Ada.Text_IO.New_Line;
   end Print_Buffer;

end Test_Channel;
