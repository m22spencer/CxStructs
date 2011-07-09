

function A ()
{
    allocate_struct (myStruct, Color);  //creates __STRUCT__myStruct:Struct and __STRUCTID__myStruct:Int

    struct(myStruct).color (0xFF00FF00);    //Checks if __STRUCTID__ is avail in the locals, if not, it creates it.
    --OR--
    struct(myStruct.color) = 0xFF00FF00;
    --OR--
    myStruct.struct.color = 0xFF00FF00;
    You get the point.

    var myOtherStructVar = myStruct;   //Fails because myStruct doesn't actually exist

    
    B (myStruct);       //passes __STRUCT__ to B
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
