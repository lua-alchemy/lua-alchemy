/* bridge_as3_c.c -- The C<->AS3 bridge helper functions
 */
#include "bridge_as3_c.h"

#include <string.h>

AS3_Val no_params = NULL;
AS3_Val zero_param = NULL;
AS3_Val Number_class = NULL;
AS3_Val int_class = NULL;
AS3_Val String_class = NULL;
AS3_Val Boolean_class = NULL;
AS3_Val flash_utils_namespace = NULL;
AS3_Val getQualifiedClassName_method = NULL;
AS3_Val Array_class = NULL;

/* setup some useful constants */
void initialize_as3_constants()
{
  no_params = AS3_Array("");
  zero_param = AS3_Int(0);
  Number_class = get_class("Number");
  int_class = get_class("int");
  String_class = get_class("String");
  Boolean_class = get_class("Boolean");
  flash_utils_namespace = AS3_String("flash.utils");
  getQualifiedClassName_method = AS3_NSGetS(flash_utils_namespace, "getQualifiedClassName");
  Array_class = get_class("Array");	
}

/*
* Get an actionscript class with the given namespace and class name
* in the format: package::ClassName
*/
AS3_Val get_class(const char * as_class_path)
{
  AS3_Val as_namespace;
  AS3_Val as_class;
  char * class_ptr = NULL;

  /* TODO might want to store classes in a table to save loading again */

  class_ptr = strstr(as_class_path, "::");

  if (class_ptr > as_class_path)
  {
    as_namespace = AS3_StringN(as_class_path, (class_ptr - as_class_path) / sizeof(char));
    as_class = AS3_String(class_ptr + 2);
  }
  else
  {
    as_namespace = AS3_Undefined();
    as_class = AS3_String(as_class_path);
  }

  AS3_Val ret = AS3_NSGet(as_namespace, as_class);

  /* TODO check for failure getting class */

  AS3_Release(as_namespace);
  AS3_Release(as_class);

  return ret;
}

/*
  TODO: Ugly workaround. Remove.
        See http://tinyurl.com/a9djb2
*/
BOOL is_null(AS3_Val val)
{
  BOOL result = FALSE;
  AS3_Val argsVal = AS3_Array("AS3ValType", val);
  AS3_Val classNameVal = AS3_Call(getQualifiedClassName_method, NULL, argsVal);
  AS3_Malloced_Str className = AS3_StringValue(classNameVal);
  AS3_Release(argsVal);
  AS3_Release(classNameVal);

  result = (strncmp(className, "null", 4) == 0);

  free(className);

  return result;
}

