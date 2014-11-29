package tests;

using DateTools;

#if sys
import sys.net.Host;
#end

#if macro
import haxe.macro.Expr;
#end

#if js
import js.Browser;
#end

@caption("Build-time vs. Run-time")
class BuildTimeRunTime extends Testable {
	
    public static function CurrentTimestamp() : String {
		var stamp = Date.now().format("%Y-%m-%d %T");
        return '${stamp}';
    }

	private static function CurrentSystem() : String {
		#if sys
			var machine = Host.localhost();
			return Sys.systemName()+" machine "+machine;
		#elseif js
			var agent = Browser.navigator.userAgent.split(";")[0] + ")";
			return agent+ " on "+Browser.navigator.platform;		
		#else
			#error unhandled system
		#end		
	}
	
    macro private static function MacroTimestamp() : Expr {
        return macro $v{ CurrentTimestamp() };
    }
	
	macro private static function MacroSystem() : Expr {
		var name = CurrentSystem();
		return macro $v{name};
	}
	
    private override function Test() : Void {
        Output.Info('Built at '+MacroTimestamp()+' on '+MacroSystem());
        Output.Info('Running '+CurrentTimestamp()+' on '+CurrentSystem());
    }

}
