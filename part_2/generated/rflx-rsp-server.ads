--
-- Generated by RecordFlux 0.9.1.dev18+ge578157d on 2023-03-16
--
-- Copyright (C) 2018-2023 AdaCore GmbH
--
-- This file is distributed under the terms of the GNU Affero General Public License version 3.
--

pragma Restrictions (No_Streams);
pragma Style_Checks ("N3aAbCdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
with RFLX.RSP.Server_Allocator;
with RFLX.RFLX_Types;
with RFLX.RSP.RSP_Message;

package RFLX.RSP.Server with
  SPARK_Mode
is

   use type RFLX.RFLX_Types.Index;

   use type RFLX.RFLX_Types.Length;

   type Channel is (C_Chan);

   type State is (S_Receive_Stack_Select, S_Verify_Stack_Select, S_Select_Stack, S_Receive_Data_Request, S_Verify_Data_Request, S_Store, S_Get, S_Send_Data_Answer, S_Exception_Error, S_Invalid_Packet_Error, S_Got_Answer_Packet_Error, S_Stack_Id_Not_Set_Error, S_Stack_Full_Error, S_Final);

   type Private_Context is private;

   type Context is abstract tagged limited
      record
         P : Private_Context;
      end record;

   procedure Store_Data (Ctx : in out Context; Stack_Id : RFLX.RSP.Stack_Identifier; Data : RFLX_Types.Bytes; RFLX_Result : out Boolean) is abstract;

   procedure Handle_Error (Ctx : in out Context; Err : RFLX.RSP.Server_Error_Kind; RFLX_Result : out Boolean) is abstract;

   function Uninitialized (Ctx : Context'Class) return Boolean;

   function Initialized (Ctx : Context'Class) return Boolean;

   function Active (Ctx : Context'Class) return Boolean;

   procedure Initialize (Ctx : in out Context'Class) with
     Pre =>
       Uninitialized (Ctx),
     Post =>
       Initialized (Ctx)
       and Active (Ctx);

   procedure Finalize (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Uninitialized (Ctx)
       and not Active (Ctx);

   pragma Warnings (Off, "subprogram ""Tick"" has no effect");

   procedure Tick (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx);

   pragma Warnings (On, "subprogram ""Tick"" has no effect");

   function In_IO_State (Ctx : Context'Class) return Boolean;

   pragma Warnings (Off, "subprogram ""Run"" has no effect");

   procedure Run (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx);

   pragma Warnings (On, "subprogram ""Run"" has no effect");

   function Next_State (Ctx : Context'Class) return State;

   function Has_Data (Ctx : Context'Class; Chan : Channel) return Boolean with
     Pre =>
       Initialized (Ctx);

   function Read_Buffer_Size (Ctx : Context'Class; Chan : Channel) return RFLX_Types.Length with
     Pre =>
       Initialized (Ctx)
       and then Has_Data (Ctx, Chan);

   procedure Read (Ctx : Context'Class; Chan : Channel; Buffer : out RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) with
     Pre =>
       Initialized (Ctx)
       and then Has_Data (Ctx, Chan)
       and then Buffer'Length > 0
       and then Offset <= RFLX_Types.Length'Last - Buffer'Length
       and then Buffer'Length + Offset <= Read_Buffer_Size (Ctx, Chan),
     Post =>
       Initialized (Ctx);

   function Needs_Data (Ctx : Context'Class; Chan : Channel) return Boolean with
     Pre =>
       Initialized (Ctx);

   function Write_Buffer_Size (Ctx : Context'Class; Chan : Channel) return RFLX_Types.Length with
     Pre =>
       Initialized (Ctx)
       and then Needs_Data (Ctx, Chan);

   procedure Write (Ctx : in out Context'Class; Chan : Channel; Buffer : RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) with
     Pre =>
       Initialized (Ctx)
       and then Needs_Data (Ctx, Chan)
       and then Buffer'Length > 0
       and then Offset <= RFLX_Types.Length'Last - Buffer'Length
       and then Buffer'Length + Offset <= Write_Buffer_Size (Ctx, Chan),
     Post =>
       Initialized (Ctx);

private

   type Private_Context is
      record
         Next_State : State := S_Receive_Stack_Select;
         Msg_Ctx : RSP.RSP_Message.Context;
         Answer_Ctx : RSP.RSP_Message.Context;
         Id : RSP.Stack_Identifier := RSP.Stack_Identifier'First;
         Slots : RSP.Server_Allocator.Slots;
         Memory : RSP.Server_Allocator.Memory;
      end record;

   function Uninitialized (Ctx : Context'Class) return Boolean is
     (not RSP.RSP_Message.Has_Buffer (Ctx.P.Msg_Ctx)
      and not RSP.RSP_Message.Has_Buffer (Ctx.P.Answer_Ctx)
      and RSP.Server_Allocator.Uninitialized (Ctx.P.Slots));

   function Global_Initialized (Ctx : Context'Class) return Boolean is
     (RSP.RSP_Message.Has_Buffer (Ctx.P.Msg_Ctx)
      and then Ctx.P.Msg_Ctx.Buffer_First = RFLX_Types.Index'First
      and then Ctx.P.Msg_Ctx.Buffer_Last = RFLX_Types.Index'First + 4095
      and then RSP.RSP_Message.Has_Buffer (Ctx.P.Answer_Ctx)
      and then Ctx.P.Answer_Ctx.Buffer_First = RFLX_Types.Index'First
      and then Ctx.P.Answer_Ctx.Buffer_Last = RFLX_Types.Index'First + 4095);

   function Initialized (Ctx : Context'Class) return Boolean is
     (Global_Initialized (Ctx)
      and then RSP.Server_Allocator.Global_Allocated (Ctx.P.Slots));

   function Active (Ctx : Context'Class) return Boolean is
     (Ctx.P.Next_State /= S_Final);

   function Next_State (Ctx : Context'Class) return State is
     (Ctx.P.Next_State);

   function Has_Data (Ctx : Context'Class; Chan : Channel) return Boolean is
     ((case Chan is
          when C_Chan =>
             (case Ctx.P.Next_State is
                 when S_Send_Data_Answer =>
                    RSP.RSP_Message.Well_Formed_Message (Ctx.P.Answer_Ctx)
                    and RSP.RSP_Message.Byte_Size (Ctx.P.Answer_Ctx) > 0,
                 when others =>
                    False)));

   function Read_Buffer_Size (Ctx : Context'Class; Chan : Channel) return RFLX_Types.Length is
     ((case Chan is
          when C_Chan =>
             (case Ctx.P.Next_State is
                 when S_Send_Data_Answer =>
                    RSP.RSP_Message.Byte_Size (Ctx.P.Answer_Ctx),
                 when others =>
                    RFLX_Types.Unreachable)));

   function Needs_Data (Ctx : Context'Class; Chan : Channel) return Boolean is
     ((case Chan is
          when C_Chan =>
             (case Ctx.P.Next_State is
                 when S_Receive_Stack_Select | S_Receive_Data_Request =>
                    True,
                 when others =>
                    False)));

   function Write_Buffer_Size (Ctx : Context'Class; Chan : Channel) return RFLX_Types.Length is
     ((case Chan is
          when C_Chan =>
             (case Ctx.P.Next_State is
                 when S_Receive_Stack_Select | S_Receive_Data_Request =>
                    RSP.RSP_Message.Buffer_Length (Ctx.P.Msg_Ctx),
                 when others =>
                    RFLX_Types.Unreachable)));

end RFLX.RSP.Server;
