package profiling;

import haxe.Timer;
import haxe.ds.StringMap;
import js.html.IFrameElement;

class ProfilingData
 {
	public static var Data(default, null) = new StringMap<ProfDataItem>();
	 
	private static function GetEntry( method : String ) : ProfDataItem {
		if ( Data.exists(method))
			return Data.get(method);
		
		var elm = new ProfDataItem(method);
		Data.set(method, elm);
		return elm;
	}
	
	public static function EnterMethod( method : String ) : Void {
		//trace('Enter $method ');
		var elm = GetEntry(method);
		elm.Enter();
	}
	 
	public static function LeaveMethod( method : String ) : Void {
		//trace('Leave $method');
		var elm = GetEntry(method);
		elm.Leave();
	}
	 

}

private class ProfDataItem {
	
	public var method(default, null) : String;
	public var calls(default, null) : Int = 0;
	public var time(default, null) : Float = 0;
	
	private var pending : Array<Float> = new Array<Float>();
	public var pendingCalls(get,never) : Int;
	
	
	public function new( name : String) {
		method = name;
	}

	public function Enter() {
		pending.push( Timer.stamp());
	}
	
	public function Leave() {
		var start = pending.pop();
		time += ( Timer.stamp() - start);
		++calls;
	}
	
	public function get_pendingCalls() : Int {
		return pending.length;
	}
}


// EOF