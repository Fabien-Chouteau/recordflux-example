with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with Interfaces; use Interfaces;

with Ada.Exceptions;

with Server_Session;

with RFLX.RSP.Server;
with RFLX.RFLX_Types;
with RFLX.RFLX_Builtin_Types;

with Test_Channel;

procedure RSP_Server is

   package Server renames RFLX.RSP.Server;
   package Types renames RFLX.RFLX_Types;

   ----------
   -- Read --
   ----------

   procedure Read (Ctx : in out Server_Session.Context) with
      Pre =>
         Server.Initialized (Ctx)
         and then Server.Has_Data (Ctx, Server.C_Chan),
      Post =>
         Server.Initialized (Ctx)
   is
      Size : constant Types.Length :=
        Server.Read_Buffer_Size (Ctx, Server.C_Chan);
      Buffer : Types.Bytes (1 .. Types.Index (Size)) := (others => 0);
   begin
      Server.Read (Ctx, Server.C_Chan, Buffer);

      Ada.Text_IO.Put ("[Server] send: ");
      Test_Channel.Print_Buffer (Buffer);

      Test_Channel.Send (Test_Channel.Client, Buffer);
   end Read;

   -----------
   -- Write --
   -----------

   procedure Write (Ctx : in out Server_Session.Context) with
      Pre =>
         Server.Initialized (Ctx)
         and then Server.Needs_Data (Ctx, Server.C_Chan),
      Post =>
         Server.Initialized (Ctx)
   is
      use type Types.Index;
      use type Types.Length;

      procedure Free is new Ada.Unchecked_Deallocation
        (RFLX.RFLX_Builtin_Types.Bytes,
         RFLX.RFLX_Builtin_Types.Bytes_Ptr);

      Request : RFLX.RFLX_Builtin_Types.Bytes_Ptr;

   begin
      Test_Channel.Receive (Test_Channel.Server, Request);

      Ada.Text_IO.Put ("[Server] receive: ");
      Test_Channel.Print_Buffer (Request.all);

      if Request'Length <= Server.Write_Buffer_Size (Ctx, Server.C_Chan) then
         Server.Write (Ctx, Server.C_Chan, Request.all);
      end if;

      Free (Request);
   end Write;

   Ctx : Server_Session.Context;
begin

   Ada.Text_IO.Put_Line ("Starting server");

   RFLX.RSP.Server.Initialize (Ctx);

   while Ctx.Active loop
      if Ctx.Has_Data (Server.C_Chan) then
         Read (Ctx);
      elsif Ctx.Needs_Data (Server.C_Chan) then
         Write (Ctx);
      end if;

      Ctx.Run;
   end loop;

   Ada.Text_IO.Put_Line ("Closing server");

   Ctx.Finalize;
end RSP_Server;
