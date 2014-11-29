// based on 
// https://raw.githubusercontent.com/elsassph/vanilla-haxe-js/master/src/Main.hx

package;

import haxe.Http;
import haxe.Json;
import profiling.*;
import tests.*;
import customizer.*;

#if js
import js.Browser;
import js.html.ButtonElement;
import js.html.DivElement;
import js.html.UListElement;
#end

class Main	implements IOutput 
			implements IProfiled  // enables profiling for this class
{
	var view : DivElement;
	var dataroot : DivElement;
	var button : ButtonElement;
	var data : Array<ItemInfo>;
	
	// entry point
	static function main() 
	{
		var app = new Main();
		app.Run();
	}

	
	function new()
	{
		data = new Array<ItemInfo>();

		// Haxe Magic, uncomment to test
		//var s = untyped __js__("alert(\"Welcome!\");");
	}
	
	function Run() 
	{
		CreateChildren();
		RunTests();
	}
	
	function RunTests() {
		new MacroSurprise(this).Execute();
		new BuildTimeRunTime(this).Execute();
		new BunchOfCats(this).Execute();
		new Customizing(this).Execute();
		new ProfilingResults(this).Execute();
	}

	
	public function Info( theText : String) : Void	{
		data.push( {
			label: theText,
			id: data.length
		});
		Render();
	}
	
	public function Error( theText : String) : Void	{
		data.push( {
			label: theText,
			id: data.length,
			error : true
		});
		Render();
	}
	
	public function NewSection( title : String) : Void {
		data.push( {
			label: title,
			id: data.length,
			block : 1
		});
		Render();
	}
	
	public function EndSection() : Void {
		data.push( {
			label: "(end)",
			id: data.length,
			block : -1
		});
		Render();
	}
	
	function Render() 
	{
		var doc = Browser.document;
		var divs = new Array<DivElement>();		
		
		dataroot.innerHTML = "";
		var div = dataroot;
		
		for (info in data)
		{
			if ( info.block == null) {
				var par = doc.createParagraphElement();
				par.textContent = info.label;
				if ( info.error) {
					par.className = "error";
				}
				div.appendChild(par);
			} else {
				if ( info.block > 0) {
					divs.push(div);
					div = doc.createDivElement();
					var h1 = doc.createElement('h${divs.length}');
					h1.textContent = info.label;
					div.appendChild(h1);
				} else {
					var outer = divs.pop();
					outer.appendChild(div);
					div = outer;
				}
			}
		}
	}
	
	
	function CreateChildren() 
	{
		var doc = Browser.document;
		
		doc.title = CustomConfig.Title;
		
		view = doc.createDivElement();
		view.className = "main";
		
		dataroot = doc.createDivElement();
		dataroot.className = "dataroot";
		
		view.appendChild(dataroot);
		doc.body.appendChild(view);
	}

}

typedef ItemInfo = {
	label : String,
	?date : String,
	id    : Int,
	?error : Bool,
	?block : Int // null = no, true = open, false = close
}


