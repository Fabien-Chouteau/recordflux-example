package body COBS is

   -------------------------
   -- Max_Encoding_Length --
   -------------------------

   function Max_Encoding_Length (Data_Len : Storage_Count)
                                 return Storage_Count
   is
   begin
      return Data_Len + (Data_Len / 254) + (if (Data_Len mod 254) > 0
                                            then 1
                                            else 0);
   end Max_Encoding_Length;

   ------------
   -- Encode --
   ------------

   procedure Encode (Data        :        Storage_Array;
                     Output      : in out Storage_Array;
                     Output_Last :    out Storage_Offset;
                     Success     :    out Boolean)
   is
      Code_Pointer : Storage_Offset := Output'First;
      Out_Pointer   : Storage_Offset := Code_Pointer + 1;
      Code  : Storage_Element := 1;

      Input : Storage_Element;
   begin

      for Index in Data'Range loop

         if Out_Pointer not in Output'Range then
            Success := False;
            return;
         end if;

         Input := Data (Index);

         if Input /= 0 then
            Output (Out_Pointer) := Input;
            Out_Pointer := Out_Pointer + 1;
            Code := Code + 1;
         end if;

         if Input = 0 or else Code = 16#FF# then
            Output (Code_Pointer) := Code;
            Code := 1;
            Code_Pointer := Out_Pointer;

            if Input = 0 or else Index /= Data'Last then
               Out_Pointer := Out_Pointer + 1;
            end if;
         end if;
      end loop;

      if Code_Pointer /= Out_Pointer then
         Output (Code_Pointer) := Code;
      end if;

      Output_Last := Out_Pointer - 1;
      Success := True;
   end Encode;

   ------------
   -- Decode --
   ------------

   procedure Decode (Data        :        Storage_Array;
                     Output      : in out Storage_Array;
                     Output_Last :    out Storage_Offset;
                     Success     :    out Boolean)
   is
      In_Index  : Storage_Offset := Data'First;
      Out_Index : Storage_Offset := Output'First;

      procedure Push (D : Storage_Element);
      --  Push one element to the output

      function Pop return Storage_Element;
      --  Pop one element from the input

      ----------
      -- Push --
      ----------

      procedure Push (D : Storage_Element) is
      begin
         Output (Out_Index) := D;
         Out_Index := Out_Index + 1;
      end Push;

      ---------
      -- Pop --
      ---------

      function Pop return Storage_Element is
         Result : constant Storage_Element := Data (In_Index);
      begin
         In_Index := In_Index + 1;
         return Result;
      end Pop;

      Code  : Storage_Element;
   begin

      while In_Index <= Data'Last loop

         Code := Pop;

         exit when Code = 0;

         if Code > 1 then

            --  Check input and output boundaries
            if Out_Index + Storage_Count (Code - 1) > Output'Last + 1
              or else
               In_Index + Storage_Count (Code - 1) > Data'Last + 1
            then
               Success := False;
               return;
            end if;

            for X in 1 .. (Code - 1) loop
               Push (Pop);
            end loop;

         end if;

         if Code /= 16#FF# and then In_Index <= Data'Last then
            Push (0);
         end if;
      end loop;

      Output_Last := Out_Index - 1;
      Success := True;
   end Decode;

   ---------------------
   -- Decode_In_Place --
   ---------------------

   procedure Decode_In_Place (Data    : in out Storage_Array;
                              Last    :    out Storage_Offset;
                              Success :    out Boolean)
   is
      In_Index  : Storage_Offset := Data'First;
      Out_Index : Storage_Offset := Data'First;

      procedure Push (D : Storage_Element);
      --  Push one element to the output

      function Pop return Storage_Element;
      --  Pop one element from the input

      ----------
      -- Push --
      ----------

      procedure Push (D : Storage_Element) is
      begin
         Data (Out_Index) := D;
         Out_Index := Out_Index + 1;
      end Push;

      ---------
      -- Pop --
      ---------

      function Pop return Storage_Element is
         Result : constant Storage_Element := Data (In_Index);
      begin
         In_Index := In_Index + 1;
         return Result;
      end Pop;

      Code  : Storage_Element;
   begin

      while In_Index <= Data'Last loop

         Code := Pop;

         exit when Code = 0;

         if Code > 1 then

            --  Check input and output boundaries
            if Out_Index + Storage_Count (Code - 1) > Data'Last + 1
              or else
               In_Index + Storage_Count (Code - 1) > Data'Last + 1
            then
               Success := False;
               return;
            end if;

            for X in 1 .. (Code - 1) loop
               Push (Pop);
            end loop;
         end if;

         if Code /= 16#FF# and then In_Index <= Data'Last then
            Push (0);
         end if;
      end loop;

      Last := Out_Index - 1;
      Success := True;
   end Decode_In_Place;

end COBS;
