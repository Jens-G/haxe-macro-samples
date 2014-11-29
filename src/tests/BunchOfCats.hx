package tests ;

import haxe.Int32;
import haxe.macro.Expr;  
import haxe.macro.Context;

using haxe.macro.ExprTools;  

@caption("Countless animals")
class BunchOfCats extends Testable {
	
	private static function GetDescription(count : Float, what : String) : String {		
		if ( count <= 0)
			return 'not even half a ${what}';
		else if ( count <= 1)
			return 'one $what';
		else if ( count <= 5)
			return 'a handful of ${what}s';
		else if ( count <= 10)
			return 'a couple of ${what}s';
		else if ( count <= 14)
			return 'about a dozen ${what}s';
		else if ( count <= 50)
			return 'a bunch of ${what}s';
		else if ( count <= 120)
			return 'quite a pile of ${what}s';
		else if ( count <= 500)
			return 'truckloads of ${what}s';
		else
			return '${count} ${what}s, an really insane amount';
	}

	macro static function Describe(count : Expr, what : String) : Expr {		
		
		switch(count.expr) {

			case EConst(c) : 			
				switch(c) {
					
					case CInt(value):  
						return macro $v{ GetDescription(Std.parseInt(value), what) };
						
					case CFloat(value):  
						return macro $v{ GetDescription(Std.parseFloat(value), what) };
						
					case CIdent(value):
						var p = Context.currentPos(); 
						var func = macro GetDescription;
						var arg1 = count; 
						var arg2 = macro $v{what};
						return { expr: ECall( func, [ arg1, arg2]), pos: p};
						
					default:  
						Context.fatalError('argument 1 must be Float or Int, found ${c}', Context.currentPos());		
						return macro $v { null };
				}
			
			case ECall(c,args) : 			
				var p = Context.currentPos(); 
				var func = macro GetDescription;
				var arg1 = count;
				var arg2 = { expr: EConst( CString('$what')), pos: p};
				macro var args : Array<Expr> = [ arg1, arg2];
				return { expr: ECall( func, [ arg1, arg2]), pos: p};
				
			default:  
				Context.fatalError('argument 1 must be numeric', Context.currentPos());		
				return macro $v { null };
		}
	}
	
	
	@feature('describer')
    public override function Execute() : Void {
		super.Execute();
	}
	
	
	@feature('describer')
    public override function Test() : Void {
		Output.Info("First I ran into " + Describe(1, 'cat') + "."); 			
		Output.Info("Next I stumbled across " + Describe(11, 'cat') + ".");			
		Output.Info("A few minutes later " + Describe(40, 'cat') + " crossed my way.");			
		Output.Info("Even though I have only seen " + Describe(52, 'cat') + " that day, "
		           +"it felt as if it were " + Describe(300, 'cat') + ".");					  

		var amount = Date.now().getSeconds();
		Output.Info('What if it would have been ${amount}, clearly ' + Describe(amount, 'dog') + "?");			
		Output.Info('What if it would have been ' + Describe(Math.max(amount, 12), 'elephant') + "?");
		
		// this one will fail, uncomment to test
		//Output.Info('What if it would have been ' + Describe('three', 'lion') + "?");
    }
}
