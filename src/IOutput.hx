package ;

interface IOutput {
	function Info( txt : String) : Void;
	function Error( txt : String) : Void;

	function NewSection( id : String) : Void;
	function EndSection() : Void;
}

