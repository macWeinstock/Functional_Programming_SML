(* CSE 341, Homework 2 Tests *)

use "hw2.sml";

(* You will surely want to add more! *)

(* warning: because real is not an eqtype, json is not an eqtype, so you cannot 
   use = on anything including something of type json.
   See test1, test3, and test9 for examples of how to work around this. *)

val epsilon = 0.0001
fun check_real (r1,r2) = Real.abs (r1 - r2) < epsilon

val test1 =
    case make_silly_json 2 of
        Array [Object [("n",Num x),
                       ("b",True)],
               Object [("n",Num y),
                       ("b",True)]]
        => check_real (x,1.0) andalso check_real(y,2.0)
      | _ => false

(*val test1b =
    case make_silly_json 3 of
        Array [Object [("n",Num x),
                       ("b",True)],
               Object [("n",Num y),
                       ("b",True)]
               Object [("n",Num z),
                       ("b",True)]]*)

(*Given by Prof.*)
val test2 = assoc ("foo", [("bar",17),("foo",19)]) = SOME 19

(*Given by Prof.*)
val test3 = case dot (json_obj, "ok") of SOME True => true |  _ => false

val test4 = one_fields json_obj = rev ["foo","bar","ok"]

val test4b = one_fields (Object [("n",Num 1.0),("b",True)])

val test4c = one_fields (Object [])

val test5 = not (no_repeats ["foo","bar","foo"])

val test5b = no_repeats ["j","s","n"]

val test5c = no_repeats ["m","a","c","a"]

val test5d = no_repeats []

val nest = Array [Object [],
                  Object[("a",True),
                         ("b",Object[("foo",True),
                                     ("foo",True)]),
                         ("c",True)],
                  Object []]

val test6 = not (recursive_no_field_repeats nest)

val nest1 = Array [Object [],
                  Object[("a",True),
                         ("b",Object[("foo",True)]),
                         ("c",True)],
                  Object []]

val test6b = not (recursive_no_field_repeats nest1)

 (* any order is okay, so it's okay to fail this test due to order *)
val test7a = count_occurrences (["a", "a", "b"], Fail "")

val test7b = count_occurrences (["b", "a", "b"], Fail "") = []
             handle (Fail "") => true 

val test8 = string_values_for_field ("x", [Object [("a", True),("x", String "foo")],
                                           Object [("x", String "bar"), ("b", True)]])
            = ["foo","bar"]

val test8b = string_values_for_field ("x", [Object [("a", True),("x", String "foo")],
                                           Object [("b", True)]])

val test8c = string_values_for_field ("x", [Object [("a", True)],
                                           Object [("b", True)]])

val test9 = 
    case filter_field_value ("x", "foo",
                             [Object [("x", String "foo"), ("y", String "bar")],
                              Object [("x", String "foo"), ("y", String "baz")],
                              Object [("x", String "a")],
                              Object []]) of
        [Object [("x",String "foo"),("y",String "bar")],
         Object [("x",String "foo"),("y",String "baz")]] => true
      | _ => false

val test9b = filter_field_value ("x", "foo",
                             [Object [("x", String "foo"), ("y", String "bar")],
                              Object [("x", String "foo"), ("y", String "baz")],
                              Object [("x", String "a")],
                              Object []])                 

val test16 = concat_with("a",["b","n","na"]) = "banana"

val test16b = concat_with("=",["m","a","c","w","e","i","n","s","t","o","c","k"]) = "m=a=c=w=e=i=n=s=t=o=c=k"

val test17 = quote_string "foo" = "\"foo\""

val test17b = quote_string("mac") = "\"mac\""

val test17c = quote_string ""

val test18 = real_to_string_for_json ~4.305 = "-4.305"

val test18b = real_to_string_for_json 4.305 = "4.305"

val test18c = real_to_string_for_json ~1003.49 = "-1003.49"

val test19 = json_to_string json_obj (*= 
             "{\"foo\" : 3.14159, \"bar\" : [1.0, \"world\", null], \"ok\" : true}"*)
val test19b = json_to_string json_array

val test19c = json_to_string json_pi

val test19d = json_to_string json_false


