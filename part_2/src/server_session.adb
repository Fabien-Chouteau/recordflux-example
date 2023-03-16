with Ada.Text_IO;

package body Server_Session is

   ----------------
   -- Store_Data --
   ----------------

   overriding
   procedure Store_Data (Ctx         : in out Context;
                         Stack_Id    : RFLX.RSP.Stack_Identifier;
                         Data        : RFLX.RFLX_Types.Bytes;
                         RFLX_Result : out Boolean)
   is
   begin
      Ada.Text_IO.Put_Line ("(#" & Ctx.Id'Img &
                              ") Push data on Stack: " & Stack_Id'Img);
      RFLX_Result := True;
   end Store_Data;

   ------------------
   -- Handle_Error --
   ------------------

   overriding
   procedure Handle_Error (Ctx         : in out Context;
                           Err         : RFLX.RSP.Server_Error_Kind;
                           RFLX_Result : out Boolean)
   is
   begin
      Ada.Text_IO.Put_Line ("(#" & Ctx.Id'Img &
                              ") Server Error: " & Err'Img);
      RFLX_Result := True;
   end Handle_Error;

end Server_Session;
