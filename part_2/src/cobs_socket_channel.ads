with GNAT.Sockets;
with RFLX.RFLX_Builtin_Types;

with Interfaces;

private with COBS.Stream.Decoder;
private with COBS.Stream.Encoder;
private with System.Storage_Elements;

package COBS_Socket_Channel with
  SPARK_Mode,
  Elaborate_Body
is

   type Instance is tagged private;

   function Open (This : Instance) return Boolean;

   procedure Initialize (This   : out Instance;
                         Socket :     GNAT.Sockets.Socket_Type;
                         Id     :     Interfaces.Unsigned_32)
     with Global => null,
          Pre    => This.Open = False,
          Post   => This.Open = True;

   procedure Close (This : in out Instance)
     with Pre    => This.Open = True,
          Post   => This.Open = False;

   procedure Send (This   : in out Instance;
                   Buffer :        RFLX.RFLX_Builtin_Types.Bytes)
     with Global => null,
          Pre    => This.Open = True;

   use type RFLX.RFLX_Builtin_Types.Length;

   procedure Receive (This   : in out Instance;
                      Buffer :    out RFLX.RFLX_Builtin_Types.Bytes;
                      Length :    out RFLX.RFLX_Builtin_Types.Length)
     with Pre    => This.Open = True,
          Post   => Length <= Buffer'Length,
          Global => null;

private

   -- COBS_Decoder --

   type COBS_Decoder is new COBS.Stream.Decoder.Instance with record
      Buffer  : RFLX.RFLX_Builtin_Types.Bytes (1 .. 512);
      Next_In : RFLX.RFLX_Builtin_Types.Index := 1;
      Packet_Ready : Boolean := False;
   end record;

   overriding
   procedure Reset (This : in out COBS_Decoder);

   overriding
   procedure Flush (This : in out COBS_Decoder;
                    Data : System.Storage_Elements.Storage_Array);

   overriding
   procedure End_Of_Frame (This : in out COBS_Decoder);

   -- COBS_Encoder --

   type COBS_Encoder is new COBS.Stream.Encoder.Instance with record
      Socket : GNAT.Sockets.Socket_Type;
   end record;

   overriding
   procedure Flush (This : in out COBS_Encoder;
                    Data :        System.Storage_Elements.Storage_Array);

   -- Instance --

   type Instance is tagged record
      Socket : GNAT.Sockets.Socket_Type;
      Chan_Id : Interfaces.Unsigned_32;
      Decoder : COBS_Decoder;
      Encoder : COBS_Encoder;
   end record;

end COBS_Socket_Channel;
