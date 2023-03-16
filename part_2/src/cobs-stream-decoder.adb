package body COBS.Stream.Decoder is

   subtype Dispatch is Instance'Class;

   --------------
   -- Do_Flush --
   --------------

   procedure Do_Flush (This : in out Instance) is
   begin
      if This.Out_Index > This.Buffer'First then
         Dispatch (This).Flush
           (This.Buffer (This.Buffer'First .. This.Out_Index - 1));
      end if;
      This.Out_Index := This.Buffer'First;
   end Do_Flush;

   -----------
   -- Reset --
   -----------

   procedure Reset (This : in out Instance) is
   begin
      This.Out_Index := This.Buffer'First;
      This.Start_Of_Frame := True;
      This.Last_Code := 0;
   end Reset;

   ----------
   -- Push --
   ----------

   procedure Push (This : in out Instance; Data : Storage_Element) is
   begin
      if This.Start_Of_Frame then
         This.Code := Data;
         This.Last_Code := This.Code;
         This.Start_Of_Frame := False;

         if This.Code = 0 then
            raise Program_Error;
         end if;
      elsif This.Code > 1 then
         This.Buffer (This.Out_Index) := Data;
         This.Out_Index := This.Out_Index + 1;

         This.Code := This.Code - 1;

      else
         if Data /= 0 and then This.Last_Code /= 16#FF# then
            This.Buffer (This.Out_Index) := 0;
            This.Out_Index := This.Out_Index + 1;
         end if;

         This.Code := Data;
         This.Last_Code := This.Code;

         This.Do_Flush;

         if Data = 0 then
            Dispatch (This).End_Of_Frame;
            This.Start_Of_Frame := True;
         end if;

      end if;
   end Push;

end COBS.Stream.Decoder;
