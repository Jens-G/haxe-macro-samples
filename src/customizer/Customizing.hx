package customizer ;

import haxe.macro.Expr;  
import haxe.macro.Context;

// main test class
@caption("Customizing the AST")
class Customizing extends Testable {
	
    public override function Test() : Void {
		
		// print customization info
		Output.Info( 'Customization: ${CustomConfig}');
		
		// test IDE completion
		// Thanks to Mark Knol for the idea shown on 
		// http://blog.stroep.nl/2014/01/haxe-macros/
		Output.Info( "files in /customizing:");	
		Output.Info( "- " + CustomResources.HaxeRulez_css);
		Output.Info( "- " + CustomResources.webmobile_json);
    }
}


@:build(customizer.CustomizerMacro.addResources())
class CustomResources
{
    // wird während Build durch CustomizerMacro gefüllt
} 



// EOF