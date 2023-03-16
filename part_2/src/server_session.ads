with Interfaces;

with GNAT.Sockets;

with COBS_Socket_Channel;

with RFLX.RSP.Server;
with RFLX.RFLX_Types;

package Server_Session is

   type Context is new RFLX.RSP.Server.Context with
      record
         Chan : COBS_Socket_Channel.Instance;
         Id   : Interfaces.Unsigned_32;
      end record;

   overriding
   procedure Store_Data (Ctx         : in out Context;
                         Stack_Id    : RFLX.RSP.Stack_Identifier;
                         Data        : RFLX.RFLX_Types.Bytes;
                         RFLX_Result : out Boolean);

   overriding
   procedure Handle_Error (Ctx         : in out Context;
                           Err         : RFLX.RSP.Server_Error_Kind;
                           RFLX_Result : out Boolean);

end Server_Session;
