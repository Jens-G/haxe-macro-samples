package profiling;


@caption("Profiler results")
class ProfilingResults extends Testable
 {
    public override function Test() : Void {
		for ( elm in ProfilingData.Data) {

			var parts = 0;
			var anz : Int;
			
			var pending = "";
			anz = elm.pendingCalls;
			if( anz > 0)  {
				++parts;
				var calls = ' $anz call' + (anz > 1 ? 's' : '');
				pending = '${calls} pending';
			}
			
			anz = elm.calls;
			var completed = "";
			if( anz > 0)  {
				++parts;
				// more than msec precision does not make any sense at all
				var msec : Float = Math.round( elm.time * 1000);
				var calls = ' $anz call' + (anz > 1 ? 's' : '');
				completed = '${msec} msec spent with ${calls}';
			}
			
			var comma = (parts > 1) ? ", " : "";
			
			Output.Info('method ${elm.method}: ${completed}${comma}${pending}.');
		}
    }
	 

}

// EOF