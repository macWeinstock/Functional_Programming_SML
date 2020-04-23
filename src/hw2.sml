(* CSE 341, HW2 Provided Code *)

(* main datatype definition we will use throughout the assignment *)
datatype json =
         Num of real (* real is what SML calls floating point numbers *)
       | String of string
       | False
       | True
       | Null
       | Array of json list
       | Object of (string * json) list

(* some examples of values of type json *)
val json_pi    = Num 3.14159
val json_hello = String "hello"
val json_false = False
val json_array = Array [Num 1.0, String "world", Null]
val json_obj   = Object [("foo", json_pi), ("bar", json_array), ("ok", True)]

(* some provided one-liners that use the standard library and/or some features
   we have not learned yet. (Only) the challenge problem will need more
   standard-library functions. *)

(* dedup : string list -> string list -- it removes duplicates *)
fun dedup xs = ListMergeSort.uniqueSort String.compare xs

(* strcmp : string * string -> order compares strings alphabetically
   where datatype order = LESS | EQUAL | GREATER *)
val strcmp = String.compare                                        
                        
(* convert an int to a real *)
val int_to_real = Real.fromInt

(* absolute value of a real *)
val real_abs = Real.abs

(* convert a real to a string *)
val real_to_string = Real.toString

(* return true if a real is negative : real -> bool *)
val real_is_negative = Real.signBit

(* We now load 3 files with police data represented as values of type json.
   Each file binds one variable: small_incident_reports (10 reports), 
   medium_incident_reports (100 reports), and large_incident_reports 
   (1000 reports) respectively.

   However, the large file is commented out for now because it will take 
   about 15 seconds to load, which is too long while you are debugging
   earlier problems.  In string format, we have ~10000 records -- if you
   do the challenge problem, you will be able to read in all 10000 quickly --
   it's the "trick" of giving you large SML values that is slow.
*)

(* Make SML print a little less while we load a bunch of data. *)
       ; (* this semicolon is important -- it ends the previous binding *)
Control.Print.printDepth := 3;
Control.Print.printLength := 3;

use "parsed_small_police.sml";
(*use "parsed_medium_police.sml";*)

(* uncomment when you are ready to do the problems needing the large report*)
(*use "parsed_large_police.sml"; *)

(*
val large_incident_reports_list =
    case large_incident_reports of
        Array js => js
      | _ => raise (Fail "expected large_incident_reports to be an array")
*)

