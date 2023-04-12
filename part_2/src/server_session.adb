with Ada.Text_IO;

with RFLX.RFLX_Builtin_Types;

package body Server_Session is

   Stack_Size : constant := 256;

   type Stack_Rec is record
      Data    : RFLX.RFLX_Types.Bytes (1 .. Stack_Size) := (others => 0);
      Next_In : RFLX.RFLX_Types.Index := 1;
   end record;

   type Stack_Array is array (RFLX.RSP.Stack_Identifier) of Stack_Rec;

   protected The_Stacks is

      procedure Store (Stack_Id :     RFLX.RSP.Stack_Identifier;
                       Data     :     RFLX.RFLX_Types.Bytes;
                       Result   : out RFLX.RSP.Store_Result);

      procedure Print (Stack_Id : RFLX.RSP.Stack_Identifier);

   private
      Stacks : Stack_Array;
   end The_Stacks;

   ----------------
   -- The_Stacks --
   ----------------

   protected body The_Stacks is

      -----------
      -- Store --
      -----------

      procedure Store (Stack_Id :     RFLX.RSP.Stack_Identifier;
                       Data     :     RFLX.RFLX_Types.Bytes;
                       Result   : out RFLX.RSP.Store_Result)
      is
         use RFLX.RFLX_Builtin_Types;

         Stack : Stack_Rec renames Stacks (Stack_Id);

         Len   : constant RFLX.RFLX_Types.Index := Data'Length;
         First : constant RFLX.RFLX_Types.Index := Stack.Next_In;
         Last  : constant RFLX.RFLX_Types.Index := First + Len - 1;

      begin

         if Len = 0 then
            Result := RFLX.RSP.Store_Ok;

         elsif First not in Stack.Data'Range
           or else Last not in Stack.Data'Range
         then
            Result := RFLX.RSP.Store_Fail;

         else
            Stack.Data (First .. Last) := Data;
            Stack.Next_In := Last + 1;
            Result := RFLX.RSP.Store_Ok;
         end if;
      end Store;

      -----------
      -- Print --
      -----------

      procedure Print (Stack_Id : RFLX.RSP.Stack_Identifier) is
         use RFLX.RFLX_Builtin_Types;

         Stack : Stack_Rec renames Stacks (Stack_Id);
      begin
         Ada.Text_IO.Put ("(");

         for Elt of Stack.Data (Stack.Data'First .. Stack.Next_In - 1) loop
            Ada.Text_IO.Put (Elt'Img);
         end loop;

         Ada.Text_IO.Put (")");
         Ada.Text_IO.New_Line;
      end Print;

   end The_Stacks;

   ----------------
   -- Store_Data --
   ----------------

   overriding
   procedure Store_Data (Ctx         : in out Context;
                         Stack_Id    :        RFLX.RSP.Stack_Identifier;
                         Data        :        RFLX.RFLX_Types.Bytes;
                         RFLX_Result :    out RFLX.RSP.Store_Result)
   is
   begin
      Ada.Text_IO.Put ("[Server] push data on Stack:" & Stack_Id'Img & " -> ");
      The_Stacks.Store (Stack_Id, Data, RFLX_Result);
      The_Stacks.Print (Stack_Id);
   end Store_Data;

end Server_Session;
