with Interfaces;

with GNAT.Sockets;

with RFLX.RSP.Server;
with RFLX.RFLX_Types;

package Server_Session is

   type Context is new RFLX.RSP.Server.Context with null record;

   overriding
   procedure Store_Data (Ctx         : in out Context;
                         Stack_Id    : RFLX.RSP.Stack_Identifier;
                         Data        : RFLX.RFLX_Types.Bytes;
                         RFLX_Result : out RFLX.RSP.Store_Result);

end Server_Session;
