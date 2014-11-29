package customizer ;

import haxe.Json;
import haxe.macro.Expr;  
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Type;
import StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
#end


// macro build helper class
#if (sys && macro)
class CustomizerMacro
 {
	inline private static var folder : String = "customizing/";
	inline private static var customfile : String = "customizing.json";
	
	// get out folder, must exist
	private static function BuildOutputFolder() : String {
		var outdir = Compiler.getOutput();
		if ( outdir == null)
			return null;
			
		while ( ! (FileSystem.exists(outdir) && FileSystem.isDirectory(outdir))) {
			if ( outdir.indexOf("\\") > 0) {
				var tmp = outdir.split("\\");
				tmp.pop();
				outdir = tmp.join("\\");
			} else if ( outdir.indexOf("/") > 0) {
				var tmp = outdir.split("/");
				tmp.pop();
				outdir = tmp.join("/");
			} else {
				return null; // not found
			}				
		}
		
		return outdir;
	}
		
	private static function readCustomizingFile() : Dynamic {
		// default
		var fname = folder + customfile;
		
		// define?
		var argsCustom = Context.definedValue('customizing');
		if ( (argsCustom != null) && (argsCustom != "")) {
			fname = argsCustom;
			if ( FileSystem.isDirectory(fname) || (! FileSystem.exists(fname))) 
				throw 'Customizing file not found: $fname';
		}
		
		// process customizing file
		var contents : String = "";
		if( FileSystem.exists(fname) && (! FileSystem.isDirectory(fname))) {
			var file = File.read( fname, false);
			while( ! file.eof()) {
				contents += file.readLine();
			}
		}

		if( contents == "")
			contents = "{}";
			
		return Json.parse(contents);
	}
	
    private static function GetFiles( directory : String) : Array<String>
    {
		var files = new Array<String>();
		
		#if (sys && macro)
		for (fileName in FileSystem.readDirectory(directory))
			if ( ! FileSystem.isDirectory(directory + fileName))
				files.push( fileName);
		#end
		
		return files;
	}
     
	public static function addResources() : Array<Field>
    {
        var fields : Array<Field> = Context.getBuildFields(); 
		var custom = new CustomizingData( readCustomizingFile());
		
		var pos = Context.currentPos();
		
		for (fname in GetFiles(folder))
        {
			var fld : Dynamic = {};
			fld.name   = StringTools.replace( fname, ".", "_");
			fld.doc    = 'Customization data file $fname';
			fld.access = [Access.APublic, Access.AStatic, Access.AInline];
			fld.kind   = FieldType.FVar( macro : String, macro $v { fname } );
			fld.pos    = pos;
			fields.push( fld);
        }

		// copy or delete custom CSS
		var outdir = BuildOutputFolder();
		if( outdir != null) {
			var cssFile = outdir + "/customized.css";
			if( FileSystem.exists(cssFile) && (! FileSystem.isDirectory(cssFile))) {
				FileSystem.deleteFile( cssFile);
				trace("removed " + cssFile);
			}
			if ( (custom.layout_style != null) && (custom.layout_style != "")) {
				File.copy( folder + custom.layout_style, cssFile);
				trace("copied " + folder + custom.layout_style +" into "+cssFile);
			}
		}
		
		return fields;
    }

	
	public static function customizeConfig() : Array<Field>
    {
        var fields : Array<Field> = Context.getBuildFields(); 
		var custom = new CustomizingData( readCustomizingFile());

		// patch fields according to config
		for ( field in fields) {
			switch(field.kind) {
			case FVar(t, e):
				switch(field.name) {
				case "Title": 
					if ( (custom.layout_title != null) && (custom.layout_title != "")) {
						field.kind = FVar( t, macro $v { custom.layout_title } );
					}
				
				case "DescriberFeature": 
					if ( custom.feat_describer != null) {
						field.kind = FVar( t, macro $i{'${custom.feat_describer}'});
					}
				
				default:
					// less interesting
				}

			default:
				// less interesting
			}
        }

		return fields;
    }

	
	public static function customizeClass() : Array<Field>
    {
        var fields : Array<Field> = Context.getBuildFields(); 
		var custom = new CustomizingData( readCustomizingFile());

		// patch fields according to config
		for ( field in fields) {
			
			var metas = field.meta;
			for ( meta in metas) {
				switch( meta.name) {
				case "feature":
					if( (meta.params != null) && (meta.params.length > 0)) {
						var feature = meta.params[0].expr;
						switch(feature) {
						case EConst(ec):
							switch(ec) {
							case CString(cs):
								switch( cs.toLowerCase()) {
								case "describer":
									trace('status of feature "$cs" is ${custom.feat_describer}');
									if ( ! custom.feat_describer) {
										disableField(field);
									}
									
								default:
									throw 'unhandled feature $cs';
								}
								
							default:
								throw 'unhandled EConst $ec';
							}
							
						default:
							throw 'unhandled $feature';
						}
					}
				default:
					// less interesting
				}
			}
		}
		
		return fields;
    }

    private static function disableField( field : Field) {
		switch(field.kind) {
		case FFun(f):
			if( f.expr != null) {
				var expr = f.expr.expr;
				switch( expr) {
				case EBlock(blk) :  	// remove entire method implementation
					while ( blk.length > 0) { 
						blk.pop(); 
					}
					switch( f.ret) {
					case null:
						// Void
					case TPath(p):
						var tname = p.pack.join(".") + "." + p.name;
						switch(tname) {
						case ".Void":  
							// Void, nothing to do
						default:
							throw 'unhandled return type ${f.ret}';  // TODO: nach Bedarf ergänzen
						}
					default:
						trace('unexpected return type ${f.ret}');
					}
					
				default:
					trace('unexpected ${expr}');
				}
			}
			
		default:
			throw 'unhandled ${field.kind}';
		}
	}
	
}
#end


#if (sys && macro)
private class CustomizingData {
	
	public var feat_describer : Null<Bool> = null;
	public var layout_style : String = "";
	public var layout_title : String = "";

	public function new( json : Dynamic) {
		if (json.features != null) {
			feat_describer = json.features.describer;
		}

		if (json.layout != null) {
			if (json.layout.title != null) {
				layout_title = json.layout.title;
			}
			if (json.layout.style != null) {
				layout_style = json.layout.style;
			}
		}
	}
	
}
#end



// EOF