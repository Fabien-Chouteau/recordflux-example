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

package body RFLX.RSP.Server with
  SPARK_Mode
is

   use type RFLX.RFLX_Types.Bytes_Ptr;

   use type RFLX.RFLX_Types.Bit_Length;

   procedure Receive_Stack_Select (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Receive_Stack_Select_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Receive_Stack_Select_Invariant);
      -- rsp.rflx:70:10
      RSP.RSP_Message.Verify_Message (Ctx.P.Msg_Ctx);
      Ctx.P.Next_State := S_Verify_Stack_Select;
      pragma Assert (Receive_Stack_Select_Invariant);
   end Receive_Stack_Select;

   procedure Verify_Stack_Select (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Verify_Stack_Select_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Verify_Stack_Select_Invariant);
      if RSP.RSP_Message.Well_Formed_Message (Ctx.P.Msg_Ctx) = False then
         Ctx.P.Next_State := S_Invalid_Packet_Error;
      elsif RSP.RSP_Message.Get_Kind (Ctx.P.Msg_Ctx) /= Request_Msg then
         Ctx.P.Next_State := S_Got_Answer_Packet_Error;
      elsif RSP.RSP_Message.Get_Request_Kind (Ctx.P.Msg_Ctx) /= Request_Select_Stack then
         Ctx.P.Next_State := S_Stack_Id_Not_Set_Error;
      else
         Ctx.P.Next_State := S_Select_Stack;
      end if;
      pragma Assert (Verify_Stack_Select_Invariant);
   end Verify_Stack_Select;

   procedure Select_Stack (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Select_Stack_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Select_Stack_Invariant);
      -- rsp.rflx:86:10
      if RSP.RSP_Message.Valid (Ctx.P.Msg_Ctx, RSP.RSP_Message.F_Request_Stack_Id) then
         Ctx.P.Id := RSP.RSP_Message.Get_Request_Stack_Id (Ctx.P.Msg_Ctx);
      else
         Ctx.P.Next_State := S_Exception_Error;
         pragma Assert (Select_Stack_Invariant);
         goto Finalize_Select_Stack;
      end if;
      Ctx.P.Next_State := S_Receive_Data_Request;
      pragma Assert (Select_Stack_Invariant);
      <<Finalize_Select_Stack>>
   end Select_Stack;

   procedure Receive_Data_Request (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Receive_Data_Request_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Receive_Data_Request_Invariant);
      -- rsp.rflx:95:10
      RSP.RSP_Message.Verify_Message (Ctx.P.Msg_Ctx);
      Ctx.P.Next_State := S_Verify_Data_Request;
      pragma Assert (Receive_Data_Request_Invariant);
   end Receive_Data_Request;

   procedure Verify_Data_Request (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Verify_Data_Request_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Verify_Data_Request_Invariant);
      if RSP.RSP_Message.Well_Formed_Message (Ctx.P.Msg_Ctx) = False then
         Ctx.P.Next_State := S_Invalid_Packet_Error;
      elsif RSP.RSP_Message.Get_Kind (Ctx.P.Msg_Ctx) /= Request_Msg then
         Ctx.P.Next_State := S_Got_Answer_Packet_Error;
      elsif RSP.RSP_Message.Get_Request_Kind (Ctx.P.Msg_Ctx) = Request_Store then
         Ctx.P.Next_State := S_Store;
      elsif RSP.RSP_Message.Get_Request_Kind (Ctx.P.Msg_Ctx) = Request_Get then
         Ctx.P.Next_State := S_Get;
      elsif RSP.RSP_Message.Get_Request_Kind (Ctx.P.Msg_Ctx) = Request_Select_Stack then
         Ctx.P.Next_State := S_Select_Stack;
      else
         Ctx.P.Next_State := S_Exception_Error;
      end if;
      pragma Assert (Verify_Data_Request_Invariant);
   end Verify_Data_Request;

   procedure Store (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      Store_Data_Error : Boolean;
      function Store_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Store_Invariant);
      -- rsp.rflx:114:10
      if RSP.RSP_Message.Well_Formed (Ctx.P.Msg_Ctx, RSP.RSP_Message.F_Request_Payload) then
         declare
            RFLX_Store_Data_Arg_1_Msg : RFLX_Types.Bytes (RFLX_Types.Index'First .. RFLX_Types.Index'First + 4095) := (others => 0);
            RFLX_Store_Data_Arg_1_Msg_Length : constant RFLX_Types.Length := RFLX_Types.To_Length (RSP.RSP_Message.Field_Size (Ctx.P.Msg_Ctx, RSP.RSP_Message.F_Request_Payload)) + 1;
         begin
            RSP.RSP_Message.Get_Request_Payload (Ctx.P.Msg_Ctx, RFLX_Store_Data_Arg_1_Msg (RFLX_Types.Index'First .. RFLX_Types.Index'First + RFLX_Types.Index (RFLX_Store_Data_Arg_1_Msg_Length) - 2));
            Store_Data (Ctx, Ctx.P.Id, RFLX_Store_Data_Arg_1_Msg (RFLX_Types.Index'First .. RFLX_Types.Index'First + RFLX_Types.Index (RFLX_Store_Data_Arg_1_Msg_Length) - 2), Store_Data_Error);
         end;
      else
         Ctx.P.Next_State := S_Exception_Error;
         pragma Assert (Store_Invariant);
         goto Finalize_Store;
      end if;
      if Store_Data_Error then
         Ctx.P.Next_State := S_Stack_Full_Error;
      else
         Ctx.P.Next_State := S_Receive_Data_Request;
      end if;
      pragma Assert (Store_Invariant);
      <<Finalize_Store>>
   end Store;

   procedure Get (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Get_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Get_Invariant);
      -- rsp.rflx:124:10
      RSP.RSP_Message.Reset (Ctx.P.Answer_Ctx);
      if RSP.RSP_Message.Available_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Kind) < 8 then
         Ctx.P.Next_State := S_Exception_Error;
         pragma Assert (Get_Invariant);
         goto Finalize_Get;
      end if;
      pragma Assert (RSP.RSP_Message.Sufficient_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Kind));
      RSP.RSP_Message.Set_Kind (Ctx.P.Answer_Ctx, Answer_Msg);
      pragma Assert (RSP.RSP_Message.Sufficient_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Answer_Kind));
      RSP.RSP_Message.Set_Answer_Kind (Ctx.P.Answer_Ctx, Answer_Data);
      pragma Assert (RSP.RSP_Message.Sufficient_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Answer_Length));
      RSP.RSP_Message.Set_Answer_Length (Ctx.P.Answer_Ctx, 1);
      if RSP.RSP_Message.Valid_Length (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Answer_Payload, RFLX_Types.To_Length (2 * RFLX_Types.Byte'Size)) then
         pragma Assert (RSP.RSP_Message.Sufficient_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Answer_Payload));
         RSP.RSP_Message.Set_Answer_Payload (Ctx.P.Answer_Ctx, (RFLX_Types.Byte'Val (42), RFLX_Types.Byte'Val (42)));
      else
         Ctx.P.Next_State := S_Exception_Error;
         pragma Assert (Get_Invariant);
         goto Finalize_Get;
      end if;
      Ctx.P.Next_State := S_Send_Data_Answer;
      pragma Assert (Get_Invariant);
      <<Finalize_Get>>
   end Get;

   procedure Send_Data_Answer (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Send_Data_Answer_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Send_Data_Answer_Invariant);
      -- rsp.rflx:136:10
      Ctx.P.Next_State := S_Receive_Data_Request;
      pragma Assert (Send_Data_Answer_Invariant);
   end Send_Data_Answer;

   procedure Exception_Error (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      Unused : Boolean;
      function Exception_Error_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Exception_Error_Invariant);
      -- rsp.rflx:144:10
      Handle_Error (Ctx, Got_Exception, Unused);
      Ctx.P.Next_State := S_Final;
      pragma Assert (Exception_Error_Invariant);
   end Exception_Error;

   procedure Invalid_Packet_Error (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      Unused : Boolean;
      function Invalid_Packet_Error_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Invalid_Packet_Error_Invariant);
      -- rsp.rflx:152:10
      Handle_Error (Ctx, Invalid_Packet, Unused);
      Ctx.P.Next_State := S_Final;
      pragma Assert (Invalid_Packet_Error_Invariant);
   end Invalid_Packet_Error;

   procedure Got_Answer_Packet_Error (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      Unused : Boolean;
      function Got_Answer_Packet_Error_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Got_Answer_Packet_Error_Invariant);
      -- rsp.rflx:160:10
      Handle_Error (Ctx, Got_Answer_Packet, Unused);
      Ctx.P.Next_State := S_Final;
      pragma Assert (Got_Answer_Packet_Error_Invariant);
   end Got_Answer_Packet_Error;

   procedure Stack_Id_Not_Set_Error (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      Unused : Boolean;
      function Stack_Id_Not_Set_Error_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Stack_Id_Not_Set_Error_Invariant);
      -- rsp.rflx:168:10
      Handle_Error (Ctx, Stack_Id_Not_Set, Unused);
      Ctx.P.Next_State := S_Final;
      pragma Assert (Stack_Id_Not_Set_Error_Invariant);
   end Stack_Id_Not_Set_Error;

   procedure Stack_Full_Error (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      Unused : Boolean;
      function Stack_Full_Error_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Stack_Full_Error_Invariant);
      -- rsp.rflx:176:10
      Handle_Error (Ctx, Stack_Full, Unused);
      Ctx.P.Next_State := S_Final;
      pragma Assert (Stack_Full_Error_Invariant);
   end Stack_Full_Error;

   procedure Initialize (Ctx : in out Context'Class) is
      Msg_Buffer : RFLX_Types.Bytes_Ptr;
      Answer_Buffer : RFLX_Types.Bytes_Ptr;
   begin
      RSP.Server_Allocator.Initialize (Ctx.P.Slots, Ctx.P.Memory);
      Msg_Buffer := Ctx.P.Slots.Slot_Ptr_1;
      pragma Warnings (Off, "unused assignment");
      Ctx.P.Slots.Slot_Ptr_1 := null;
      pragma Warnings (On, "unused assignment");
      RSP.RSP_Message.Initialize (Ctx.P.Msg_Ctx, Msg_Buffer);
      Answer_Buffer := Ctx.P.Slots.Slot_Ptr_2;
      pragma Warnings (Off, "unused assignment");
      Ctx.P.Slots.Slot_Ptr_2 := null;
      pragma Warnings (On, "unused assignment");
      RSP.RSP_Message.Initialize (Ctx.P.Answer_Ctx, Answer_Buffer);
      Ctx.P.Next_State := S_Receive_Stack_Select;
   end Initialize;

   procedure Finalize (Ctx : in out Context'Class) is
      Msg_Buffer : RFLX_Types.Bytes_Ptr;
      Answer_Buffer : RFLX_Types.Bytes_Ptr;
   begin
      pragma Warnings (Off, """Ctx.P.Msg_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      RSP.RSP_Message.Take_Buffer (Ctx.P.Msg_Ctx, Msg_Buffer);
      pragma Warnings (On, """Ctx.P.Msg_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      pragma Assert (Ctx.P.Slots.Slot_Ptr_1 = null);
      pragma Assert (Msg_Buffer /= null);
      Ctx.P.Slots.Slot_Ptr_1 := Msg_Buffer;
      pragma Assert (Ctx.P.Slots.Slot_Ptr_1 /= null);
      pragma Warnings (Off, """Ctx.P.Answer_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      RSP.RSP_Message.Take_Buffer (Ctx.P.Answer_Ctx, Answer_Buffer);
      pragma Warnings (On, """Ctx.P.Answer_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      pragma Assert (Ctx.P.Slots.Slot_Ptr_2 = null);
      pragma Assert (Answer_Buffer /= null);
      Ctx.P.Slots.Slot_Ptr_2 := Answer_Buffer;
      pragma Assert (Ctx.P.Slots.Slot_Ptr_2 /= null);
      RSP.Server_Allocator.Finalize (Ctx.P.Slots);
      Ctx.P.Next_State := S_Final;
   end Finalize;

   procedure Reset_Messages_Before_Write (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
   begin
      case Ctx.P.Next_State is
         when S_Receive_Stack_Select =>
            RSP.RSP_Message.Reset (Ctx.P.Msg_Ctx, Ctx.P.Msg_Ctx.First, Ctx.P.Msg_Ctx.First - 1);
         when S_Verify_Stack_Select | S_Select_Stack =>
            null;
         when S_Receive_Data_Request =>
            RSP.RSP_Message.Reset (Ctx.P.Msg_Ctx, Ctx.P.Msg_Ctx.First, Ctx.P.Msg_Ctx.First - 1);
         when S_Verify_Data_Request | S_Store | S_Get | S_Send_Data_Answer | S_Exception_Error | S_Invalid_Packet_Error | S_Got_Answer_Packet_Error | S_Stack_Id_Not_Set_Error | S_Stack_Full_Error | S_Final =>
            null;
      end case;
   end Reset_Messages_Before_Write;

   procedure Tick (Ctx : in out Context'Class) is
   begin
      case Ctx.P.Next_State is
         when S_Receive_Stack_Select =>
            Receive_Stack_Select (Ctx);
         when S_Verify_Stack_Select =>
            Verify_Stack_Select (Ctx);
         when S_Select_Stack =>
            Select_Stack (Ctx);
         when S_Receive_Data_Request =>
            Receive_Data_Request (Ctx);
         when S_Verify_Data_Request =>
            Verify_Data_Request (Ctx);
         when S_Store =>
            Store (Ctx);
         when S_Get =>
            Get (Ctx);
         when S_Send_Data_Answer =>
            Send_Data_Answer (Ctx);
         when S_Exception_Error =>
            Exception_Error (Ctx);
         when S_Invalid_Packet_Error =>
            Invalid_Packet_Error (Ctx);
         when S_Got_Answer_Packet_Error =>
            Got_Answer_Packet_Error (Ctx);
         when S_Stack_Id_Not_Set_Error =>
            Stack_Id_Not_Set_Error (Ctx);
         when S_Stack_Full_Error =>
            Stack_Full_Error (Ctx);
         when S_Final =>
            null;
      end case;
      Reset_Messages_Before_Write (Ctx);
   end Tick;

   function In_IO_State (Ctx : Context'Class) return Boolean is
     (Ctx.P.Next_State in S_Receive_Stack_Select | S_Receive_Data_Request | S_Send_Data_Answer);

   procedure Run (Ctx : in out Context'Class) is
   begin
      Tick (Ctx);
      while
         Active (Ctx)
         and not In_IO_State (Ctx)
      loop
         pragma Loop_Invariant (Initialized (Ctx));
         Tick (Ctx);
      end loop;
   end Run;

   procedure Read (Ctx : Context'Class; Chan : Channel; Buffer : out RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) is
      function Read_Pre (Message_Buffer : RFLX_Types.Bytes) return Boolean is
        (Buffer'Length > 0
         and then Offset < Message_Buffer'Length);
      procedure Read (Message_Buffer : RFLX_Types.Bytes) with
        Pre =>
          Read_Pre (Message_Buffer)
      is
         Length : constant RFLX_Types.Index := RFLX_Types.Index (RFLX_Types.Length'Min (Buffer'Length, Message_Buffer'Length - Offset));
         Buffer_Last : constant RFLX_Types.Index := Buffer'First - 1 + Length;
      begin
         Buffer (Buffer'First .. RFLX_Types.Index (Buffer_Last)) := Message_Buffer (RFLX_Types.Index (RFLX_Types.Length (Message_Buffer'First) + Offset) .. Message_Buffer'First - 2 + RFLX_Types.Index (Offset + 1) + Length);
      end Read;
      procedure RSP_RSP_Message_Read is new RSP.RSP_Message.Generic_Read (Read, Read_Pre);
   begin
      Buffer := (others => 0);
      case Chan is
         when C_Chan =>
            case Ctx.P.Next_State is
               when S_Send_Data_Answer =>
                  RSP_RSP_Message_Read (Ctx.P.Answer_Ctx);
               when others =>
                  pragma Warnings (Off, "unreachable code");
                  null;
                  pragma Warnings (On, "unreachable code");
            end case;
      end case;
   end Read;

   procedure Write (Ctx : in out Context'Class; Chan : Channel; Buffer : RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) is
      Write_Buffer_Length : constant RFLX_Types.Length := Write_Buffer_Size (Ctx, Chan);
      function Write_Pre (Context_Buffer_Length : RFLX_Types.Length; Offset : RFLX_Types.Length) return Boolean is
        (Buffer'Length > 0
         and then Context_Buffer_Length = Write_Buffer_Length
         and then Offset <= RFLX_Types.Length'Last - Buffer'Length
         and then Buffer'Length + Offset <= Write_Buffer_Length);
      procedure Write (Message_Buffer : out RFLX_Types.Bytes; Length : out RFLX_Types.Length; Context_Buffer_Length : RFLX_Types.Length; Offset : RFLX_Types.Length) with
        Pre =>
          Write_Pre (Context_Buffer_Length, Offset)
          and then Offset <= RFLX_Types.Length'Last - Message_Buffer'Length
          and then Message_Buffer'Length + Offset = Write_Buffer_Length,
        Post =>
          Length <= Message_Buffer'Length
      is
      begin
         Length := Buffer'Length;
         Message_Buffer := (others => 0);
         Message_Buffer (Message_Buffer'First .. RFLX_Types.Index (RFLX_Types.Length (Message_Buffer'First) - 1 + Length)) := Buffer;
      end Write;
      procedure RSP_RSP_Message_Write is new RSP.RSP_Message.Generic_Write (Write, Write_Pre);
   begin
      case Chan is
         when C_Chan =>
            case Ctx.P.Next_State is
               when S_Receive_Stack_Select | S_Receive_Data_Request =>
                  RSP_RSP_Message_Write (Ctx.P.Msg_Ctx, Offset);
               when others =>
                  pragma Warnings (Off, "unreachable code");
                  null;
                  pragma Warnings (On, "unreachable code");
            end case;
      end case;
   end Write;

end RFLX.RSP.Server;