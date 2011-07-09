import CxStruct;
using CxTest.PhysicsStruct;

class CxTest
{
    public static function main ()
    { 
        classTest ();
        structTest ();
    }

    public static function structTest ()
    {
        var ba = new flash.utils.ByteArray ();
        ba.length = 500000*27;      //No memory manager, just allocate 100mb (AKA lazy)
        flash.Memory.select (ba);

        //var obj = CxMacro.allocateStructArray (PhysicsStruct, 1000000);
        //for (phys in obj) {}

        var time:Int = flash.Lib.getTimer ();   
        var ct = 0;
        var phys:Int = 0;     
        var vx:Int;
        var vy:Int;
        //for (phys in new FullIterator(0,1000000,24))
        var e:Int = 500000*26;
        while (phys < e)
        {
            CxMacro.unroll (10,     //Unrolls this code block 20 times in the preprocessor
            {
                ct++;
                //_[property]() means get
                //[property() means set
                //Not very pretty, but very fast.
                //All property access is inlined, these are not function calls
                phys.vx(phys._vx() + phys._ax());
                phys.vy(phys._vy() + phys._ay());

                phys.x(phys._x() + phys._vx());
                phys.y(phys._y() + phys._vy());

                phys += 26;

                //Alternatively you may do ex: MyStructClass.vx(phys,value)
                //This allows you to forcibly cast structs, or deal with
                //naming collisions
            });
        }
        time = flash.Lib.getTimer () - time;
        trace ("Struct: " + time + "ms " + ct);
    }

    public static function classTest ()
    {
        var objects = [];
        for (i in 0...1000000)
        {
            objects.push (new Physics ());
        }

        var time:Int = flash.Lib.getTimer ();
        var ct:Int = 0;
        var vx:Int;
        var vy:Int;
        var i:Int = 0;
        var e:Int = 500000;
        while (i < e)
        {
            CxMacro.unroll (10,
            {  
                var phys = objects[i];
                ct++;
                phys.vx = phys.vx + phys.ax;
                phys.vy = phys.vy + phys.ay;

                phys.y = phys.x + phys.vx;
                phys.x = phys.y + phys.vy;
                i++;
            });
        }
        time = flash.Lib.getTimer () - time;
        trace ("Class: " + time + "ms " + ct);
    }
}

//Extending CxStruct causes this class to store fields in flash.Memory
//A class may also extend CxUnion<BaseStruct> for unions.
//When defining a union, it will add data to the struct, not union.
//Valid types are Float, Double, Byte, Int16, Int
//Use property name for set, and _property for get
//You may perform typecasting when using Unions
//
// class Struct1 extends CxStruct
// {
//      var i:Int;  //bytes 0-4 will be interpreted as int
// }
// Struct1.i(myStructPointer, 0x379);
//
// class Struct2 extends CxUnion<Struct1>
// {
//      var f:Float;  //bytes 0-4 will be interpreted as float
// }
// Struct1.f(myStructPointer, 76.930);
// 
// Typecasting can help with unpacking ARGB colors, invSqrt functions, and more
//

class PhysicsStruct extends CxStruct
{
    var x:Int; var y:Int;
    var vx:Int; var vy:Int;
    var ax:Int; var ay:Int;
}

using CxTest.PhysicsStruct;
class PhysicsStructTools
{
    public static inline function construct (struct:Struct, x:Int, y:Int, vx:Int, 
                                             vy:Int, ax:Int, ay:Int)
    {
        struct.x(x); struct.y(y); 
        struct.vx(vx); struct.vy(vy); 
        struct.ax(ax); struct.ay(ay);
    }
}


class Physics
{
    public function new (?x:Int, ?y:Int, ?vx:Int, 
                         ?vy:Int, ?ax:Int, ?ay:Int)
    {
        this.x = x;
        this.y = y;
        this.vx = vx;
        this.vy = vy;
        this.ax = ax;
        this.ay = ay;
    }

    public var x:Int;
    public var y:Int;

    public var vx:Int;
    public var vy:Int;

    public var ax:Int;
    public var ay:Int;
}

class FullIterator
{
    public var min:Int;
    public var max:Int;
    var jump:Int;
    
    public function new (min : Int, max : Int, jump:Int)
    {
        this.min = min;
        this.max = max;
        this.jump = jump;
    }

    public inline function iterator ()
    {
        return new PhysStructIter (min,max,jump);
    }
}

class PhysStructIter {

	var min : Int;
	var max : Int;
	var jump:Int;

	/**
		Iterate from [min] (inclusive) to [max] (exclusive).
		If [max <= min], the iterator will not act as a countdown.
	**/
	public function new( min : Int, max : Int, jump:Int ) {
	    trace (min + ":" + max + ":" + jump);
		this.min = min;
		this.max = max;
		this.jump = jump;
	}

	/**
		Returns true if the iterator has other items, false otherwise.
	**/
	public function hasNext():Bool {
		return min < max;
	}

	/**
		Moves to the next item of the iterator.
	**/
	public function next():Int {
		return min+=jump;
	}

}











