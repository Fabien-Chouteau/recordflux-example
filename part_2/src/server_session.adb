with Ada.Text_IO;
with Test_Channel;

with RFLX.RFLX_Builtin_Types; use RFLX.RFLX_Builtin_Types;

package body Server_Session is

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

      ---------
      -- Get --
      ---------

      procedure Get (Stack_Id :     RFLX.RSP.Stack_Identifier;
                     Result   : out RFLX.RSP.Payload.Structure)
      is
         Stack : Stack_Rec renames Stacks (Stack_Id);

         Available : constant Length := Length (Stack.Next_In) - Length (Stack.Data'First);
         Max_Len   : constant Length := Length (RFLX.RSP.Length'Last);
         Len       : constant Length := Length'Min (Max_Len, Available);
      begin

         Result.Length := RFLX.RSP.Length (Len);

         if Len > 0 then
            declare
               From_First : constant Index := Stack.Next_In - Index (Len);
               From_Last  : constant Index := Stack.Next_In - 1;

               To_First   : constant Index := Result.Data'First;
               To_Last    : constant Index := To_First + Index (Len) - 1;

            begin
               Result.Data (To_First .. To_Last) :=
                 Stack.Data (From_First .. From_Last);

               Stack.Next_In := Stack.Next_In - Index (Len);
            end;
         end if;
      end Get;

      -----------
      -- Print --
      -----------

      procedure Print (Stack_Id : RFLX.RSP.Stack_Identifier) is
         Stack : Stack_Rec renames Stacks (Stack_Id);
      begin
         for Elt of Stack.Data (Stack.Data'First .. Stack.Next_In - 1) loop
            Ada.Text_IO.Put (Elt'Img);
         end loop;
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
      use RFLX.RSP;
   begin
      Ada.Text_IO.Put ("[Server] try to push data on stack:" & Stack_Id'Img & " -> ");
      Test_Channel.Print_Buffer (Data, 10);

      The_Stacks.Store (Stack_Id, Data, RFLX_Result);

      if RFLX_Result = Store_Fail then
         Ada.Text_IO.Put_Line ("[Server] push failed.");
      end if;

      Ada.Text_IO.Put ("[Server] stack:" & Stack_Id'Img & " ->");
      The_Stacks.Print (Stack_Id);
   end Store_Data;

   ----------------
   -- Store_Data --
   ----------------

   overriding
   procedure Get_Data (Ctx         : in out Context;
                       Stack_Id    : RFLX.RSP.Stack_Identifier;
                       RFLX_Result : out RFLX.RSP.Payload.Structure)
   is
   begin
      The_Stacks.Get (Stack_Id, RFLX_Result);

      Ada.Text_IO.Put ("[Server] get data from Stack:" & Stack_Id'Img & " -> ");
      Test_Channel.Print_Buffer (RFLX_Result.Data, 10);
      Ada.Text_IO.Put ("[Server] stack:" & Stack_Id'Img & " ->");
      The_Stacks.Print (Stack_Id);
   end Get_Data;

end Server_Session;
