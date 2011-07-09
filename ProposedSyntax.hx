//Personally I'd rather just do things the way it is now.
//          without type safety
//But people complain all the time about type safety....
//          Afterall, why use your brain when you can spam 
//          F5 and read your list of compiler errors.

function A ()
{
    allocate_struct (myStruct, Color);  //creates __STRUCT__myStruct:Struct and __STRUCTID__myStruct:Int

    struct(myStruct).color (0xFF00FF00);    //Checks if __STRUCTID__ is avail in the locals, if not, it creates it.
    --OR--
    struct(myStruct.color) = 0xFF00FF00;
    --OR--
    myStruct.struct.color = 0xFF00FF00;
    //You get the point.

    var newStruct = myStruct;   //Fails because myStruct doesn't actually exist
    structCopy(myStruct, newStruct);

    
    B (struct(myStruct));       //passes __STRUCT__ to B
}

function B (struct:Struct)
{
    trace (struct(myStruct)._color);    //Fails to find __STRUCTID__, so it generates it.
}


class Color extends CxStruct
{
    var color:Int32;
}

class ARGB implements CxUnion<Color>
{
    var a:Byte;
    var r:Byte;
    var g:Byte;
    var b:Byte;
}
