with RSP_Server;
with RSP_Client;

procedure Example is
   task Client is
   end Client;

   task body Client is
   begin
      RSP_Client;
   end Client;
begin

   RSP_Server;
end Example;
