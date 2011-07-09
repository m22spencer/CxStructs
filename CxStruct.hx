/*
@:autoBuild (Macro.build()) class Struct
{
   
    var pos:Int;
}
*/

@:autoBuild(CxMacro.compileStruct ()) class CxStruct
{
    var addr:Int;
    public function new (addr:Int){this.addr=addr;}

    public static var pos:Int = 0;
    public static inline var size:Int = 4;
}

@:keep interface CxUnion<T>
{
    
}

class CxStructIter {

	var min : Int;
	var max : Int;
	var jump:Int;

	/**
		Iterate from [min] (inclusive) to [max] (exclusive).
		If [max <= min], the iterator will not act as a countdown.
	**/
	public function new( min : Int, max : Int, jump:Int ) {
		this.min = min;
		this.max = max;
		this.jump = jump;
	}

	/**
		Returns true if the iterator has other items, false otherwise.
	**/
	public function hasNext() {
		return min < max;
	}

	/**
		Moves to the next item of the iterator.
	**/
	public function next() {
		return min+=jump;
	}

}

class Byte{}
class Int16{}
class Int32{}

#if SAFE_STRUCTS
typedef Struct = {o:Int};
#else
typedef Struct = Int;
#end
