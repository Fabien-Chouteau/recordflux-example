--  This unit provides an abstract type to encode COBS byte per byte. It can
--  stream data because the full input frame is not required to start encoding.
--
--  To use this encoder, declare a tagged type that inherit from this one and
--  implement a Flush procedure that will receive the encoded data from the
--  encoder.
--
--  The Flush procedure can, for instance, send encoded data to a serial port.

package COBS.Stream.Encoder
with Preelaborate
is

   type Instance is abstract tagged private;

   procedure Reset (This : in out Instance);

   procedure Push (This : in out Instance;
                   Data : Storage_Element);
   --  Push an input byte into the decoder

   procedure End_Frame (This : in out Instance);
   --  Signal the end of the current frame, flush the remainaing data and a
   --  zero delimiter.

   procedure Flush (This : in out Instance;
                    Data : Storage_Array)
   is abstract;
   --  This procedure is called whenever the encoder needs has encoded data to
   --  flush.

private

   type Instance is abstract tagged record
      Buffer         : Storage_Array (1 .. 255);
      Code           : Storage_Element := 1;
      Prev_Code      : Storage_Element := 1;
      Code_Pointer   : Storage_Offset := 1;
      Encode_Pointer : Storage_Offset := 2;
   end record;

end COBS.Stream.Encoder;
