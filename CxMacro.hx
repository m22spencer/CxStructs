import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
class CxMacro
{
    @:macro static var structPosition:Int = 0;
    @:macro public static function allocateStruct (type:Expr):Expr
    {
        var bsize:String = switch (type.expr)
        {
            case EConst(c):
                switch (c)
                {
                    case CType(s):
                        (s+".__SIZE__");
                    default:
                        throw "Error2";
                }

            default:
                throw "Error";
        }
    
        #if SAFE_STRUCTS
            #error
        #else
            return Context.parse ("CxStruct.pos+="+bsize, Context.currentPos());
        #end
    }

    @:macro public static function allocateStructArray (type:Expr, num:Expr):Expr
    {
        var bnum:Int = switch (num.expr)
        {
            case EConst (c):
                switch (c)
                {
                    case CInt (n):
                        Std.parseInt (n);
                    default:
                        throw "Error";
                }
            default:
                throw "Error";

        }

        var bsize:String = switch (type.expr)
        {
            case EConst(c):
                switch (c)
                {
                    case CType(s):
                        (s+".__SIZE__");
                    default:
                        throw "Error2";
                }

            default:
                throw "Error";
        }
    
        #if SAFE_STRUCTS
            #error
        #else
            //return Context.parse ("{start:CxStruct.pos, end:CxStruct.pos+="+bsize+"*"+bnum+"}", Context.currentPos());
            return Context.parse ("new FullIterator (CxStruct.pos, CxStruct.pos+="+bsize+"*"+bnum+", "+bsize+")", Context.currentPos());
        #end
    }

    @:macro public static function structSize (type:Expr)
    {
        switch (type.expr)
        {
            case EConst(c):
                switch (c)
                {
                    case CType(s):
                        return Context.parse (s+".__SIZE__", Context.currentPos());
                    default:
                        throw "Error2";
                }

            default:
                throw "Error";
        }
    
        return null;

    }

    static inline function intPath () return TPath({pack:[], name:"Int", params:[], sub:null})
    static inline function structPath () return TPath({pack:[],name:"Class", params:[TPType (TPath({pack:[],name:"CxStruct", params:[], sub:null}))], sub:null})
    /*
        { 
	        expr => ENew({ 
		        sub => null, 
		        name => Color,
		        pack => [], 
		        params => [] 
	        },
	        [{ 
		        expr => EConst(CInt(33)), 
		        pos => #pos(CxLinear.hx:9: characters 51-53) 
	        }]), 
	        pos => #pos(CxLinear.hx:9: characters 41-54) 
        }
    */

    @:macro public static function unroll (t:Int, e:Expr):Expr
    {
        var block = [];
        for (i in 0...t)
        {
            block.push (e);
        }
        return {expr:EBlock(block), pos:Context.currentPos()}
    }

