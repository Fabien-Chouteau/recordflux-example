with GNAT.Sockets; use GNAT.Sockets;
with Ada.Streams; use Ada.Streams;

with Ada.Text_IO;

with RFLX.RFLX_Builtin_Types; use RFLX.RFLX_Builtin_Types;

package body COBS_Socket_Channel is

   -------------------
   -- To_Ada_Stream --
   -------------------

   function To_Ada_Stream (Buffer : RFLX.RFLX_Builtin_Types.Bytes)
                           return Ada.Streams.Stream_Element_Array with
      Pre =>
         Buffer'First = 1
         and then Buffer'Length <= Ada.Streams.Stream_Element_Offset'Last
   is
      Result : Ada.Streams.Stream_Element_Array (1 .. Buffer'Length);
   begin
      for I in Result'Range loop
         Result (I) := Ada.Streams.Stream_Element (Buffer (RFLX.RFLX_Builtin_Types.Index (I)));
      end loop;
      return Result;
   end To_Ada_Stream;

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
   ----------
   -- Open --
   ----------

   function Open (This : Instance) return Boolean is
   begin
      return This.Socket /= GNAT.Sockets.No_Socket;
   end Open;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (This   : out Instance;
                         Socket :     GNAT.Sockets.Socket_Type;
                         Id     :     Interfaces.Unsigned_32)
   is
   begin
      This.Socket := Socket;
      This.Chan_Id := Id;
      This.Encoder.Reset;
      This.Decoder.Reset;

      This.Encoder.Socket := Socket;
   end Initialize;

   -----------
   -- Close --
   -----------

   procedure Close (This : in out Instance) is
   begin
      Close_Socket (This.Socket);
      This.Socket := No_Socket;
   end Close;

   ----------
   -- Send --
   ----------

   procedure Send (This   : in out Instance;
                   Buffer :        RFLX.RFLX_Builtin_Types.Bytes)
     with
       SPARK_Mode => Off
   is
   begin
      for Elt of Buffer loop
         This.Encoder.Push (System.Storage_Elements.Storage_Element (Elt));
      end loop;
      This.Encoder.End_Frame;
   end Send;

   -------------
   -- Receive --
   -------------

   procedure Receive (This   : in out Instance;
                      Buffer :    out RFLX.RFLX_Builtin_Types.Bytes;
                      Length :    out RFLX.RFLX_Builtin_Types.Length)
     with
       SPARK_Mode => Off
   is
      Data : Ada.Streams.Stream_Element_Array (1 .. Buffer'Length);
      Last : Ada.Streams.Stream_Element_Offset;

      B_Last : RFLX.RFLX_Builtin_Types.Index;
   begin
      Length := 0;

      GNAT.Sockets.Receive_Socket (Socket => This.Socket,
                                   Item   => Data,
                                   Last   => Last);

      if Last > 0 then
         for Elt of Data (Data'First .. Last) loop
            Ada.Text_IO.Put_Line ("(#" & This.Chan_Id'Img &
                                    ") Got COBS byte:" & Elt'Img);
            This.Decoder.Push (System.Storage_Elements.Storage_Element (Elt));

            if This.Decoder.Packet_Ready then
               This.Decoder.Packet_Ready := False;

               Length := RFLX.RFLX_Builtin_Types.Length
                 (This.Decoder.Next_In - 1);

               B_Last := Buffer'First + This.Decoder.Next_In - 2;

               Buffer (Buffer'First .. B_Last) :=
                 (This.Decoder.Buffer (1 .. This.Decoder.Next_In - 1));

               Ada.Text_IO.Put ("(#" & This.Chan_Id'Img &
                                  ") Got message: ");
               Print_Buffer (Buffer (Buffer'First .. B_Last));
               return;
            end if;

         end loop;
      end if;
   end Receive;

   -----------
   -- Reset --
   -----------

   overriding
   procedure Reset (This : in out COBS_Decoder) is
   begin
      COBS.Stream.Decoder.Instance (This).Reset;

      This.Next_In := This.Buffer'First;
      This.Packet_Ready := False;
   end Reset;

   -----------
   -- Flush --
   -----------

   overriding
   procedure Flush (This : in out COBS_Decoder;
                    Data :        System.Storage_Elements.Storage_Array)
   is
   begin
      for Elt of Data loop
         This.Buffer (This.Next_In) := RFLX.RFLX_Builtin_Types.Byte (Elt);
         This.Next_In := This.Next_In + 1;
      end loop;
   end Flush;

   ------------------
   -- End_Of_Frame --
   ------------------

   overriding
   procedure End_Of_Frame (This : in out COBS_Decoder) is
   begin
      This.Packet_Ready := True;
   end End_Of_Frame;

   -----------
   -- Flush --
   -----------

   overriding
   procedure Flush (This : in out COBS_Encoder;
                    Data :        System.Storage_Elements.Storage_Array)
   is
      Stream_Data : Ada.Streams.Stream_Element_Array
        (1 .. Data'Length)
        with Address => Data'Address;

      Last : Ada.Streams.Stream_Element_Count;
   begin
      GNAT.Sockets.Send_Socket (This.Socket, Stream_Data, Last);
   end Flush;

end COBS_Socket_Channel;
