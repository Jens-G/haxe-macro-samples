package profiling;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

#if (sys && macro)
class ProfilingSetup
 {
	public static function instrument() : Array<Field> {
		
		var fields = Context.getBuildFields();
		var cls = Context.getLocalClass().get();
		
		for ( field in fields) {
			switch(field.kind) {
			case FFun(f) : 
				if( f.expr != null) {
					var expr = f.expr.expr;
					switch( expr) {
					case EBlock(blk) : 
						var fEnter = macro ProfilingData.EnterMethod;
						var fLeave = macro ProfilingData.LeaveMethod;
						var className = cls.pack.join(".") +"." + cls.name +"." + field.name;
						var methodName = { expr: EConst( CString(className)), pos: cls.pos};
						blk.insert(0, { expr: ECall( fEnter, [ methodName]), pos: cls.pos } );
						blk.push(     { expr: ECall( fLeave, [ methodName]), pos: cls.pos } );
						
					default:
						trace(' unexpected ${expr}');
						// less interesting
					}
				}
		
			default:
				// less interesting
			}
		}
		
		return fields;
	}
}
#end

// EOF