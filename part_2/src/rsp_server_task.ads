with GNAT.Sockets;
with Interfaces;

package RSP_Server_Task is

   task type Instance is
      entry Start (Socket : GNAT.Sockets.Socket_Type;
                   Id     : Interfaces.Unsigned_32);
   end Instance;

end RSP_Server_Task;
