package ;

import customizer.*;
import haxe.rtti.Meta;

#if (haxe_ver >= 3.2)
import haxe.rtti.Rtti;
#end


@:rtti
#if ! macro @:autoBuild(customizer.CustomizerMacro.customizeClass()) #end
class Testable 
{
	private var Output(default, null) : IOutput;
	
	public function new( output : IOutput) {
		this.Output = output;
	}


	private var blocks : Int = 0;
		
	private function OpenBlock( caption : String) : Void {
		Output.NewSection( caption);
		++blocks;
	}
	
	private function CloseBlock( closeAll : Bool = false) : Void {
		var close = closeAll ? blocks : Math.min( 1, blocks);
		
		while ( close > 0) {
			Output.EndSection();
			--close;
		}
	}

	
	// returns @caption meta data, defaults to the class name otherwise
	private function Title() : String {
		var descr = Type.getClassName(Type.getClass(this));  // default
		var cls = Type.getClass(this);

		// haxe.rtti.Rtti requires Haxe 3.2.0
		#if (haxe_ver >= 3.2)
		var rtti = Rtti.getRtti(cls);
		if ( rtti.meta != null) {
			for ( entry in rtti.meta) {
				switch(entry.name) {
				case "caption":
					if ( (entry.params != null) && (entry.params.length > 0) && (entry.params[0] != "")) {
						descr = entry.params[0];
					}
				default:
					// less interesting
				}
			}
		}
		#end
			
		// this works with 3.1.3
		var meta = Meta.getType(cls);
		if ( (meta.caption != null) && (meta.caption.length > 0) && (meta.caption[0] != "")) {
			descr = meta.caption[0];
		}
			
		return descr;
	}
	
	
    public function Execute() : Void {
		try
		{
			OpenBlock( Title());
			Test();
			CloseBlock(true);
		}
		catch ( e : Dynamic)
		{
			trace('ERROR: $e');
			if( Output != null) {
				Output.Error('ERROR: $e');
				CloseBlock(true);
			}				
		}
	}
	
    private function Test() : Void {
		throw "must be overridden";
	}
}