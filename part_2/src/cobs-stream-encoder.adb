package body COBS.Stream.Encoder is

   subtype Dispatch is Instance'Class;

   procedure Do_Flush (This : in out Instance);

   procedure Do_Flush (This : in out Instance) is
   begin
      Dispatch (This).Flush
        (This.Buffer (This.Buffer'First .. This.Encode_Pointer - 1));

      This.Code_Pointer := This.Buffer'First;
      This.Encode_Pointer := This.Code_Pointer + 1;
   end Do_Flush;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : in out Instance) is
   begin
      This.Code := 1;
      This.Code_Pointer := 1;
      This.Prev_Code := 1;
      This.Encode_Pointer := 2;
   end Reset;

   ----------
   -- Push --
   ----------

   procedure Push (This : in out Instance; Data : Storage_Element) is
   begin
      if Data /= 0 then
         This.Buffer (This.Encode_Pointer) := Data;
         This.Encode_Pointer := This.Encode_Pointer + 1;
         This.Code := This.Code + 1;
      end if;

      if Data = 0 or else This.Code = 16#FF# then
         This.Buffer (This.Code_Pointer) := This.Code;
         This.Prev_Code := This.Code;

         Do_Flush (This);

         This.Code := 1;
      end if;
   end Push;

   ---------------
   -- End_Frame --
   ---------------

   procedure End_Frame (This : in out Instance) is
   begin
      if This.Code /= 1 or else This.Prev_Code /= 16#FF# then
         This.Buffer (This.Code_Pointer) := This.Code;
         This.Buffer (This.Encode_Pointer) := 0;
         This.Encode_Pointer := This.Encode_Pointer + 1;

      else
         This.Buffer (This.Code_Pointer) := 0;
      end if;

      Do_Flush (This);

      This.Code := 1;
      This.Prev_Code := 1;
   end End_Frame;

end COBS.Stream.Encoder;
