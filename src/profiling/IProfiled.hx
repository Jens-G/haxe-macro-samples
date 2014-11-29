package profiling;

@:autoBuild(profiling.ProfilingSetup.instrument())
interface IProfiled {
	// Note: no members
	// Any class which implement an empty interface with "@:autoBuild" 
	// will not implement this interface in the final compiled output.
}


// EOF