    @:macro public static var offset:Int = 0;
    @:macro public static function compileStruct ():Array<Field>
    {
        var pos = haxe.macro.Context.currentPos ();
        var fields = Context.getBuildFields();
        var newFields:Array<Field> = [];

        offset = 0;

        for (field in fields)
        {
            switch (field.kind)
            {
                case FVar(t,e):
                    switch (t)
                    {
                        case TPath(p):
                            switch (p.name)
                            {
                                case "Byte":
                                    var tfunc = 
                                    {
                                        args:[{value:null,name:"o",opt:false, type:TPath({pack:[],name:"Dynamic", params:[],sub:null})}],
                                        //args:[],
                                        ret:TPath({sub:null, name:"Int", pack:[], params:[]}),
                                                
                                        expr:null,
                                        params:[],
                                    }
                                    var code:String = 
                                    #if SAFE_STRUCTS
                                        "return flash.Memory.getByte (o.o+"+offset+")";
                                    #else
                                        "return flash.Memory.getByte (o+"+offset+")";
                                    #end
                                    
                                    var fexpr = Context.parse(code, Context.currentPos());
                                    var fbody = {expr:EReturn(fexpr), pos : Context.currentPos() };
                                    tfunc.expr = fbody;
                                    
                                    newFields.push ({name:"_"+field.name, doc :null, meta:[], access:[AInline,APublic,AStatic], kind:FFun(tfunc),pos:pos});

                                    var tfunc = 
                                    {
                                        args:[{value:null,name:"o",opt:false, type:TPath({pack:[],name:"Int", params:[],sub:null})},{value:null,name:"v",opt:false, type:TPath({pack:[],name:"Int", params:[],sub:null})}],
                                        //args:[],
                                        ret:null, //TPath({sub:null, name:"Void", pack:[], params:[]}),
                                        expr:null,
                                        params:[],
                                    }
                                    var e:Expr = Context.parse("flash.Memory.setByte (o+"+offset+",v)",Context.currentPos());
                                    tfunc.expr = {expr:EBlock ([e]),pos:Context.currentPos()};
                                    
                                    newFields.push ({name:field.name, doc :null, meta:[], access:[AInline,APublic,AStatic], kind:FFun(tfunc),pos:pos});

                                    offset+=1;

                                case "Int16":
                                    var tfunc = 
                                    {
                                        args:[{value:null,name:"o",opt:true, type:TPath({pack:[],name:"Int", params:[],sub:null})}],
                                        //args:[],
                                        ret:TPath({sub:null, name:"Int", pack:[], params:[]}),
                                        expr:null,
                                        params:[],
                                    }
                                    var code:String = 
                                    "return flash.Memory.getUI16(o+"+offset+")";

                                    
                                    var fexpr = Context.parse(code, Context.currentPos());
                                    var fbody = {expr:EReturn(fexpr), pos : Context.currentPos() };
                                    tfunc.expr = fbody;
                                    
                                    newFields.push ({name:"_"+field.name, doc :null, meta:[], access:[AInline,APublic,AStatic], kind:FFun(tfunc),pos:pos});

                                    var tfunc = 
                                    {
                                        args:[{value:null,name:"o",opt:false, type:TPath({pack:[],name:"Int", params:[],sub:null})},{value:null,name:"v",opt:false, type:TPath({pack:[],name:"Int", params:[],sub:null})}],
                                        //args:[],
                                        ret:null, //TPath({sub:null, name:"Void", pack:[], params:[]}),
                                        expr:null,
                                        params:[],
                                    }
                                    var e:Expr = Context.parse("flash.Memory.setI16 (o+"+offset+",v)",Context.currentPos());
                                    tfunc.expr = {expr:EBlock ([e]),pos:Context.currentPos()};
                                    
                                    newFields.push ({name:field.name, doc :null, meta:[], access:[AInline,APublic,AStatic], kind:FFun(tfunc),pos:pos});
                                    
                                    offset+=2;
                                    
                                case "Int":
                                    var tfunc = 
                                    {
                                        args:[{value:null,name:"o",opt:false, type:TPath({pack:[],name:"Int", params:[],sub:null})}],
                                        //args:[],
                                        ret:TPath({sub:null, name:"Int", pack:[], params:[]}),
                                        expr:null,
                                        params:[],
                                    }
                                    var code:String = 
                                    "return flash.Memory.getI32 (o+"+offset+")";
                                    
                                    var fexpr = Context.parse(code, Context.currentPos());
                                    var fbody = {expr:EReturn(fexpr), pos : Context.currentPos() };
                                    tfunc.expr = fbody;
                                    
                                    newFields.push ({name:"_"+field.name, doc :null, meta:[], access:[AInline,APublic,AStatic], kind:FFun(tfunc),pos:pos});

                                    var tfunc = 
                                    {
                                        args:[{value:null,name:"o",opt:false, type:TPath({pack:[],name:"Int", params:[],sub:null})},{value:null,name:"v",opt:false, type:TPath({pack:[],name:"Int", params:[],sub:null})}],
                                        //args:[],
                                        ret:null, //TPath({sub:null, name:"Void", pack:[], params:[]}),
                                        expr:null,
                                        params:[],
                                    }
                                    var e:Expr = Context.parse("flash.Memory.setI32 (o+"+offset+",v)",Context.currentPos());
                                    tfunc.expr = {expr:EBlock ([e]),pos:Context.currentPos()};
                                    
                                    newFields.push ({name:field.name, doc :null, meta:[], access:[AInline,APublic,AStatic], kind:FFun(tfunc),pos:pos});

                                    offset+=4;
                                    
                                case "Float":
                                    var tfunc = 
                                    {
                                        args:[{value:null,name:"o",opt:false, type:TPath({pack:[],name:"Int", params:[],sub:null})}],
                                        //args:[],
                                        ret:TPath({sub:null, name:"Float", pack:[], params:[]}),
                                        expr:null,
                                        params:[],
                                    }
                                    var code:String = 
                                    "return flash.Memory.getFloat (o+"+offset+")";
                                    
                                    var fexpr = Context.parse(code, Context.currentPos());
                                    var fbody = {expr:EReturn(fexpr), pos : Context.currentPos() };
                                    tfunc.expr = fbody;
                                    
                                    newFields.push ({name:"_"+field.name, doc :null, meta:[], access:[AInline,APublic,AStatic], kind:FFun(tfunc),pos:pos});

                                    var tfunc = 
                                    {
                                        args:[{value:null,name:"o",opt:false, type:TPath({pack:[],name:"Int", params:[],sub:null})},{value:null,name:"v",opt:false, type:TPath({pack:[],name:"Float", params:[],sub:null})}],
                                        //args:[],
                                        ret:null, //TPath({sub:null, name:"Void", pack:[], params:[]}),
                                        expr:null,
                                        params:[],
                                    }
                                    var e:Expr = Context.parse("flash.Memory.setFloat (o+"+offset+",v)",Context.currentPos());
                                    tfunc.expr = {expr:EBlock ([e]),pos:Context.currentPos()};
                                    
                                    newFields.push ({name:field.name, doc :null, meta:[], access:[AInline,APublic,AStatic], kind:FFun(tfunc),pos:pos});

                                    offset+=4;
                                default:
                                    throw "Failure";
                            }
                        default:
                            throw "Only TPath is supported";
                    }
                default:
                    throw "Only FVar is supported";
            }
        }

        var sct:ComplexType = TPath({sub:null, name:"Int", pack:[], params:[]});
        var expr:Expr = Context.parse(offset+"", Context.currentPos());

        newFields.push ({name:"__SIZE__", doc :null, meta:[], access:[AInline,APublic,AStatic], kind:FVar(sct,expr),pos:pos});

        /*
        var tfunc = 
        {
            args:[{value:null,name:"o",opt:false, type:TPath({pack:[],name:"Int", params:[],sub:null})}],
            //args:[],
            ret:TPath({sub:null, name:"Float", pack:[], params:[]}),
            expr:null,
            params:[],
        }
        var code:String = 
        "return flash.Memory.getFloat (o+"+offset+")";
        offset+=4;
        var fexpr = Context.parse(code, Context.currentPos());
        var fbody = {expr:EReturn(fexpr), pos : Context.currentPos() };
        tfunc.expr = fbody;
        
        newFields.push ({name:"test_GET", doc :null, meta:[], access:[AInline,APublic,AStatic], kind:FFun(tfunc),pos:pos});
        */
        
        return newFields;
    }
}
