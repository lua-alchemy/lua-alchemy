/* bridge_as3_c.h -- The C<->AS3 bridge helper functions
 */
#ifndef BRIDGE_AS3_C_H_
#define BRIDGE_AS3_C_H_

#include <AS3.h>
#include "lua-alchemy.h"

/* Some global variables initialized in initialize_as3_constants() */
extern AS3_Val no_params;
extern AS3_Val zero_param;
extern AS3_Val Number_class;
extern AS3_Val int_class;
extern AS3_Val String_class;
extern AS3_Val Boolean_class;
extern AS3_Val flash_utils_namespace;
extern AS3_Val getQualifiedClassName_method;
extern AS3_Val Array_class;

void initialize_as3_constants();
AS3_Val get_class(const char * as_namespaceclass_path);
AS3_Val get_class2(const char * as_namespace_path, const char * as_class_path);
BOOL is_null(AS3_Val val);
AS3_Malloced_Str get_string_bytes(AS3_Val str, size_t * size_in_bytes);

#endif /* BRIDGE_AS3_C_H_ */
