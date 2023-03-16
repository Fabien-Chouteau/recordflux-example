--  This unit provides an abstract type to decode COBS byte per byte. It can
--  stream data because the full input frame is not required to start decoding.
--
--  To use this decoder, declare a tagged type that inherit from this one and
--  implement a Flush procedure that will receive the encoded data from the
--  encoder, and a End_Of_Frame procedure that will be called at the end of
--  each COBS frames.
--
--  The Flush procedure can, for instance, gather decoded data in a vector
--  before processing it in the End_Of_Frame procedure.

package COBS.Stream.Decoder
with Preelaborate
is

   type Instance is abstract tagged private;

   procedure Reset (This : in out Instance);

   procedure Push (This : in out Instance;
                   Data : Storage_Element);

   procedure Flush (This : in out Instance;
                    Data : Storage_Array)
   is abstract;

   procedure End_Of_Frame (This : in out Instance)
   is abstract;

private

   type Instance is abstract tagged record
      Buffer         : Storage_Array (1 .. 255);
      Out_Index      : Storage_Offset := 1;

      Start_Of_Frame : Boolean := True;
      Code           : Storage_Element;
      Last_Code      : Storage_Element := 0;
   end record;

   procedure Do_Flush (This : in out Instance);

end COBS.Stream.Decoder;
