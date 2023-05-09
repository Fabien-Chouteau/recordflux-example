with Interfaces;

with GNAT.Sockets;

with RFLX.RSP.Server;
with RFLX.RSP.Payload;
with RFLX.RFLX_Types;

package Server_Session is

   type Context is new RFLX.RSP.Server.Context with private;

   overriding
   procedure Store_Data (Ctx         : in out Context;
                         Stack_Id    : RFLX.RSP.Stack_Identifier;
                         Data        : RFLX.RFLX_Types.Bytes;
                         RFLX_Result : out RFLX.RSP.Store_Result);

   overriding
   procedure Get_Data (Ctx         : in out Context;
                       Stack_Id    : RFLX.RSP.Stack_Identifier;
                       RFLX_Result : out RFLX.RSP.Payload.Structure);

private

   type Context is new RFLX.RSP.Server.Context with null record;

   Stack_Size : constant := 15;

   type Stack_Rec is record
      Data    : RFLX.RFLX_Types.Bytes (1 .. Stack_Size) := (others => 0);
      Next_In : RFLX.RFLX_Types.Index := 1;
   end record;

   type Stack_Array is array (RFLX.RSP.Stack_Identifier) of Stack_Rec;

   protected The_Stacks is

      procedure Store (Stack_Id :     RFLX.RSP.Stack_Identifier;
                       Data     :     RFLX.RFLX_Types.Bytes;
                       Result   : out RFLX.RSP.Store_Result);

      procedure Get (Stack_Id :     RFLX.RSP.Stack_Identifier;
                     Result   : out RFLX.RSP.Payload.Structure);

      procedure Print (Stack_Id : RFLX.RSP.Stack_Identifier);

   private
      Stacks : Stack_Array;
   end The_Stacks;

end Server_Session;
