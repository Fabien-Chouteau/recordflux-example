with RFLX.RFLX_Builtin_Types; use RFLX.RFLX_Builtin_Types;

with Ada.Containers.Synchronized_Queue_Interfaces;
with Ada.Containers.Unbounded_Synchronized_Queues;
with Ada.Text_IO;

package Test_Channel with
Elaborate_Body
is

   package Message_Queue_Interfaces is
     new Ada.Containers.Synchronized_Queue_Interfaces
       (Element_Type => RFLX.RFLX_Builtin_Types.Bytes_Ptr);

   package Message_Queues is
     new Ada.Containers.Unbounded_Synchronized_Queues
       (Queue_Interfaces => Message_Queue_Interfaces);

   subtype Instance is Message_Queues.Queue;

   procedure Send (This : in out Instance; Msg : RFLX.RFLX_Builtin_Types.Bytes)
     with Pre => Msg'Length > 0;

   procedure Receive (This    : in out Instance;
                      Msg_Ptr :    out RFLX.RFLX_Builtin_Types.Bytes_Ptr)
     with Pre => (Msg_Ptr = null or else Msg_Ptr.all'Length > 0);

   procedure Print_Buffer (Buffer : RFLX.RFLX_Builtin_Types.Bytes;
                           Base   : Ada.Text_IO.Number_Base);

   Server : Test_Channel.Instance;
   Client : Test_Channel.Instance;

end Test_Channel;
