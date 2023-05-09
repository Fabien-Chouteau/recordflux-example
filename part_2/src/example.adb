with RSP_Client;
with RSP_Server;

with Ada.Task_Identification;

procedure Example is

   task Server is
   end Server;

   task body Server is
   begin
      RSP_Server;
   end Server;

begin
   RSP_Client;

   Ada.Task_Identification.Abort_Task (Server'Identity);
end Example;
