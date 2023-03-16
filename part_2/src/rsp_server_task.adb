with Ada.Text_IO;
with Ada.Exceptions;

with Server_Session;
with RFLX.RSP.Server;
with RFLX.RFLX_Types;
with RFLX.RFLX_Builtin_Types;

package body RSP_Server_Task is

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
      use type Types.Index;
      use type Types.Length;
      Buffer : Types.Bytes (Types.Index'First .. Types.Index'First + 4095)
         := (others => 0);
      Size : constant Types.Length :=
        Server.Read_Buffer_Size (Ctx, Server.C_Chan);
   begin
      if Size = 0 then
         Ada.Text_IO.Put_Line ("Error: read buffer size is 0");
         return;
      end if;
      if Buffer'Length < Size then
         Ada.Text_IO.Put_Line ("Error: buffer too small");
         return;
      end if;
      Server.Read
         (Ctx,
          Server.C_Chan,
          Buffer (Buffer'First .. Buffer'First - 2 + Types.Index (Size + 1)));

      Ctx.Chan.Send
        (Buffer (Buffer'First .. Buffer'First - 2 + Types.Index (Size + 1)));
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
      Buffer : Types.Bytes (Types.Index'First .. Types.Index'First + 4095);
      Length : RFLX.RFLX_Builtin_Types.Length;
   begin

      Ctx.Chan.Receive (Buffer, Length);

      if
         Length > 0
         and Length <= Server.Write_Buffer_Size (Ctx, Server.C_Chan)
      then
         Server.Write
            (Ctx,
             Server.C_Chan,
             Buffer (Buffer'First .. Buffer'First +  RFLX.RFLX_Builtin_Types.Index (Length) - 1));

         Ctx.Run;
      end if;
   end Write;

   --------------
   -- Instance --
   --------------

   task body Instance is
      Ctx : Server_Session.Context;
   begin

      loop
         accept Start (Socket : GNAT.Sockets.Socket_Type;
                       Id     : Interfaces.Unsigned_32)
         do
            RFLX.RSP.Server.Initialize (Ctx);
            Ctx.Chan.Initialize (Socket, Id);
            Ctx.Id := Id;
         end Start;

         begin
            Ada.Text_IO.Put_Line ("(#" & Ctx.Id'Img & ") Starting server");

            while Ctx.Active loop
               if Ctx.Has_Data (Server.C_Chan) then
                  Read (Ctx);
               elsif Ctx.Needs_Data (Server.C_Chan) then
                  Write (Ctx);
               else
                  Ctx.Run;
               end if;
            end loop;

            Ada.Text_IO.Put_Line ("(#" & Ctx.Id'Img & ") Closing server");

            Ctx.Chan.Close;
            Ctx.Finalize;

         exception
            when E : others =>
               Ada.Text_IO.Put_Line ("(#" & Ctx.Id'Img & ") Exception: "
                                     & Ada.Exceptions.Exception_Name (E) & ": "
                                     & Ada.Exceptions.Exception_Message (E));
         end;
      end loop;
   end Instance;

end RSP_Server_Task;
