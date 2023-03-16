--
-- Generated by RecordFlux 0.9.1.dev18+ge578157d on 2023-03-16
--
-- Copyright (C) 2018-2023 AdaCore GmbH
--
-- This file is distributed under the terms of the GNU Affero General Public License version 3.
--

pragma Style_Checks ("N3aAbCdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");
with RFLX.RFLX_Types.Operations;

package body RFLX.RSP.RSP_Message with
  SPARK_Mode
is

   pragma Unevaluated_Use_Of_Old (Allow);

   procedure Initialize (Ctx : out Context; Buffer : in out RFLX_Types.Bytes_Ptr; Written_Last : RFLX_Types.Bit_Length := 0) is
   begin
      Initialize (Ctx, Buffer, RFLX_Types.To_First_Bit_Index (Buffer'First), RFLX_Types.To_Last_Bit_Index (Buffer'Last), Written_Last);
   end Initialize;

   procedure Initialize (Ctx : out Context; Buffer : in out RFLX_Types.Bytes_Ptr; First : RFLX_Types.Bit_Index; Last : RFLX_Types.Bit_Length; Written_Last : RFLX_Types.Bit_Length := 0) is
      Buffer_First : constant RFLX_Types.Index := Buffer'First;
      Buffer_Last : constant RFLX_Types.Index := Buffer'Last;
   begin
      Ctx := (Buffer_First, Buffer_Last, First, Last, First - 1, (if Written_Last = 0 then First - 1 else Written_Last), Buffer, (F_Kind => (State => S_Invalid, Predecessor => F_Initial), others => (State => S_Invalid, Predecessor => F_Final)));
      Buffer := null;
   end Initialize;

   procedure Reset (Ctx : in out Context) is
   begin
      Reset (Ctx, RFLX_Types.To_First_Bit_Index (Ctx.Buffer'First), RFLX_Types.To_Last_Bit_Index (Ctx.Buffer'Last));
   end Reset;

   procedure Reset (Ctx : in out Context; First : RFLX_Types.Bit_Index; Last : RFLX_Types.Bit_Length) is
   begin
      Ctx := (Ctx.Buffer_First, Ctx.Buffer_Last, First, Last, First - 1, First - 1, Ctx.Buffer, (F_Kind => (State => S_Invalid, Predecessor => F_Initial), others => (State => S_Invalid, Predecessor => F_Final)));
   end Reset;

   procedure Take_Buffer (Ctx : in out Context; Buffer : out RFLX_Types.Bytes_Ptr) is
   begin
      Buffer := Ctx.Buffer;
      Ctx.Buffer := null;
   end Take_Buffer;

   procedure Copy (Ctx : Context; Buffer : out RFLX_Types.Bytes) is
   begin
      if Buffer'Length > 0 then
         Buffer := Ctx.Buffer.all (RFLX_Types.To_Index (Ctx.First) .. RFLX_Types.To_Index (Ctx.Verified_Last));
      else
         Buffer := Ctx.Buffer.all (1 .. 0);
      end if;
   end Copy;

   function Read (Ctx : Context) return RFLX_Types.Bytes is
     (Ctx.Buffer.all (RFLX_Types.To_Index (Ctx.First) .. RFLX_Types.To_Index (Ctx.Verified_Last)));

   procedure Generic_Read (Ctx : Context) is
   begin
      Read (Ctx.Buffer.all (RFLX_Types.To_Index (Ctx.First) .. RFLX_Types.To_Index (Ctx.Verified_Last)));
   end Generic_Read;

   procedure Generic_Write (Ctx : in out Context; Offset : RFLX_Types.Length := 0) is
      Length : RFLX_Types.Length;
   begin
      Reset (Ctx, RFLX_Types.To_First_Bit_Index (Ctx.Buffer_First), RFLX_Types.To_Last_Bit_Index (Ctx.Buffer_Last));
      Write (Ctx.Buffer.all (Ctx.Buffer'First + RFLX_Types.Index (Offset + 1) - 1 .. Ctx.Buffer'Last), Length, Ctx.Buffer'Length, Offset);
      pragma Assert (Length <= Ctx.Buffer.all'Length, "Length <= Buffer'Length is not ensured by postcondition of ""Write""");
      Ctx.Written_Last := RFLX_Types.Bit_Index'Max (Ctx.Written_Last, RFLX_Types.To_Last_Bit_Index (RFLX_Types.Length (Ctx.Buffer_First) + Offset + Length - 1));
   end Generic_Write;

   procedure Data (Ctx : Context; Data : out RFLX_Types.Bytes) is
   begin
      Data := Ctx.Buffer.all (RFLX_Types.To_Index (Ctx.First) .. RFLX_Types.To_Index (Ctx.Verified_Last));
   end Data;

   pragma Warnings (Off, "precondition is always False");

   function Successor (Ctx : Context; Fld : Field) return Virtual_Field is
     ((case Fld is
          when F_Kind =>
             (if
                 RFLX_Types.Base_Integer (Ctx.Cursors (F_Kind).Value) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Answer_Msg))
              then
                 F_Answer_Kind
              elsif
                 RFLX_Types.Base_Integer (Ctx.Cursors (F_Kind).Value) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Request_Msg))
              then
                 F_Request_Kind
              else
                 F_Initial),
          when F_Request_Kind =>
             (if
                 RFLX_Types.Base_Integer (Ctx.Cursors (F_Request_Kind).Value) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Request_Store))
              then
                 F_Request_Length
              elsif
                 RFLX_Types.Base_Integer (Ctx.Cursors (F_Request_Kind).Value) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Request_Select_Stack))
              then
                 F_Request_Stack_Id
              else
                 F_Initial),
          when F_Request_Length =>
             F_Request_Payload,
          when F_Request_Payload =>
             F_Request_Stack_Id,
          when F_Request_Stack_Id =>
             F_Answer_Kind,
          when F_Answer_Kind =>
             (if
                 RFLX_Types.Base_Integer (Ctx.Cursors (F_Answer_Kind).Value) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Answer_Data))
              then
                 F_Answer_Length
              else
                 F_Initial),
          when F_Answer_Length =>
             F_Answer_Payload,
          when F_Answer_Payload =>
             F_Final))
    with
     Pre =>
       RFLX.RSP.RSP_Message.Has_Buffer (Ctx)
       and RFLX.RSP.RSP_Message.Well_Formed (Ctx, Fld)
       and RFLX.RSP.RSP_Message.Valid_Predecessor (Ctx, Fld);

   pragma Warnings (On, "precondition is always False");

   function Invalid_Successor (Ctx : Context; Fld : Field) return Boolean is
     ((case Fld is
          when F_Kind =>
             Invalid (Ctx.Cursors (F_Answer_Kind))
             and Invalid (Ctx.Cursors (F_Request_Kind)),
          when F_Request_Kind =>
             Invalid (Ctx.Cursors (F_Request_Length))
             and Invalid (Ctx.Cursors (F_Request_Stack_Id)),
          when F_Request_Length =>
             Invalid (Ctx.Cursors (F_Request_Payload)),
          when F_Request_Payload =>
             Invalid (Ctx.Cursors (F_Request_Stack_Id)),
          when F_Request_Stack_Id =>
             Invalid (Ctx.Cursors (F_Answer_Kind)),
          when F_Answer_Kind =>
             Invalid (Ctx.Cursors (F_Answer_Length)),
          when F_Answer_Length =>
             Invalid (Ctx.Cursors (F_Answer_Payload)),
          when F_Answer_Payload =>
             True));

   function Sufficient_Buffer_Length (Ctx : Context; Fld : Field) return Boolean is
     (Ctx.Buffer /= null
      and Field_First (Ctx, Fld) + Field_Size (Ctx, Fld) < RFLX_Types.Bit_Length'Last
      and Ctx.First <= Field_First (Ctx, Fld)
      and Field_First (Ctx, Fld) + Field_Size (Ctx, Fld) - 1 <= Ctx.Written_Last)
    with
     Pre =>
       RFLX.RSP.RSP_Message.Has_Buffer (Ctx)
       and RFLX.RSP.RSP_Message.Valid_Next (Ctx, Fld);

   function Equal (Ctx : Context; Fld : Field; Data : RFLX_Types.Bytes) return Boolean is
     (Sufficient_Buffer_Length (Ctx, Fld)
      and then (case Fld is
                   when F_Request_Payload | F_Answer_Payload =>
                      Data'Length = RFLX_Types.To_Index (Field_Last (Ctx, Fld)) - RFLX_Types.To_Index (Field_First (Ctx, Fld)) + 1
                      and then (for all I in RFLX_Types.Index range RFLX_Types.To_Index (Field_First (Ctx, Fld)) .. RFLX_Types.To_Index (Field_Last (Ctx, Fld)) =>
                                   Ctx.Buffer.all (I) = Data (Data'First + (I - RFLX_Types.To_Index (Field_First (Ctx, Fld))))),
                   when others =>
                      False));

   procedure Reset_Dependent_Fields (Ctx : in out Context; Fld : Field) with
     Pre =>
       RFLX.RSP.RSP_Message.Valid_Next (Ctx, Fld),
     Post =>
       Valid_Next (Ctx, Fld)
       and Invalid (Ctx.Cursors (Fld))
       and Invalid_Successor (Ctx, Fld)
       and Ctx.Buffer_First = Ctx.Buffer_First'Old
       and Ctx.Buffer_Last = Ctx.Buffer_Last'Old
       and Ctx.First = Ctx.First'Old
       and Ctx.Last = Ctx.Last'Old
       and Ctx.Cursors (Fld).Predecessor = Ctx.Cursors (Fld).Predecessor'Old
       and Has_Buffer (Ctx) = Has_Buffer (Ctx)'Old
       and Field_First (Ctx, Fld) = Field_First (Ctx, Fld)'Old
       and Field_Size (Ctx, Fld) = Field_Size (Ctx, Fld)'Old
       and (for all F in Field =>
               (if F < Fld then Ctx.Cursors (F) = Ctx.Cursors'Old (F) else Invalid (Ctx, F)))
   is
      First : constant RFLX_Types.Bit_Length := Field_First (Ctx, Fld) with
        Ghost;
      Size : constant RFLX_Types.Bit_Length := Field_Size (Ctx, Fld) with
        Ghost;
   begin
      pragma Assert (Field_First (Ctx, Fld) = First
                     and Field_Size (Ctx, Fld) = Size);
      for Fld_Loop in reverse Field'Succ (Fld) .. Field'Last loop
         Ctx.Cursors (Fld_Loop) := (S_Invalid, F_Final);
         pragma Loop_Invariant (Field_First (Ctx, Fld) = First
                                and Field_Size (Ctx, Fld) = Size);
         pragma Loop_Invariant ((for all F in Field =>
                                    (if F < Fld_Loop then Ctx.Cursors (F) = Ctx.Cursors'Loop_Entry (F) else Invalid (Ctx, F))));
      end loop;
      pragma Assert (Field_First (Ctx, Fld) = First
                     and Field_Size (Ctx, Fld) = Size);
      Ctx.Cursors (Fld) := (S_Invalid, Ctx.Cursors (Fld).Predecessor);
      pragma Assert (Field_First (Ctx, Fld) = First
                     and Field_Size (Ctx, Fld) = Size);
   end Reset_Dependent_Fields;

   function Composite_Field (Fld : Field) return Boolean is
     (Fld in F_Request_Payload | F_Answer_Payload);

   function Get (Ctx : Context; Fld : Field) return RFLX_Types.Base_Integer with
     Pre =>
       RFLX.RSP.RSP_Message.Has_Buffer (Ctx)
       and then RFLX.RSP.RSP_Message.Valid_Next (Ctx, Fld)
       and then RFLX.RSP.RSP_Message.Sufficient_Buffer_Length (Ctx, Fld)
       and then not RFLX.RSP.RSP_Message.Composite_Field (Fld)
   is
      First : constant RFLX_Types.Bit_Index := Field_First (Ctx, Fld);
      Last : constant RFLX_Types.Bit_Index := Field_Last (Ctx, Fld);
      Buffer_First : constant RFLX_Types.Index := RFLX_Types.To_Index (First);
      Buffer_Last : constant RFLX_Types.Index := RFLX_Types.To_Index (Last);
      Offset : constant RFLX_Types.Offset := RFLX_Types.Offset ((RFLX_Types.Byte'Size - Last mod RFLX_Types.Byte'Size) mod RFLX_Types.Byte'Size);
      Size : constant Positive := (case Fld is
          when F_Kind | F_Request_Kind | F_Request_Length | F_Request_Stack_Id | F_Answer_Kind | F_Answer_Length =>
             8,
          when others =>
             Positive'Last);
      Byte_Order : constant RFLX_Types.Byte_Order := RFLX_Types.High_Order_First;
   begin
      return RFLX_Types.Operations.Extract (Ctx.Buffer, Buffer_First, Buffer_Last, Offset, Size, Byte_Order);
   end Get;

   procedure Verify (Ctx : in out Context; Fld : Field) is
      Value : RFLX_Types.Base_Integer;
   begin
      if
         Invalid (Ctx.Cursors (Fld))
         and then Valid_Predecessor (Ctx, Fld)
         and then Path_Condition (Ctx, Fld)
      then
         if Sufficient_Buffer_Length (Ctx, Fld) then
            Value := (if Composite_Field (Fld) then 0 else Get (Ctx, Fld));
            if
               Valid_Value (Fld, Value)
               and then Field_Condition (Ctx, Fld, Value)
            then
               pragma Assert ((if Fld = F_Answer_Payload then Field_Last (Ctx, Fld) mod RFLX_Types.Byte'Size = 0));
               pragma Assert ((((Field_Last (Ctx, Fld) + RFLX_Types.Byte'Size - 1) / RFLX_Types.Byte'Size) * RFLX_Types.Byte'Size) mod RFLX_Types.Byte'Size = 0);
               Ctx.Verified_Last := ((Field_Last (Ctx, Fld) + RFLX_Types.Byte'Size - 1) / RFLX_Types.Byte'Size) * RFLX_Types.Byte'Size;
               pragma Assert (Field_Last (Ctx, Fld) <= Ctx.Verified_Last);
               if Composite_Field (Fld) then
                  Ctx.Cursors (Fld) := (State => S_Well_Formed, First => Field_First (Ctx, Fld), Last => Field_Last (Ctx, Fld), Value => Value, Predecessor => Ctx.Cursors (Fld).Predecessor);
               else
                  Ctx.Cursors (Fld) := (State => S_Valid, First => Field_First (Ctx, Fld), Last => Field_Last (Ctx, Fld), Value => Value, Predecessor => Ctx.Cursors (Fld).Predecessor);
               end if;
               Ctx.Cursors (Successor (Ctx, Fld)) := (State => S_Invalid, Predecessor => Fld);
            else
               Ctx.Cursors (Fld) := (State => S_Invalid, Predecessor => F_Final);
            end if;
         else
            Ctx.Cursors (Fld) := (State => S_Incomplete, Predecessor => F_Final);
         end if;
      end if;
   end Verify;

   procedure Verify_Message (Ctx : in out Context) is
   begin
      for F in Field loop
         pragma Loop_Invariant (Has_Buffer (Ctx)
                                and Ctx.Buffer_First = Ctx.Buffer_First'Loop_Entry
                                and Ctx.Buffer_Last = Ctx.Buffer_Last'Loop_Entry
                                and Ctx.First = Ctx.First'Loop_Entry
                                and Ctx.Last = Ctx.Last'Loop_Entry);
         Verify (Ctx, F);
      end loop;
   end Verify_Message;

   function Get_Request_Payload (Ctx : Context) return RFLX_Types.Bytes is
      First : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Request_Payload).First);
      Last : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Request_Payload).Last);
   begin
      return Ctx.Buffer.all (First .. Last);
   end Get_Request_Payload;

   function Get_Answer_Payload (Ctx : Context) return RFLX_Types.Bytes is
      First : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Answer_Payload).First);
      Last : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Answer_Payload).Last);
   begin
      return Ctx.Buffer.all (First .. Last);
   end Get_Answer_Payload;

   procedure Get_Request_Payload (Ctx : Context; Data : out RFLX_Types.Bytes) is
      First : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Request_Payload).First);
      Last : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Request_Payload).Last);
   begin
      Data := (others => RFLX_Types.Byte'First);
      Data (Data'First .. Data'First + (Last - First)) := Ctx.Buffer.all (First .. Last);
   end Get_Request_Payload;

   procedure Get_Answer_Payload (Ctx : Context; Data : out RFLX_Types.Bytes) is
      First : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Answer_Payload).First);
      Last : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Answer_Payload).Last);
   begin
      Data := (others => RFLX_Types.Byte'First);
      Data (Data'First .. Data'First + (Last - First)) := Ctx.Buffer.all (First .. Last);
   end Get_Answer_Payload;

   procedure Generic_Get_Request_Payload (Ctx : Context) is
      First : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Request_Payload).First);
      Last : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Request_Payload).Last);
   begin
      Process_Request_Payload (Ctx.Buffer.all (First .. Last));
   end Generic_Get_Request_Payload;

   procedure Generic_Get_Answer_Payload (Ctx : Context) is
      First : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Answer_Payload).First);
      Last : constant RFLX_Types.Index := RFLX_Types.To_Index (Ctx.Cursors (F_Answer_Payload).Last);
   begin
      Process_Answer_Payload (Ctx.Buffer.all (First .. Last));
   end Generic_Get_Answer_Payload;

   procedure Set (Ctx : in out Context; Fld : Field; Val : RFLX_Types.Base_Integer; Size : RFLX_Types.Bit_Length; State_Valid : Boolean; Buffer_First : out RFLX_Types.Index; Buffer_Last : out RFLX_Types.Index; Offset : out RFLX_Types.Offset) with
     Pre =>
       RFLX.RSP.RSP_Message.Has_Buffer (Ctx)
       and then RFLX.RSP.RSP_Message.Valid_Next (Ctx, Fld)
       and then RFLX.RSP.RSP_Message.Valid_Value (Fld, Val)
       and then RFLX.RSP.RSP_Message.Valid_Size (Ctx, Fld, Size)
       and then Size <= RFLX.RSP.RSP_Message.Available_Space (Ctx, Fld)
       and then (if
                    RFLX.RSP.RSP_Message.Composite_Field (Fld)
                 then
                    Size mod RFLX_Types.Byte'Size = 0
                 else
                    State_Valid),
     Post =>
       Valid_Next (Ctx, Fld)
       and then Invalid_Successor (Ctx, Fld)
       and then Buffer_First = RFLX_Types.To_Index (Field_First (Ctx, Fld))
       and then Buffer_Last = RFLX_Types.To_Index (Field_First (Ctx, Fld) + Size - 1)
       and then Offset = RFLX_Types.Offset ((RFLX_Types.Byte'Size - (Field_First (Ctx, Fld) + Size - 1) mod RFLX_Types.Byte'Size) mod RFLX_Types.Byte'Size)
       and then Ctx.Buffer_First = Ctx.Buffer_First'Old
       and then Ctx.Buffer_Last = Ctx.Buffer_Last'Old
       and then Ctx.First = Ctx.First'Old
       and then Ctx.Last = Ctx.Last'Old
       and then Ctx.Buffer_First = Ctx.Buffer_First'Old
       and then Ctx.Buffer_Last = Ctx.Buffer_Last'Old
       and then Ctx.First = Ctx.First'Old
       and then Ctx.Last = Ctx.Last'Old
       and then Has_Buffer (Ctx) = Has_Buffer (Ctx)'Old
       and then Predecessor (Ctx, Fld) = Predecessor (Ctx, Fld)'Old
       and then Field_First (Ctx, Fld) = Field_First (Ctx, Fld)'Old
       and then Sufficient_Space (Ctx, Fld)
       and then (if State_Valid and Size > 0 then Valid (Ctx, Fld) else Well_Formed (Ctx, Fld))
       and then (case Fld is
                    when F_Kind =>
                       Get_Kind (Ctx) = To_Actual (Val)
                       and (if
                               RFLX_Types.Base_Integer (To_Base_Integer (Get_Kind (Ctx))) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Answer_Msg))
                            then
                               Predecessor (Ctx, F_Answer_Kind) = F_Kind
                               and Valid_Next (Ctx, F_Answer_Kind))
                       and (if
                               RFLX_Types.Base_Integer (To_Base_Integer (Get_Kind (Ctx))) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Request_Msg))
                            then
                               Predecessor (Ctx, F_Request_Kind) = F_Kind
                               and Valid_Next (Ctx, F_Request_Kind)),
                    when F_Request_Kind =>
                       Get_Request_Kind (Ctx) = To_Actual (Val)
                       and (if
                               RFLX_Types.Base_Integer (To_Base_Integer (Get_Request_Kind (Ctx))) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Request_Store))
                            then
                               Predecessor (Ctx, F_Request_Length) = F_Request_Kind
                               and Valid_Next (Ctx, F_Request_Length))
                       and (if
                               RFLX_Types.Base_Integer (To_Base_Integer (Get_Request_Kind (Ctx))) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Request_Select_Stack))
                            then
                               Predecessor (Ctx, F_Request_Stack_Id) = F_Request_Kind
                               and Valid_Next (Ctx, F_Request_Stack_Id)),
                    when F_Request_Length =>
                       Get_Request_Length (Ctx) = To_Actual (Val)
                       and (Predecessor (Ctx, F_Request_Payload) = F_Request_Length
                            and Valid_Next (Ctx, F_Request_Payload)),
                    when F_Request_Payload =>
                       (Predecessor (Ctx, F_Request_Stack_Id) = F_Request_Payload
                        and Valid_Next (Ctx, F_Request_Stack_Id)),
                    when F_Request_Stack_Id =>
                       Get_Request_Stack_Id (Ctx) = To_Actual (Val)
                       and (Predecessor (Ctx, F_Answer_Kind) = F_Request_Stack_Id
                            and Valid_Next (Ctx, F_Answer_Kind)),
                    when F_Answer_Kind =>
                       Get_Answer_Kind (Ctx) = To_Actual (Val)
                       and (if
                               RFLX_Types.Base_Integer (To_Base_Integer (Get_Answer_Kind (Ctx))) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Answer_Data))
                            then
                               Predecessor (Ctx, F_Answer_Length) = F_Answer_Kind
                               and Valid_Next (Ctx, F_Answer_Length)),
                    when F_Answer_Length =>
                       Get_Answer_Length (Ctx) = To_Actual (Val)
                       and (Predecessor (Ctx, F_Answer_Payload) = F_Answer_Length
                            and Valid_Next (Ctx, F_Answer_Payload)),
                    when F_Answer_Payload =>
                       (if Well_Formed_Message (Ctx) then Message_Last (Ctx) = Field_Last (Ctx, Fld)))
       and then (for all F in Field =>
                    (if F < Fld then Ctx.Cursors (F) = Ctx.Cursors'Old (F)))
   is
      First : RFLX_Types.Bit_Index;
      Last : RFLX_Types.Bit_Length;
   begin
      Reset_Dependent_Fields (Ctx, Fld);
      First := Field_First (Ctx, Fld);
      Last := Field_First (Ctx, Fld) + Size - 1;
      Offset := RFLX_Types.Offset ((RFLX_Types.Byte'Size - Last mod RFLX_Types.Byte'Size) mod RFLX_Types.Byte'Size);
      Buffer_First := RFLX_Types.To_Index (First);
      Buffer_Last := RFLX_Types.To_Index (Last);
      pragma Assert ((((Last + RFLX_Types.Byte'Size - 1) / RFLX_Types.Byte'Size) * RFLX_Types.Byte'Size) mod RFLX_Types.Byte'Size = 0);
      pragma Warnings (Off, "attribute Update is an obsolescent feature");
      Ctx := Ctx'Update (Verified_Last => ((Last + RFLX_Types.Byte'Size - 1) / RFLX_Types.Byte'Size) * RFLX_Types.Byte'Size, Written_Last => ((Last + RFLX_Types.Byte'Size - 1) / RFLX_Types.Byte'Size) * RFLX_Types.Byte'Size);
      pragma Warnings (On, "attribute Update is an obsolescent feature");
      pragma Assert (Size = (case Fld is
                         when F_Kind | F_Request_Kind | F_Request_Length =>
                            8,
                         when F_Request_Payload =>
                            RFLX_Types.Bit_Length (Ctx.Cursors (F_Request_Length).Value) * 8,
                         when F_Request_Stack_Id | F_Answer_Kind | F_Answer_Length =>
                            8,
                         when F_Answer_Payload =>
                            RFLX_Types.Bit_Length (Ctx.Cursors (F_Answer_Length).Value) * 8));
      if State_Valid then
         Ctx.Cursors (Fld) := (State => S_Valid, First => First, Last => Last, Value => Val, Predecessor => Ctx.Cursors (Fld).Predecessor);
      else
         Ctx.Cursors (Fld) := (State => S_Well_Formed, First => First, Last => Last, Value => Val, Predecessor => Ctx.Cursors (Fld).Predecessor);
      end if;
      Ctx.Cursors (Successor (Ctx, Fld)) := (State => S_Invalid, Predecessor => Fld);
      pragma Assert (Last = (Field_First (Ctx, Fld) + Size) - 1);
   end Set;

   procedure Set_Scalar (Ctx : in out Context; Fld : Field; Val : RFLX_Types.Base_Integer) with
     Pre =>
       not Ctx'Constrained
       and then RFLX.RSP.RSP_Message.Has_Buffer (Ctx)
       and then RFLX.RSP.RSP_Message.Valid_Next (Ctx, Fld)
       and then Fld in F_Kind | F_Request_Kind | F_Request_Length | F_Request_Stack_Id | F_Answer_Kind | F_Answer_Length
       and then RFLX.RSP.RSP_Message.Valid_Value (Fld, Val)
       and then RFLX.RSP.RSP_Message.Valid_Size (Ctx, Fld, RFLX.RSP.RSP_Message.Field_Size (Ctx, Fld))
       and then RFLX.RSP.RSP_Message.Available_Space (Ctx, Fld) >= RFLX.RSP.RSP_Message.Field_Size (Ctx, Fld)
       and then RFLX.RSP.RSP_Message.Field_Size (Ctx, Fld) in 1 .. RFLX_Types.Base_Integer'Size
       and then RFLX_Types.Fits_Into (Val, Natural (RFLX.RSP.RSP_Message.Field_Size (Ctx, Fld))),
     Post =>
       Has_Buffer (Ctx)
       and Valid (Ctx, Fld)
       and Invalid_Successor (Ctx, Fld)
       and (case Fld is
               when F_Kind =>
                  Get_Kind (Ctx) = To_Actual (Val)
                  and (if
                          RFLX_Types.Base_Integer (To_Base_Integer (Get_Kind (Ctx))) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Answer_Msg))
                       then
                          Predecessor (Ctx, F_Answer_Kind) = F_Kind
                          and Valid_Next (Ctx, F_Answer_Kind))
                  and (if
                          RFLX_Types.Base_Integer (To_Base_Integer (Get_Kind (Ctx))) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Request_Msg))
                       then
                          Predecessor (Ctx, F_Request_Kind) = F_Kind
                          and Valid_Next (Ctx, F_Request_Kind)),
               when F_Request_Kind =>
                  Get_Request_Kind (Ctx) = To_Actual (Val)
                  and (if
                          RFLX_Types.Base_Integer (To_Base_Integer (Get_Request_Kind (Ctx))) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Request_Store))
                       then
                          Predecessor (Ctx, F_Request_Length) = F_Request_Kind
                          and Valid_Next (Ctx, F_Request_Length))
                  and (if
                          RFLX_Types.Base_Integer (To_Base_Integer (Get_Request_Kind (Ctx))) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Request_Select_Stack))
                       then
                          Predecessor (Ctx, F_Request_Stack_Id) = F_Request_Kind
                          and Valid_Next (Ctx, F_Request_Stack_Id)),
               when F_Request_Length =>
                  Get_Request_Length (Ctx) = To_Actual (Val)
                  and (Predecessor (Ctx, F_Request_Payload) = F_Request_Length
                       and Valid_Next (Ctx, F_Request_Payload)),
               when F_Request_Payload =>
                  (Predecessor (Ctx, F_Request_Stack_Id) = F_Request_Payload
                   and Valid_Next (Ctx, F_Request_Stack_Id)),
               when F_Request_Stack_Id =>
                  Get_Request_Stack_Id (Ctx) = To_Actual (Val)
                  and (Predecessor (Ctx, F_Answer_Kind) = F_Request_Stack_Id
                       and Valid_Next (Ctx, F_Answer_Kind)),
               when F_Answer_Kind =>
                  Get_Answer_Kind (Ctx) = To_Actual (Val)
                  and (if
                          RFLX_Types.Base_Integer (To_Base_Integer (Get_Answer_Kind (Ctx))) = RFLX_Types.Base_Integer (To_Base_Integer (RFLX.RSP.Answer_Data))
                       then
                          Predecessor (Ctx, F_Answer_Length) = F_Answer_Kind
                          and Valid_Next (Ctx, F_Answer_Length)),
               when F_Answer_Length =>
                  Get_Answer_Length (Ctx) = To_Actual (Val)
                  and (Predecessor (Ctx, F_Answer_Payload) = F_Answer_Length
                       and Valid_Next (Ctx, F_Answer_Payload)),
               when F_Answer_Payload =>
                  (if Well_Formed_Message (Ctx) then Message_Last (Ctx) = Field_Last (Ctx, Fld)))
       and (for all F in Field =>
               (if F < Fld then Ctx.Cursors (F) = Ctx.Cursors'Old (F)))
       and Ctx.Buffer_First = Ctx.Buffer_First'Old
       and Ctx.Buffer_Last = Ctx.Buffer_Last'Old
       and Ctx.First = Ctx.First'Old
       and Ctx.Last = Ctx.Last'Old
       and Has_Buffer (Ctx) = Has_Buffer (Ctx)'Old
       and Predecessor (Ctx, Fld) = Predecessor (Ctx, Fld)'Old
       and Field_First (Ctx, Fld) = Field_First (Ctx, Fld)'Old
   is
      Buffer_First, Buffer_Last : RFLX_Types.Index;
      Offset : RFLX_Types.Offset;
      Size : constant RFLX_Types.Bit_Length := Field_Size (Ctx, Fld);
   begin
      Set (Ctx, Fld, Val, Size, True, Buffer_First, Buffer_Last, Offset);
      RFLX_Types.Lemma_Size (Val, Positive (Size));
      RFLX_Types.Operations.Insert (Val, Ctx.Buffer, Buffer_First, Buffer_Last, Offset, Positive (Size), RFLX_Types.High_Order_First);
   end Set_Scalar;

   procedure Set_Kind (Ctx : in out Context; Val : RFLX.RSP.Message_Kind) is
   begin
      Set_Scalar (Ctx, F_Kind, RFLX.RSP.To_Base_Integer (Val));
   end Set_Kind;

   procedure Set_Request_Kind (Ctx : in out Context; Val : RFLX.RSP.Request_Kind) is
   begin
      Set_Scalar (Ctx, F_Request_Kind, RFLX.RSP.To_Base_Integer (Val));
   end Set_Request_Kind;

   procedure Set_Request_Length (Ctx : in out Context; Val : RFLX.RSP.Length) is
   begin
      Set_Scalar (Ctx, F_Request_Length, RFLX.RSP.To_Base_Integer (Val));
   end Set_Request_Length;

   procedure Set_Request_Stack_Id (Ctx : in out Context; Val : RFLX.RSP.Stack_Identifier) is
   begin
      Set_Scalar (Ctx, F_Request_Stack_Id, RFLX.RSP.To_Base_Integer (Val));
   end Set_Request_Stack_Id;

   procedure Set_Answer_Kind (Ctx : in out Context; Val : RFLX.RSP.Answer_Kind) is
   begin
      Set_Scalar (Ctx, F_Answer_Kind, RFLX.RSP.To_Base_Integer (Val));
   end Set_Answer_Kind;

   procedure Set_Answer_Length (Ctx : in out Context; Val : RFLX.RSP.Length) is
   begin
      Set_Scalar (Ctx, F_Answer_Length, RFLX.RSP.To_Base_Integer (Val));
   end Set_Answer_Length;

   procedure Set_Request_Payload_Empty (Ctx : in out Context) is
      Unused_Buffer_First, Unused_Buffer_Last : RFLX_Types.Index;
      Unused_Offset : RFLX_Types.Offset;
   begin
      Set (Ctx, F_Request_Payload, 0, 0, True, Unused_Buffer_First, Unused_Buffer_Last, Unused_Offset);
   end Set_Request_Payload_Empty;

   procedure Set_Answer_Payload_Empty (Ctx : in out Context) is
      Unused_Buffer_First, Unused_Buffer_Last : RFLX_Types.Index;
      Unused_Offset : RFLX_Types.Offset;
   begin
      Set (Ctx, F_Answer_Payload, 0, 0, True, Unused_Buffer_First, Unused_Buffer_Last, Unused_Offset);
   end Set_Answer_Payload_Empty;

   procedure Initialize_Request_Payload_Private (Ctx : in out Context; Length : RFLX_Types.Length) with
     Pre =>
       not Ctx'Constrained
       and then RFLX.RSP.RSP_Message.Has_Buffer (Ctx)
       and then RFLX.RSP.RSP_Message.Valid_Next (Ctx, RFLX.RSP.RSP_Message.F_Request_Payload)
       and then RFLX.RSP.RSP_Message.Valid_Length (Ctx, RFLX.RSP.RSP_Message.F_Request_Payload, Length)
       and then RFLX_Types.To_Length (RFLX.RSP.RSP_Message.Available_Space (Ctx, RFLX.RSP.RSP_Message.F_Request_Payload)) >= Length
       and then RFLX.RSP.RSP_Message.Field_First (Ctx, RFLX.RSP.RSP_Message.F_Request_Payload) mod RFLX_Types.Byte'Size = 1,
     Post =>
       Has_Buffer (Ctx)
       and Well_Formed (Ctx, F_Request_Payload)
       and Field_Size (Ctx, F_Request_Payload) = RFLX_Types.To_Bit_Length (Length)
       and Ctx.Verified_Last = Field_Last (Ctx, F_Request_Payload)
       and Invalid (Ctx, F_Request_Stack_Id)
       and Invalid (Ctx, F_Answer_Kind)
       and Invalid (Ctx, F_Answer_Length)
       and Invalid (Ctx, F_Answer_Payload)
       and (Predecessor (Ctx, F_Request_Stack_Id) = F_Request_Payload
            and Valid_Next (Ctx, F_Request_Stack_Id))
       and Ctx.Buffer_First = Ctx.Buffer_First'Old
       and Ctx.Buffer_Last = Ctx.Buffer_Last'Old
       and Ctx.First = Ctx.First'Old
       and Ctx.Last = Ctx.Last'Old
       and Predecessor (Ctx, F_Request_Payload) = Predecessor (Ctx, F_Request_Payload)'Old
       and Valid_Next (Ctx, F_Request_Payload) = Valid_Next (Ctx, F_Request_Payload)'Old
       and Get_Kind (Ctx) = Get_Kind (Ctx)'Old
       and Get_Request_Kind (Ctx) = Get_Request_Kind (Ctx)'Old
       and Get_Request_Length (Ctx) = Get_Request_Length (Ctx)'Old
       and Field_First (Ctx, F_Request_Payload) = Field_First (Ctx, F_Request_Payload)'Old
       and Field_Last (Ctx, F_Request_Payload) = Field_Last (Ctx, Predecessor (Ctx, F_Request_Payload)) + Field_Size (Ctx, F_Request_Payload)
   is
      First : constant RFLX_Types.Bit_Index := Field_First (Ctx, F_Request_Payload);
      Last : constant RFLX_Types.Bit_Index := Field_First (Ctx, F_Request_Payload) + RFLX_Types.Bit_Length (Length) * RFLX_Types.Byte'Size - 1;
   begin
      pragma Assert (Last mod RFLX_Types.Byte'Size = 0);
      Reset_Dependent_Fields (Ctx, F_Request_Payload);
      pragma Warnings (Off, "attribute Update is an obsolescent feature");
      Ctx := Ctx'Update (Verified_Last => Last, Written_Last => Last);
      pragma Warnings (On, "attribute Update is an obsolescent feature");
      Ctx.Cursors (F_Request_Payload) := (State => S_Well_Formed, First => First, Last => Last, Value => 0, Predecessor => Ctx.Cursors (F_Request_Payload).Predecessor);
      Ctx.Cursors (Successor (Ctx, F_Request_Payload)) := (State => S_Invalid, Predecessor => F_Request_Payload);
   end Initialize_Request_Payload_Private;

   procedure Initialize_Request_Payload (Ctx : in out Context) is
   begin
      Initialize_Request_Payload_Private (Ctx, RFLX_Types.To_Length (Field_Size (Ctx, F_Request_Payload)));
   end Initialize_Request_Payload;

   procedure Initialize_Answer_Payload_Private (Ctx : in out Context; Length : RFLX_Types.Length) with
     Pre =>
       not Ctx'Constrained
       and then RFLX.RSP.RSP_Message.Has_Buffer (Ctx)
       and then RFLX.RSP.RSP_Message.Valid_Next (Ctx, RFLX.RSP.RSP_Message.F_Answer_Payload)
       and then RFLX.RSP.RSP_Message.Valid_Length (Ctx, RFLX.RSP.RSP_Message.F_Answer_Payload, Length)
       and then RFLX_Types.To_Length (RFLX.RSP.RSP_Message.Available_Space (Ctx, RFLX.RSP.RSP_Message.F_Answer_Payload)) >= Length
       and then RFLX.RSP.RSP_Message.Field_First (Ctx, RFLX.RSP.RSP_Message.F_Answer_Payload) mod RFLX_Types.Byte'Size = 1,
     Post =>
       Has_Buffer (Ctx)
       and Well_Formed (Ctx, F_Answer_Payload)
       and Field_Size (Ctx, F_Answer_Payload) = RFLX_Types.To_Bit_Length (Length)
       and Ctx.Verified_Last = Field_Last (Ctx, F_Answer_Payload)
       and Ctx.Buffer_First = Ctx.Buffer_First'Old
       and Ctx.Buffer_Last = Ctx.Buffer_Last'Old
       and Ctx.First = Ctx.First'Old
       and Ctx.Last = Ctx.Last'Old
       and Predecessor (Ctx, F_Answer_Payload) = Predecessor (Ctx, F_Answer_Payload)'Old
       and Valid_Next (Ctx, F_Answer_Payload) = Valid_Next (Ctx, F_Answer_Payload)'Old
       and Get_Kind (Ctx) = Get_Kind (Ctx)'Old
       and Get_Answer_Kind (Ctx) = Get_Answer_Kind (Ctx)'Old
       and Get_Answer_Length (Ctx) = Get_Answer_Length (Ctx)'Old
       and Field_First (Ctx, F_Answer_Payload) = Field_First (Ctx, F_Answer_Payload)'Old
       and Field_Last (Ctx, F_Answer_Payload) = Field_Last (Ctx, Predecessor (Ctx, F_Answer_Payload)) + Field_Size (Ctx, F_Answer_Payload)
   is
      First : constant RFLX_Types.Bit_Index := Field_First (Ctx, F_Answer_Payload);
      Last : constant RFLX_Types.Bit_Index := Field_First (Ctx, F_Answer_Payload) + RFLX_Types.Bit_Length (Length) * RFLX_Types.Byte'Size - 1;
   begin
      pragma Assert (Last mod RFLX_Types.Byte'Size = 0);
      Reset_Dependent_Fields (Ctx, F_Answer_Payload);
      pragma Warnings (Off, "attribute Update is an obsolescent feature");
      Ctx := Ctx'Update (Verified_Last => Last, Written_Last => Last);
      pragma Warnings (On, "attribute Update is an obsolescent feature");
      Ctx.Cursors (F_Answer_Payload) := (State => S_Well_Formed, First => First, Last => Last, Value => 0, Predecessor => Ctx.Cursors (F_Answer_Payload).Predecessor);
      Ctx.Cursors (Successor (Ctx, F_Answer_Payload)) := (State => S_Invalid, Predecessor => F_Answer_Payload);
   end Initialize_Answer_Payload_Private;

   procedure Initialize_Answer_Payload (Ctx : in out Context) is
   begin
      Initialize_Answer_Payload_Private (Ctx, RFLX_Types.To_Length (Field_Size (Ctx, F_Answer_Payload)));
   end Initialize_Answer_Payload;

   procedure Set_Request_Payload (Ctx : in out Context; Data : RFLX_Types.Bytes) is
      Buffer_First : constant RFLX_Types.Index := RFLX_Types.To_Index (Field_First (Ctx, F_Request_Payload));
      Buffer_Last : constant RFLX_Types.Index := Buffer_First + Data'Length - 1;
   begin
      Initialize_Request_Payload_Private (Ctx, Data'Length);
      pragma Assert (Buffer_Last = RFLX_Types.To_Index (Field_Last (Ctx, F_Request_Payload)));
      Ctx.Buffer.all (Buffer_First .. Buffer_Last) := Data;
      pragma Assert (Ctx.Buffer.all (RFLX_Types.To_Index (Field_First (Ctx, F_Request_Payload)) .. RFLX_Types.To_Index (Field_Last (Ctx, F_Request_Payload))) = Data);
   end Set_Request_Payload;

   procedure Set_Answer_Payload (Ctx : in out Context; Data : RFLX_Types.Bytes) is
      Buffer_First : constant RFLX_Types.Index := RFLX_Types.To_Index (Field_First (Ctx, F_Answer_Payload));
      Buffer_Last : constant RFLX_Types.Index := Buffer_First + Data'Length - 1;
   begin
      Initialize_Answer_Payload_Private (Ctx, Data'Length);
      pragma Assert (Buffer_Last = RFLX_Types.To_Index (Field_Last (Ctx, F_Answer_Payload)));
      Ctx.Buffer.all (Buffer_First .. Buffer_Last) := Data;
      pragma Assert (Ctx.Buffer.all (RFLX_Types.To_Index (Field_First (Ctx, F_Answer_Payload)) .. RFLX_Types.To_Index (Field_Last (Ctx, F_Answer_Payload))) = Data);
   end Set_Answer_Payload;

   procedure Generic_Set_Request_Payload (Ctx : in out Context; Length : RFLX_Types.Length) is
      First : constant RFLX_Types.Bit_Index := Field_First (Ctx, F_Request_Payload);
      Buffer_First : constant RFLX_Types.Index := RFLX_Types.To_Index (First);
      Buffer_Last : constant RFLX_Types.Index := RFLX_Types.To_Index (First + RFLX_Types.To_Bit_Length (Length) - 1);
   begin
      Process_Request_Payload (Ctx.Buffer.all (Buffer_First .. Buffer_Last));
      Initialize_Request_Payload_Private (Ctx, Length);
   end Generic_Set_Request_Payload;

   procedure Generic_Set_Answer_Payload (Ctx : in out Context; Length : RFLX_Types.Length) is
      First : constant RFLX_Types.Bit_Index := Field_First (Ctx, F_Answer_Payload);
      Buffer_First : constant RFLX_Types.Index := RFLX_Types.To_Index (First);
      Buffer_Last : constant RFLX_Types.Index := RFLX_Types.To_Index (First + RFLX_Types.To_Bit_Length (Length) - 1);
   begin
      Process_Answer_Payload (Ctx.Buffer.all (Buffer_First .. Buffer_Last));
      Initialize_Answer_Payload_Private (Ctx, Length);
   end Generic_Set_Answer_Payload;

end RFLX.RSP.RSP_Message;