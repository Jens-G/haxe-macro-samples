package tests ;

import haxe.macro.Expr;

@caption("Macro Surprise")
class MacroSurprise extends Testable {
	
	public override function Test() : Void {
		var x = 0;
		var b = Zweimal(++x);  // macro -> Auswertung zur Buildzeit
		Output.Info( 'x = $x, b = $b');  // x = 2, b = 3 weil (++x + ++x) = 1 + 2 = 3
	}

	macro static function Zweimal(e:Expr) {
		return macro $e + $e;  
	}
}
