package customizer ;

import haxe.macro.Expr;  
import haxe.macro.Context;


@:build(customizer.CustomizerMacro.customizeConfig())
class CustomConfig
{
	// all default values
    static public inline var Title = "Boring Standard Solution™";
    static public inline var DescriberFeature = false;
} 





// EOF