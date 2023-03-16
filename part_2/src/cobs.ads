--  This unit provides sub-programs to encode/decode COBS from arrays in
--  memory. The entire encoded/decoded frame must be available in a
--  contiguous array.

with System.Storage_Elements; use System.Storage_Elements;

package COBS
with Preelaborate
is

   function Max_Encoding_Length (Data_Len : Storage_Count)
                                 return Storage_Count;
   --  Return the worst case output size for a given data length

   procedure Encode (Data        :        Storage_Array;
                     Output      : in out Storage_Array;
                     Output_Last :    out Storage_Offset;
                     Success     :    out Boolean);
   --  Encode input Data into the Output buffer without adding a delimiter.
   --  Output_Last is the index of the last encoded byte in the Output
   --  buffer. The procedure will return with Success = False if the Output
   --  buffer is not large enough to encode the input. You can use the
   --  Max_Encoding_Length function to get the worst case output size for
   --  a given data length.

   procedure Decode (Data        :        Storage_Array;
                     Output      : in out Storage_Array;
                     Output_Last :    out Storage_Offset;
                     Success     :    out Boolean);
   --  Decode input Data into the Output buffer. Output_Last is the index of
   --  the last decoded byte in the Output buffer. The procedure will return
   --  with Success = False if the Output buffer is not large enough to decode
   --  the input, or if the COBS frame is not correctly encoded.

   procedure Decode_In_Place (Data    : in out Storage_Array;
                              Last    :    out Storage_Offset;
                              Success :    out Boolean);
   --  Decode input Data inside the Data buffer itself. Last is the index of
   --  the last decoded byte in the Data buffer. The procedure will return
   --  with Success = False if the COBS frame is not correctly encoded.

end COBS;