(* Now make SML print more again so that we can see what we're working with. *)
(*; Control.Print.printDepth := 20;
Control.Print.printLength := 20;*)

(**** PUT PROBLEMS 1-8 HERE ****)

fun make_silly_json(i) = 
    let fun formLstObj (i, lst) = case i of
            0 => lst
        |   i => formLstObj(i-1, (Object [("n", Num (int_to_real i)),("b", True)])::lst)
    in
        Array (formLstObj(i, []))
    end

fun assoc(k, xs) = case xs of
    [] => NONE
    | (k1, v1) :: xs => if k1 = k then SOME v1 else assoc (k, xs)

fun dot(j,f) = case j of       
    Object fs => assoc (f,fs)
    | _ => NONE;

fun one_fields(j) = 
    let fun getNames (j, acc) = case j of
           Object ((x1,v1)::j') => getNames(Object j', x1::acc)
        | _ => acc
    in
        getNames(j, [])
    end

fun no_repeats(xs) = 
    let val firstLength = length xs
    in if (length (dedup xs)) < firstLength
        then false 
        else true
    end

fun recursive_no_field_repeats(j) = case j of
    Array arr => let fun arr_helper(a) = case a of
            [] => true
            |   x::xs => recursive_no_field_repeats(x) andalso recursive_no_field_repeats(Array xs)
        in
            arr_helper(arr)
        end
    | Object obj => let fun obj_helper(obj) = 
                        let fun obj_helper1(j, acc) = case j of
                            [] => recursive_no_field_repeats(Array(acc))
                            | (x1,v1)::xs => obj_helper1(xs, v1::acc)
                        in
                            obj_helper1(obj, [])
                        end
                    in
                        no_repeats(one_fields(Object obj)) andalso obj_helper(obj)
                    end
    | _ => true

fun count_occurrences (xs, exn) =
    let fun helper(xs, currStr, currCount, acc) = case xs of
                [] => (currStr, currCount)::acc
            |   (x::xs) => case strcmp (x, currStr) of
                    LESS => raise exn
                |   EQUAL => helper(xs, x, currCount + 1, acc)
                |   GREATER => helper(xs, x, 1, (currStr, currCount)::acc)
    in
        case xs of
            [] => []
        |   x::xs => helper(xs, x, 1, [])
    end

fun string_values_for_field(str, j) = case j of
        [] => []
    |   (x::xs) => case dot(x, str) of
            SOME (String v1) => v1::string_values_for_field(str, xs)
        | _ => string_values_for_field(str, xs)


(* histogram and histogram_for_field are provided, but they use your 
   count_occurrences and string_values_for_field, so uncomment them 
   after doing earlier problems *)

(* histogram_for_field takes a field name f and a list of objects js and 
   returns counts for how often a string is the contents of f in js. *)

exception SortIsBroken

fun histogram (xs : string list) : (string * int) list =
  let
    fun compare_strings (s1 : string, s2 : string) : bool = s1 > s2

    val sorted_xs = ListMergeSort.sort compare_strings xs
    val counts = count_occurrences (sorted_xs,SortIsBroken)

    fun compare_counts ((s1 : string, n1 : int), (s2 : string, n2 : int)) : bool =
      n1 < n2 orelse (n1 = n2 andalso s1 < s2)
  in
    ListMergeSort.sort compare_counts counts
  end

fun histogram_for_field (f,js) =
  histogram (string_values_for_field (f, js))

(**** PUT PROBLEMS 9-11 HERE ****)

(*NOTE: Downloaded SML with homebrew and have Mac Catalina OS, so I'm only using the small parsed file *)

(*val res = string_values_for_field("event_clearance_description", case small_incident_reports of Array arr => arr)*)

fun filter_field_value(str, str1, j) = case j of
    [] => []
    | (x::xs) => case dot(x, str) of
        SOME (String v1) => if v1 = str1
                            then x::filter_field_value(str, str1, xs)
                            else filter_field_value(str, str1, xs)
        | _ => filter_field_value(str, str1, xs)

(*;Control.Print.printDepth := 3;  DON'T NEED THESE CAUSE IM ONLY USING THE SMALL DATASET
Control.Print.printLength := 3;*)

val large_event_clearance_description_histogram = histogram_for_field("event_clearance_description", case small_incident_reports of Array arr => arr)

val large_hundred_block_location_histogram = histogram_for_field("hundred_block_location", case small_incident_reports of Array arr => arr)

(**** PUT PROBLEMS 12-15 HERE ****)

val forty_third_and_the_ave_reports = filter_field_value("hundred_block_location", "43XX BLOCK OF UNIVERSITY WAY NE", case small_incident_reports of Array arr => arr)

val forty_third_and_the_ave_event_clearance_description_histogram = histogram_for_field("event_clearance_description", forty_third_and_the_ave_reports)

val nineteenth_and_forty_fifth_reports = filter_field_value("hundred_block_location", "45XX BLOCK OF 19TH AVE NE", case small_incident_reports of Array arr => arr)

val nineteenth_and_forty_fifth_event_clearance_description_histogram = histogram_for_field("event_clearance_description", nineteenth_and_forty_fifth_reports)

(*;Control.Print.printDepth := 20;  DON'T NEED THESE CAUSE I'M ONLY USING THE SMALL DATASET
Control.Print.printLength := 20;*)

(**** PUT PROBLEMS 16-19 HERE ****)

fun concat_with(sep, xs) = case xs of
    [] => ""
    |   (x::xs) => case xs of
            [] => x
            | _ => x ^ sep ^ (concat_with(sep, xs))

fun quote_string(xs) = "\"" ^ xs ^ "\""

fun real_to_string_for_json(num) =  case real_is_negative(num) of
        true => "-" ^ real_to_string(real_abs(num))
    | _ => real_to_string(num)

fun json_to_string(j) = case j of
        Num num => real_to_string_for_json(num)
       | String str => quote_string(str)
       | False => "false"
       | True => "true"
       | Null => "null"
       | Array arr => let fun arr_helper(arr, acc) = case arr of
                           Array (x::xs) => arr_helper(Array xs, json_to_string(x)::acc)
                        | _ => acc
                    in 
                        "[" ^ concat_with(", ", arr_helper(Array arr, [])) ^ "]"
                    end           
       | Object obj => let fun obj_helper(obj, acc) = case obj of
                           Object ((x1,v1)::xs) => obj_helper(Object xs, quote_string(x1) ^ ":" ^ json_to_string(v1)::acc)
                        | _ => acc
                    in 
                        "{" ^ concat_with(", ", obj_helper(Object obj, [])) ^ "}" 
                    end
