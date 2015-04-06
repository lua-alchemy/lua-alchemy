The AS3 Sugar provides a Lua-like way to access AS3 class and instance creation, property getter/setters, and function calls.

Values return from sugar are always AS3 Objects for performance reasons.  If you need to perform Lua operations on these values, you should convert them to Lua types using as3.tolua(value).
```
example = as3.class.String.new("Hello")
hello = as3.tolua(example) .. " World!"
as3.trace(hello) -- Traces "Hello World!"
```

**Note:** Only classes that have been included in the SWF can be created. For the demo all of mx.containers and mx.controls have been included along with all the top level and default classes all SWFs get.

Sugar is optional feature. See UsingRawLuaAlchemy.

### Create AS3 Object
```
syntax = as3.class.ClassName.new(param1, ..., paramN)
example1 = as3.class.String.new("Hello There")
example2 = as3.class.flash.utils.ByteArray.new()
```

### Get Member Property
```
value = as3obj.property
example = as3.class.Array.new()
len = example.length
```

### Set Member Property
```
as3obj.property = value
example = as3.class.MyClass.new()
example.text = "Hello There"
```

### Call Member Function
```
return = as3obj.function([param1, ..., paramN])
example1 = as3.class.Array.new()
example1.push(5)

example2 = as3.class.MyClass.new()
example2.someFunction()
result = example2.anotherFunction(1, "hello")
```

### Get A Class
```
syntax = as3.class.ClassName.class()
example = as3.class.flash.utils.ByteArray.class()
```
You should be able to call static functions or get static methods using this class just as if it were an instance created with new.  But sometimes you may want to directly call into a class without creating an instance like done in ActionScript

### Get Static Property
```
syntax = as3.class.ClassName.staticProperty
example = as3.class.MyClass.SOME_CONSTANT
```

### Set Static Property
```
as3.class.ClassName.staticProperty = value
as3.class.MyClass.text = "hello"
```

### Call Static Function
```
as3.class.ClassName.staticFunction([param1, ..., paramN])
as3.class.MyClass.someStaticFunction()
v = as3.class.MyClass.anotherStaticFunction(1, 6, 999)
```

### Call Namespace Function
```
as3.namespace.ClassName.namespaceFunction([param1, ..., paramN])
as3.namespace.MyClass.someNamespaceFunction()
v = as3.namespace.MyClass.anotherNamespaceFunction(1, 6, 999)
```