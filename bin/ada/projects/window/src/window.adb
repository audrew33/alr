 with Ada.Text_IO;
 with Interfaces.C;
 with Interfaces.C.Pointers;
 with Interfaces.C.Strings;
 
 procedure window is
   use  Interfaces.C;
 
   type int_array is array (size_t range <>) of aliased int with Pack;
 
   package Int_Pointers is new Pointers (
     Index              => size_t,
     Element            => int,
     Element_Array      => int_array,
     Default_Terminator => 0
   );
 
   -- int setupterm (char *term, int fildes, int *errret);
   function Get_Terminal_Data (
     terminal           : Interfaces.C.Strings.chars_ptr; 
     file_descriptor    : int; 
     error_code_pointer : Int_Pointers.Pointer
   ) return int
   with Import => True, Convention => C, External_Name => "setupterm";
 
   -- int tigetnum (char *name);
   function Get_Numeric_Value (name : Interfaces.C.Strings.chars_ptr) return int
   with Import => True, Convention => C, External_Name => "tigetnum";
 
   function Format (value : int) return String is
     result : String := int'Image (value);
   begin
     return (if result(1) = ' ' then result(2..result'Last) else result);
   end Format;
 
   error_code         : aliased int;
   error_code_pointer : Int_Pointers.Pointer := error_code'Access;
 
 begin
   if Get_Terminal_Data (Interfaces.C.Strings.Null_Ptr, 1, error_code_pointer) = 0 then
     Ada.Text_IO.Put_Line (
       "Window size: " &
       Format (Get_Numeric_Value (Interfaces.C.Strings.New_String ("cols"))) & "x" & 
       Format (Get_Numeric_Value (Interfaces.C.Strings.New_String ("lines")))
     );
   else
     Ada.Text_IO.Put_Line ("Can't access terminal data");
   end if;
 end window;
